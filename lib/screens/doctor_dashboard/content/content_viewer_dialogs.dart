import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/content_item.dart';

/// Video player dialog for viewing videos
class VideoPlayerDialog extends StatefulWidget {
  final ContentItem item;

  const VideoPlayerDialog({super.key, required this.item});

  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.item.fileUrl.isEmpty) {
        setState(() {
          _hasError = true;
        });
        return;
      }

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.item.fileUrl),
      );

      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: TextStyle(
                          fontSize: AppConstants.h4Size,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF111518),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.item.description != null) ...[
                        const SizedBox(height: AppConstants.spacing1),
                        Text(
                          widget.item.description!,
                          style: TextStyle(
                            fontSize: AppConstants.body2Size,
                            color: isDark
                                ? Colors.grey.shade400
                                : AppColors.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.white : const Color(0xFF111518),
                  ),
                ),
              ],
            ),
          ),
          // Video player
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: _hasError
                  ? Center(
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
                    )
                  : _isInitialized && _controller != null
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_controller!),
                            // Play/pause button overlay
                            GestureDetector(
                              onTap: () {
                                if (_controller!.value.isPlaying) {
                                  _controller!.pause();
                                } else {
                                  _controller!.play();
                                }
                                setState(() {});
                              },
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _controller!.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Image viewer dialog for viewing images
class ImageViewerDialog extends StatelessWidget {
  final ContentItem item;

  const ImageViewerDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: AppConstants.h4Size,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF111518),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.description != null) ...[
                        const SizedBox(height: AppConstants.spacing1),
                        Text(
                          item.description!,
                          style: TextStyle(
                            fontSize: AppConstants.body2Size,
                            color: isDark
                                ? Colors.grey.shade400
                                : AppColors.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.white : const Color(0xFF111518),
                  ),
                ),
              ],
            ),
          ),
          // Image
          if (item.fileUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppConstants.radiusLarge),
                bottomRight: Radius.circular(AppConstants.radiusLarge),
              ),
              child: Image.network(
                item.fileUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: Colors.grey.shade200,
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
                            'Failed to load image',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: AppConstants.body2Size,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 300,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 300,
              color: Colors.grey.shade200,
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

