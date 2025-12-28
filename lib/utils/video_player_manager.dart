import 'package:video_player/video_player.dart';

/// Singleton manager to handle multiple video players
/// Ensures only one video plays at a time and disposes others
class VideoPlayerManager {
  static final VideoPlayerManager _instance = VideoPlayerManager._internal();
  factory VideoPlayerManager() => _instance;
  VideoPlayerManager._internal();

  VideoPlayerController? _currentController;
  String? _currentVideoId;

  /// Register a video player as the active one
  /// If another video is playing, it will be paused (but not disposed)
  void setActivePlayer(String videoId, VideoPlayerController controller) {
    // If there's already a playing video, pause it
    if (_currentController != null && _currentVideoId != videoId) {
      try {
        if (_currentController!.value.isInitialized && 
            _currentController!.value.isPlaying) {
          _currentController!.pause();
        }
      } catch (e) {
        // Ignore errors during pause
      }
    }

    _currentController = controller;
    _currentVideoId = videoId;
  }

  /// Unregister a video player (when it's disposed)
  void removePlayer(String videoId) {
    if (_currentVideoId == videoId) {
      _currentController = null;
      _currentVideoId = null;
    }
  }

  /// Check if a video is currently playing
  bool isVideoPlaying(String videoId) {
    return _currentVideoId == videoId && 
           _currentController != null && 
           _currentController!.value.isInitialized &&
           _currentController!.value.isPlaying;
  }

  /// Pause the currently playing video
  void pauseCurrentVideo() {
    if (_currentController != null && 
        _currentController!.value.isInitialized &&
        _currentController!.value.isPlaying) {
      _currentController!.pause();
    }
  }

  /// Dispose all video players
  void disposeAll() {
    if (_currentController != null) {
      try {
        if (_currentController!.value.isInitialized) {
          _currentController!.pause();
        }
        _currentController!.removeListener(() {});
        _currentController!.dispose();
      } catch (e) {
        // Ignore errors during disposal
      }
      _currentController = null;
      _currentVideoId = null;
    }
  }
}

