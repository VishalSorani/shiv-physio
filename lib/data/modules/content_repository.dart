import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../base_class/base_repository.dart';
import '../models/content_item.dart';
import '../service/storage_service.dart';

/// Repository for managing doctor content (videos/images)
class ContentRepository extends BaseRepository {
  final SupabaseClient _supabase;
  final StorageService _storageService;

  ContentRepository({
    required SupabaseClient supabase,
    required StorageService storageService,
  }) : _supabase = supabase,
       _storageService = storageService;

  /// Get current doctor ID from storage
  String? _getDoctorId() {
    final user = _storageService.getUser();
    return user?.id;
  }

  /// Get all content items for the doctor
  Future<List<ContentItem>> getContentItems({
    ContentCategory? categoryFilter,
  }) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        logW('No doctor ID found in storage');
        return [];
      }

      logD('Fetching content items for doctor: $doctorId');

      dynamic query = _supabase
          .from('content')
          .select('*')
          .eq('uploaded_by', doctorId)
          .eq('is_published', true)
          .order('created_at', ascending: false);

      // Apply category filter if provided
      if (categoryFilter != null && categoryFilter != ContentCategory.all) {
        query = query.eq('category', categoryFilter.toDb());
      }

      final response = await query;

      if (response.isEmpty) {
        logD('No content items found');
        return [];
      }

      final items = (response as List)
          .map((json) => ContentItem.fromJson(json))
          .toList();

      logI('Fetched ${items.length} content items');
      return items;
    } catch (e) {
      logE('Error fetching content items', error: e);
      handleRepositoryError(e);
      rethrow;
    }
  }

  /// Get all content items for patients (uses doctor ID from Supabase function)
  Future<List<ContentItem>> getContentItemsForPatients({
    ContentCategory? categoryFilter,
  }) async {
    try {
      logD('Fetching content items for patients');

      // Get doctor ID using Supabase function
      final doctorIdResponse = await _supabase.rpc('get_doctor_id');
      String? doctorId;

      if (doctorIdResponse != null) {
        if (doctorIdResponse is String) {
          doctorId = doctorIdResponse;
        } else if (doctorIdResponse is Map) {
          doctorId = doctorIdResponse['id']?.toString();
        } else {
          doctorId = doctorIdResponse.toString();
        }
      }

      if (doctorId == null || doctorId.isEmpty || doctorId == 'null') {
        logW('No doctor ID found');
        return [];
      }

      logD('Found doctor ID: $doctorId');

      dynamic query = _supabase
          .from('content')
          .select('*')
          .eq('uploaded_by', doctorId)
          .eq('is_published', true)
          .order('created_at', ascending: false);

      // Apply category filter if provided
      if (categoryFilter != null && categoryFilter != ContentCategory.all) {
        query = query.eq('category', categoryFilter.toDb());
      }

      final response = await query;

      if (response.isEmpty) {
        logD('No content items found');
        return [];
      }

      final items = (response as List)
          .map((json) => ContentItem.fromJson(json))
          .toList();

      logI('Fetched ${items.length} content items for patients');
      return items;
    } catch (e) {
      logE('Error fetching content items for patients', error: e);
      handleRepositoryError(e);
      rethrow;
    }
  }

  /// Get total count of content items
  Future<int> getContentCount({ContentCategory? categoryFilter}) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        return 0;
      }

      dynamic query = _supabase
          .from('content')
          .select('id')
          .eq('uploaded_by', doctorId);

      // Apply category filter if provided
      if (categoryFilter != null && categoryFilter != ContentCategory.all) {
        query = query.eq('category', categoryFilter.toDb());
      }

      final response = await query;
      return (response as List).length;
    } catch (e) {
      logE('Error getting content count', error: e);
      return 0;
    }
  }

  /// Upload file to Firebase Storage
  Future<String> uploadFileToStorage({
    required String filePath,
    required String fileName,
    required ContentType contentType,
  }) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        throw Exception('No doctor ID found in storage');
      }

      logD('Uploading file to Firebase Storage: $fileName');

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      // Determine storage path based on content type
      final folder = contentType == ContentType.video ? 'videos' : 'images';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileName.split('.').last;
      final storageFileName = '${doctorId}_$timestamp.$extension';
      final storagePath = 'content/$folder/$storageFileName';

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      final uploadTask = storageRef.putFile(file);

      // Wait for upload to complete
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      logI('File uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      logE('Error uploading file to storage', error: e);
      rethrow;
    }
  }

  /// Upload content file (video or image)
  Future<ContentItem> uploadContent({
    required String filePath,
    required ContentType type,
    required ContentCategory category,
    required String title,
    String? description,
    required String fileUrl, // URL after uploading to storage
    String? thumbnailUrl,
  }) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        throw Exception('No doctor ID found in storage');
      }

      logD('Uploading content: $title, type: ${type.toDb()}');

      // Prepare data for content table
      final contentData = <String, dynamic>{
        'uploaded_by': doctorId,
        'title': title,
        'description': description,
        'category': category.toDb(),
        'type': type.toDb(), // Store type explicitly
        'is_published': true,
      };

      // Note: fileUrl and thumbnailUrl should be provided after uploading to storage
      // For now, these will be null and can be updated later
      if (fileUrl != null) {
        if (type == ContentType.video) {
          contentData['video_url'] = fileUrl;
          contentData['storage_path'] = null;
        } else {
          contentData['storage_path'] = fileUrl;
          contentData['video_url'] = null;
        }
      }

      if (thumbnailUrl != null) {
        contentData['thumbnail_url'] = thumbnailUrl;
      }

      final response = await _supabase
          .from('content')
          .insert(contentData)
          .select()
          .single();

      final contentItem = ContentItem.fromJson(response);
      logI('Content uploaded successfully');
      return contentItem;
    } catch (e) {
      logE('Error uploading content', error: e);
      handleRepositoryError(e);
    }
  }

  /// Delete content item
  Future<void> deleteContent(String contentId) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        throw Exception('No doctor ID found in storage');
      }

      logD('Deleting content: $contentId');

      await _supabase
          .from('content')
          .delete()
          .eq('id', contentId)
          .eq('uploaded_by', doctorId);

      logI('Content deleted successfully');
    } catch (e) {
      logE('Error deleting content', error: e);
      handleRepositoryError(e);
    }
  }

  /// Update content item
  Future<void> updateContent(ContentItem content) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        throw Exception('No doctor ID found in storage');
      }

      logD('Updating content: ${content.id}');

      // Map ContentItem to content table structure
      // For videos: use video_url, for images: use storage_path
      final updateData = <String, dynamic>{
        'title': content.title,
        'description': content.description,
        'category': content.category.toDb(),
        'type': content.type.toDb(), // Store type explicitly
        'thumbnail_url': content.thumbnailUrl,
      };

      // Set video_url for videos, storage_path for images
      if (content.type == ContentType.video) {
        updateData['video_url'] = content.fileUrl;
        updateData['storage_path'] = null;
      } else {
        updateData['storage_path'] = content.fileUrl;
        updateData['video_url'] = null;
      }

      await _supabase
          .from('content')
          .update(updateData)
          .eq('id', content.id)
          .eq('uploaded_by', doctorId);

      logI('Content updated successfully');
    } catch (e) {
      logE('Error updating content', error: e);
      handleRepositoryError(e);
    }
  }
}
