import 'package:flutter_bloc/flutter_bloc.dart';

import 'video_feed_state.dart';

class VideoFeedCubit extends Cubit<VideoFeedState> {
  VideoFeedCubit() : super(const VideoFeedState());

  void switchMode(VideoMode mode) {
    emit(state.copyWith(mode: mode));
  }

  void toggleFullscreen() {
    emit(state.copyWith(isFullscreen: !state.isFullscreen));
  }

  void setFullscreen(bool fullscreen) {
    emit(state.copyWith(isFullscreen: fullscreen));
  }
}
