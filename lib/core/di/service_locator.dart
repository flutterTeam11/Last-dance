import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/drone/data/drone_repository_impl.dart';
import '../../features/drone/domain/drone_repository.dart';
import '../../features/drone/presentation/cubit/drone_status_cubit.dart';
import '../../features/drone/presentation/cubit/drone_tracking_cubit.dart';
import '../../features/drone/presentation/cubit/mission_cubit.dart';
import '../../features/drone/presentation/cubit/pi_health_cubit.dart';
import '../../features/drone/presentation/cubit/video_feed_cubit.dart';
import '../../features/onboarding/cubit/onboarding_cubit.dart';
import '../pi_http_client.dart';
import '../utils/local_storage_service.dart';
import '../websocket/drone_ws_bridge.dart';
import '../websocket/ws_client.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  // Core
  getIt.registerLazySingleton<LocalStorageService>(() => LocalStorageService());
  getIt.registerLazySingleton<PiHttpClient>(
    () => PiHttpClient(baseUrl: 'http://raspaberry.local:5000'),
  );
  getIt.registerLazySingleton<WsClient>(
    () => WsClient(baseUrl: 'ws://raspaberry.local:8000'),
  );
  getIt.registerLazySingleton<DroneWsBridge>(
    () => DroneWsBridge(getIt<WsClient>()),
  );

  // Firebase
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
      firestore: getIt<FirebaseFirestore>(),
      localStorage: getIt<LocalStorageService>(),
    ),
  );
  getIt.registerLazySingleton<DroneRepository>(
    () => DroneRepositoryImpl(firestore: getIt<FirebaseFirestore>()),
  );

  // Cubits
  getIt.registerFactory<OnboardingCubit>(() => OnboardingCubit());
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<DroneTrackingCubit>(
    () => DroneTrackingCubit(repository: getIt<DroneRepository>()),
  );
  getIt.registerLazySingleton<DroneStatusCubit>(
    () => DroneStatusCubit(repository: getIt<DroneRepository>()),
  );
  getIt.registerLazySingleton<VideoFeedCubit>(() => VideoFeedCubit());
  getIt.registerLazySingleton<MissionCubit>(
    () => MissionCubit(piClient: getIt<PiHttpClient>()),
  );
  getIt.registerLazySingleton<PiHealthCubit>(
    () => PiHealthCubit(
      piClient: getIt<PiHttpClient>(),
      droneStatusCubit: getIt<DroneStatusCubit>(),
    ),
  );
}
