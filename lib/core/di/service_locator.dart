import 'package:get_it/get_it.dart';

import '../../features/onboarding/cubit/onboarding_cubit.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerFactory<OnboardingCubit>(() => OnboardingCubit());
}
