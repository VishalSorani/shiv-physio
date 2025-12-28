import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../core/constants/app_constants.dart';
import '../data/models/content_item.dart';
import '../utils/video_player_manager.dart';

/// Inline video player widget for content cards
class InlineVideoPlayer extends StatefulWidget {
  final ContentItem content;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const InlineVideoPlayer({
    super.key,
    required this.content,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<InlineVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isPlaying = false;
  bool _showControls = true;
  final VideoPlayerManager _manager = VideoPlayerManager();
  late final String _videoId;

  @override
  void initState() {
    super.initState();
    // Use content ID as video ID for uniqueness, fallback to timestamp
    _videoId = widget.content.id.isNotEmpty 
        ? widget.content.id 
        : DateTime.now().millisecondsSinceEpoch.toString();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.content.fileUrl.isEmpty) {
        setState(() {
          _hasError = true;
        });
        return;
      }

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.content.fileUrl),
      );

      await _controller!.initialize();
      _controller!.addListener(_videoListener);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      
      // Register with manager but don't auto-play
      // Video will only play when user taps
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _videoListener() {
    if (_controller != null && mounted) {
      setState(() {
        _isPlaying = _controller!.value.isPlaying;
      });
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    if (_controller!.value.isPlaying) {
      // Pause current video
      _controller!.pause();
      _manager.removePlayer(_videoId);
    } else {
      // Stop any other playing video and register this one
      _manager.setActivePlayer(_videoId, _controller!);
      _controller!.play();
    }
    
    setState(() {
      _showControls = true;
    });
    
    // Hide controls after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _controller != null && _controller!.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // Unregister from manager
    _manager.removePlayer(_videoId);
    
    // Pause before disposing
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.pause();
    }
    
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ??
        BorderRadius.circular(AppConstants.radiusXLarge);
    final thumbnailUrl = widget.content.thumbnailUrl ?? widget.content.fileUrl;

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video player or thumbnail
              if (_hasError)
                _buildErrorState()
              else if (_isInitialized && _controller != null)
                VideoPlayer(_controller!)
              else
                _buildLoadingState(thumbnailUrl),
              // Controls overlay
              if (_isInitialized && _controller != null)
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: AppConstants.shortAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: borderRadius,
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(AppConstants.spacing4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(String? thumbnailUrl) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
          Image.network(
            thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildPlaceholder(),
          )
        else
          _buildPlaceholder(),
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.grey.shade900,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppConstants.spacing2),
            Text(
              'Failed to load video',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: AppConstants.body2Size,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(
          Icons.videocam_outlined,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }
}

