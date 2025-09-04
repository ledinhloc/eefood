import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../network/dio_client.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Register DioClient
  getIt.registerLazySingleton(() => DioClient());

  // Register SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);

  // Register Repository
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      dio: getIt<DioClient>().dio,
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Register UseCases
  getIt.registerLazySingleton(() => Login(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => Logout(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetCurrentUser(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RefreshToken(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetProfile(getIt<AuthRepository>()));
}