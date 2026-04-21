import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/show_login_required.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_response.dart';
import 'package:eefood/features/meal_plan/domain/enum/meal_plan_item_source.dart';
import 'package:eefood/features/meal_plan/domain/enum/meal_plan_item_status.dart';
import 'package:eefood/features/meal_plan/domain/enum/meal_slot.dart';
import 'package:eefood/features/meal_plan/domain/repository/meal_plan_repository.dart';
import 'package:eefood/features/meal_plan/presentation/provider/meal_plan_cubit.dart';
import 'package:eefood/features/meal_plan/presentation/widgets/meal_plan_item_upsert_sheet.dart';
import 'package:eefood/features/post/presentation/provider/follow_cubit.dart';
import 'package:eefood/features/recipe/presentation/provider/shopping_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app_routes.dart';
import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../profile/domain/usecases/profile_usecase.dart';
import '../../data/models/recipe_detail_model.dart';
import '../provider/recipe_detail_cubit.dart';
import '../provider/similar_recipes_cubit.dart';
import '../widgets/category_list_widget.dart';
import '../widgets/instructions/instructions_tab.dart';
import '../widgets/recipe_detail/similar_recipes_section.dart';
import '../widgets/steps_tab.dart';

class RecipeDetailPage extends StatefulWidget {
  final int recipeId;
  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late final RecipeDetailCubit _cubit;
  late final SimilarRecipesCubit _similarRecipesCubit;
  late final FollowCubit _followCubit;
  int? _currentUserId;
  bool _isLoadingFollow = false;

  List<String> _extractIngredientNames(RecipeDetailModel recipe) {
    return (recipe.ingredients ?? const [])
        .map((item) => item.ingredient?.name.trim() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cubit = RecipeDetailCubit()..loadRecipe(widget.recipeId);
    _similarRecipesCubit = SimilarRecipesCubit()
      ..loadSimilarRecipes(widget.recipeId);
    _followCubit = FollowCubit();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final user = await getIt<GetCurrentUser>().call();
    if (mounted) {
      setState(() => _currentUserId = user?.id);
    }
  }

  Future<void> _handleFollowToggle(int authorId) async {
    final user = await getIt<GetCurrentUser>().call();
    if (user == null) {
      showLoginRequired(context);
      return;
    }

    if (_currentUserId == null || _currentUserId == authorId) {
      return;
    }

    setState(() => _isLoadingFollow = true);

    try {
      await _followCubit.toggleFollow(authorId, _currentUserId!);
      await _followCubit.loadFollowData(authorId);
      if (mounted) {
        final isFollowing = _followCubit.state.isFollowing;
        showCustomSnackBar(
          context,
          isFollowing ? "Đã theo dõi" : "Đã bỏ theo dõi",
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, "Có lỗi xảy ra");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingFollow = false);
      }
    }
  }

  Future<void> _openAddToMealPlanSheet(
    BuildContext context,
    RecipeDetailModel recipe,
  ) async {
    final recipeId = recipe.id;
    if (recipeId == null) {
      showCustomSnackBar(
        context,
        'Không thể thêm công thức này vào plan',
        isError: true,
      );
      return;
    }

    final now = DateTime.now();
    final selectedDate = DateTime(now.year, now.month, now.day);
    final mealPlanCubit = MealPlanCubit(
      repository: getIt<MealPlanRepository>(),
    );

    try {
      await showMealPlanItemUpsertSheet(
        context: context,
        cubit: mealPlanCubit,
        selectedDate: selectedDate,
        item: MealPlanItemResponse(
          planDate: selectedDate,
          mealSlot: MealSlot.breakfast,
          itemSource: MealPlanItemSource.recipe,
          recipeId: recipeId,
          status: MealPlanItemStatus.planned,
          recipeTitle: recipe.title,
          imageUrl: recipe.imageUrl,
        ),
      );
    } finally {
      await mealPlanCubit.close();
    }
  }

