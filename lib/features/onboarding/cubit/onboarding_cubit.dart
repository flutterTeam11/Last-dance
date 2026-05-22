import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  void setPage(int page) {
    emit(state.copyWith(currentPage: page));
  }

  void nextPage(int totalPages) {
    if (state.currentPage < totalPages - 1) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }

  void skipToLast(int totalPages) {
    emit(state.copyWith(currentPage: totalPages - 1));
  }

  void reset() {
    emit(const OnboardingState());
  }
}
