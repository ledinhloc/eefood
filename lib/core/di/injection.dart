import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/features/auth/presentation/bloc/on_boarding_bloc/on_boarding_cubit.dart';
import 'package:eefood/features/noti/data/repositories/notification_repository_impl.dart';
import 'package:eefood/features/noti/domain/repositories/notification_repository.dart';
import 'package:eefood/features/noti/presentation/provider/notification_cubit.dart';
import 'package:eefood/features/noti/presentation/provider/notification_settings_cubit.dart';
import 'package:eefood/features/post/data/repositories/post_reaction_repository_impl.dart';
import 'package:eefood/features/post/data/repositories/post_repository_impl.dart';
import 'package:eefood/features/post/domain/repositories/post_reaction_repository.dart';
import 'package:eefood/features/post/domain/repositories/post_repository.dart';
import 'package:eefood/features/profile/domain/repositories/profile_repository.dart';
import 'package:eefood/features/profile/domain/usecases/profile_usecase.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/repositories/recipe_repository_impl.dart';
import 'package:eefood/features/recipe/domain/repositories/recipe_repository.dart';
import 'package:eefood/features/recipe/domain/usecases/recipe_usecases.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_cubit.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_refresh_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/profile/data/repo/profile_repository_imp.dart';
import '../../features/recipe/data/repositories/shopping_repository_impl.dart';
import '../../features/recipe/domain/repositories/shopping_repository.dart';
import '../../features/recipe/presentation/provider/shopping_cubit.dart';
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
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(dio: getIt<DioClient>().dio),
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
  getIt.registerLazySingleton(() => UpdateProfile(getIt<ProfileRepository>()));

  // OnBoarding Cubit (singleton)
  getIt.registerLazySingleton<OnBoardingCubit>(() => OnBoardingCubit());

  //region
  getIt.registerLazySingleton(() => Province(getIt<RecipeRepository>()));

  // ingredients
  getIt.registerLazySingleton(() => Ingredients(getIt<RecipeRepository>()));
  // categories
  getIt.registerLazySingleton(() => Categories(getIt<RecipeRepository>()));
  // recipe crud cubit
  getIt.registerFactoryParam<RecipeCrudCubit, RecipeModel?, void>(
    (initialRecipe, _) => RecipeCrudCubit(initialRecipe),
  );
  // recipe refresh cubit
  getIt.registerLazySingleton<RecipeRefreshCubit>(() => RecipeRefreshCubit());

  //notification cubit
  getIt.registerLazySingleton<NotificationCubit>(() => NotificationCubit());
  getIt.registerLazySingleton<NotificationSettingsCubit>(() => NotificationSettingsCubit());

  //recipe
  getIt.registerLazySingleton(() => CreateRecipe(getIt<RecipeRepository>()));
  getIt.registerLazySingleton(() => UpdateRecipe(getIt<RecipeRepository>()));
  getIt.registerLazySingleton(() => GetMyRecipe(getIt<RecipeRepository>()));
  getIt.registerLazySingleton(() => DeleteRecipe(getIt<RecipeRepository>()));

  //shopping
  getIt.registerLazySingleton<ShoppingRepository>(() => ShoppingRepositoryImpl(dio: getIt<DioClient>().dio ));
  getIt.registerLazySingleton(() => ShoppingCubit(repository: getIt<ShoppingRepository>()));

  //post
  getIt.registerLazySingleton<PostRepository>(() => PostRepositoryImpl(dio: getIt<DioClient>().dio ));
  getIt.registerLazySingleton<PostReactionRepository>(() => PostReactionRepositoryImpl(dio: getIt<DioClient>().dio ));

  // notification
  getIt.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(dio: getIt<DioClient>().dio ));
}