  @override
  void dispose() {
    _cubit.stopTracking();
    _similarRecipesCubit.close();
    _followCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _similarRecipesCubit),
        BlocProvider.value(value: _followCubit),
      ],
      child: BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.error != null || state.recipe == null) {
            return Scaffold(
              body: Center(child: Text(state.error ?? 'Không có dữ liệu')),
            );
          }

          final recipe = state.recipe!;
          final totalTime = (recipe.prepTime ?? 0) + (recipe.cookTime ?? 0);
          final ingredientNames = _extractIngredientNames(recipe);

          if (_currentUserId != null && recipe.userId != _currentUserId) {
            _followCubit.loadFollowData(recipe.userId);
          }

          return Scaffold(
            body: DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverAppBar(
                    shadowColor: Colors.transparent,
                    expandedHeight: 300,
                    pinned: true,
                    backgroundColor: Colors.white,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.qr_code_2_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          final deepLink =
                              AppKeys.webDeloyUrl + '/recipes/${recipe.id}';
                          Navigator.pushNamed(
                            context,
                            AppRoutes.qrCodeScreen,
                            arguments: {
                              'recipeId': recipe.id,
                              'recipeUrl': deepLink,
                              'recipeTitle': recipe.title,
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {
                          _showRecipeOption(
                            context,
                            recipe.title,
                            recipe.id!,
                            recipe: recipe,
                          );
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            recipe.imageUrl ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 80,
                              ),
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black54,
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black26,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Title ---
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              recipe.title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // --- Avatar đẹp hơn ---
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.orange,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child:
                                    recipe.avatarUrl != null &&
                                        recipe.avatarUrl!.isNotEmpty
                                    ? Image.network(
                                        recipe.avatarUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 40,
                                        color: theme.colorScheme.onSurface,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // --- Thông tin người dùng ---
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          recipe.username,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.verified,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    recipe.email,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () async {
                                      User? userStory =
                                          await getIt<GetUserById>().call(
                                            recipe.userId,
                                          );
                                      await Navigator.pushNamed(
                                        context,
                                        AppRoutes.personalUser,
                                        arguments: {'user': userStory},
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.person_outline,
                                            size: 14,
                                            color: Colors.orange,
                                          ),
                                          SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              "Xem trang cá nhân",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // --- Nút follow (tùy chọn) ---
                            _buildFollowButton(recipe),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- Info summary ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _infoBlock(
                            "${recipe.ingredients?.length ?? 0}",
                            "Ingredients",
                            context,
                          ),
                          _infoBlock("${totalTime}m", "Total Time", context),
                          _infoBlock(
                            recipe.difficulty?.name ?? "N/A",
                            "Difficulty",
                            context,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // --- Description ---
                      if (recipe.description != null &&
                          recipe.description!.isNotEmpty)
                        Text(
                          recipe.description!,
                          style: TextStyle(
                            fontSize: 15,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),

                      const SizedBox(height: 12),

                      // --- Region, cook/prep times ---
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          if (recipe.region != null &&
                              recipe.region!.isNotEmpty)
                            _iconText(Icons.place, recipe.region!, context),
                          _iconText(
                            Icons.schedule,
                            "Prep: ${recipe.prepTime ?? 0} min",
                            context,
                          ),
                          _iconText(
                            Icons.local_dining,
                            "Cook: ${recipe.cookTime ?? 0} min",
                            context,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // --- Categories ---
                      if (recipe.categories != null &&
                          recipe.categories!.isNotEmpty)
                        CategoryListWidget(categories: recipe.categories!),

                      const SizedBox(height: 16),

                      // --- Video Preview ---
                      if (recipe.videoUrl != null &&
                          recipe.videoUrl!.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            // // Có thể mở video player riêng nếu bạn muốn
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   snackBarMessage("Mở video hướng dẫn: ${recipe.videoUrl}"),
                            // );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.orange,
                                  size: 40,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Xem video hướng dẫn",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),
                      const Divider(thickness: 1.2),
                      const SizedBox(height: 12),

                      // --- Tabs: Ingredients / Steps ---
                      const TabBar(
                        labelColor: Colors.orange,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.orange,
                        tabs: [
                          Tab(text: "Ingredients"),
                          Tab(text: "Instructions"),
                        ],
                      ),

                      SizedBox(
                        height: 600,
                        child: TabBarView(
                          children: [
                            InstructionsTab(),
                            StepsTab(recipe: recipe),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SimilarRecipesSection(
                        currentRecipeId: widget.recipeId,
                        availableIngredients: ingredientNames,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Widget Follow Button --
  Widget _buildFollowButton(recipe) {
    // Không hiển thị nút nếu là chính mình
    if (_currentUserId == null ||
        recipe.userId == null ||
        _currentUserId == recipe.userId) {
      return const SizedBox();
    }

    return BlocBuilder<FollowCubit, FollowState>(
      builder: (context, followState) {
        final isFollowing = followState.isFollowing;

        if (_isLoadingFollow) {
          return const SizedBox(
            width: 80,
            height: 36,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
            ),
          );
        }

        return ElevatedButton(
          onPressed: () => _handleFollowToggle(recipe.userId!),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.grey : Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isFollowing ? "Đã theo dõi" : "Theo dõi",
            style: const TextStyle(fontSize: 13),
          ),
        );
      },
    );
  }

  // --- Helper widgets ---
  Widget _iconText(IconData icon, String text, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.black45),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _infoBlock(String value, String label, BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.orange,
          ),
        ),
        Text(label, style: TextStyle(color: theme.colorScheme.onSurface)),
      ],
    );
  }

  void _showRecipeOption(
    BuildContext context,
    String recipeTitle,
    int recipeId, {
    RecipeDetailModel? recipe,
    bool isAuthor = false,
  }) async {
    final user = await getIt<GetCurrentUser>().call();
    if (user == null) {
      showLoginRequired(context);
      return;
    }

    final opts = <BottomSheetOption>[
      BottomSheetOption(
        icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.orange),
        title: 'Thêm vào danh sách nguyên liệu',
        onTap: () {
          getIt<ShoppingCubit>().addRecipe(recipeId);
          showCustomSnackBar(context, "Thêm thành công");
        },
      ),
      if (recipe != null)
        BottomSheetOption(
          icon: const Icon(Icons.calendar_month_outlined, color: Colors.orange),
          title: 'Thêm vào kế hoạch bữa ăn',
          onTap: () {
            _openAddToMealPlanSheet(context, recipe);
          },
        ),
      BottomSheetOption(
        icon: const Icon(Icons.qr_code_2_rounded),
        title: 'Chia sẻ',
        onTap: () {},
      ),
      BottomSheetOption(
        icon: const Icon(Icons.search),
        title: 'Tìm món tương tự',
        onTap: () {},
      ),
      BottomSheetOption(
        icon: const Icon(Icons.report_gmailerrorred),
        title: 'Báo cáo',
        onTap: () {},
      ),
    ];
    if (isAuthor) {
      opts.addAll([
        BottomSheetOption(
          icon: const Icon(Icons.edit),
          title: 'Chỉnh sửa',
          onTap: () {},
        ),
        BottomSheetOption(
          icon: const Icon(Icons.delete_forever),
          title: 'Xóa',
          onTap: () {},
        ),
      ]);
    }
    await showCustomBottomSheet(context, opts);
  }
}
