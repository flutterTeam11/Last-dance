import 'package:equatable/equatable.dart';

enum VideoMode { normal, thermal, overlay }

class VideoFeedState extends Equatable {
  final VideoMode mode;
  final bool isFullscreen;

  const VideoFeedState({
    this.mode = VideoMode.normal,
    this.isFullscreen = false,
  });

  VideoFeedState copyWith({VideoMode? mode, bool? isFullscreen}) {
    return VideoFeedState(
      mode: mode ?? this.mode,
      isFullscreen: isFullscreen ?? this.isFullscreen,
    );
  }

  @override
  List<Object?> get props => [mode, isFullscreen];
}
