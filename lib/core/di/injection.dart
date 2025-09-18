import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/features/auth/presentation/bloc/on_boarding_bloc/on_boarding_cubit.dart';
import 'package:eefood/features/profile/domain/repositories/profile_repository.dart';
import 'package:eefood/features/profile/domain/usecases/profile_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/profile/data/repo/profile_repository_imp.dart';
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

  getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        dio: getIt<DioClient>().dio,
        sharedPreferences: getIt<SharedPreferences>()
      )
  );

  getIt.registerLazySingleton(() => FileUploader(dio: getIt<DioClient>().dio));

  // Register UseCases
  getIt.registerLazySingleton(() => Login(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => Logout(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetCurrentUser(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RefreshToken(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetProfile(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => Register(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => VerifyOtp(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => ForgotPassword(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => ResetPassword(getIt<AuthRepository>()));

  //use case profile
  getIt.registerLazySingleton(()=> UpdateProfile(getIt<ProfileRepository>()));

  // OnBoarding Cubit (singleton)
  getIt.registerLazySingleton<OnBoardingCubit>(() => OnBoardingCubit());
}