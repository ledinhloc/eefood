import 'dart:io';
import 'package:eefood/core/constants/app_constants.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/convert_time.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/core/utils/media_picker.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:eefood/features/recipe/data/models/category_model.dart';
import 'package:eefood/features/recipe/data/models/region_model.dart';
import 'package:eefood/features/recipe/domain/entities/recipe.dart';
import 'package:eefood/features/recipe/domain/usecases/recipe_usecases.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_cubit.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_state.dart';
import 'package:eefood/features/recipe/presentation/widgets/custom_dropdown.dart';
import 'package:eefood/features/recipe/presentation/widgets/media_picker_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BasicInfoSection extends StatefulWidget {
  const BasicInfoSection({Key? key}) : super(key: key);

  @override
  State<BasicInfoSection> createState() => _BasicInfoSectionState();
}

class _BasicInfoSectionState extends State<BasicInfoSection> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  late final _cubit;
  final _fileUpload = getIt<FileUploader>();
  final Province _province = getIt<Province>();

  final Categories _categories = getIt<Categories>();
  ProvinceModel? _selectedProvince;
  List<CategoryModel>? _listCategories;

  File? _imageFile;
  File? _videoFile;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<RecipeCrudCubit>();
    _titleController = TextEditingController(text: _cubit.state.recipe.title);
    _descriptionController = TextEditingController(
      text: _cubit.state.recipe.description,
    );
    _categoryController = TextEditingController();

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
    _initializeCubit();
  }

  Future<void> _initializeCubit() async {
     _listCategories =await _categories( "", 1, 100, );
    await _cubit.init(_cubit.state.recipe);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    _categoryController = TextEditingController();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final File? image = await MediaPicker.pickImage();
    if (image != null) {
      final url = await _fileUpload.uploadFile(image);
      if (url.isNotEmpty) {
        setState(() {
          _imageFile = image;
        });

        _cubit.updateRecipe(_cubit.state.recipe.copyWith(imageUrl: url));
      }
    }
  }

  Future<void> _pickVideo() async {
    final File? video = await MediaPicker.pickVideo();
    if (video != null) {
      final url = await _fileUpload.uploadFile(video);
      if (url.isNotEmpty) {
        setState(() {
          _videoFile = video;
        });

        _cubit.updateRecipe(_cubit.state.recipe.copyWith(videoUrl: url));
      }
    }
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green.shade300, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeCrudCubit, RecipeCrudState>(
      bloc: _cubit,
      builder: (context, state) {
        final recipe = state.recipe;
        final mediaPages = [
          MediaPickerCard(
            isImage: true,
            file: _imageFile,
            url: recipe.imageUrl,
            onPick: _pickImage,
          ),
          MediaPickerCard(
            isImage: false,
            file: _videoFile,
            url: recipe.videoUrl,
            onPick: _pickVideo,
          ),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: mediaPages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: mediaPages[index],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  mediaPages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: _currentPage == index ? 10.0 : 8.0,
                    height: _currentPage == index ? 10.0 : 8.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _titleController,
              labelText: 'Title *',
              hintText: 'Recipe title',
              borderRadius: 10,
              focusedBorderColor: Colors.green[300],
              enableClear: true,
              maxLines: 1,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a recipe title';
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              onFocusLost: (value) {
                _cubit.updateRecipe(recipe.copyWith(title: value));
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              labelText: 'Description',
              hintText: 'Write something',
              borderRadius: 10,
              focusedBorderColor: Colors.green[300],
              enableClear: true,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                _cubit.updateRecipe(
                  recipe.copyWith(description: value),
                );
              },
              // onFocusLost: (value) {
              //   print(value);
              //   _cubit.updateRecipe(recipe.copyWith(description: value));
              // },
            ),
            const SizedBox(height: 16),
            CustomDropdownSearch<String>(
              label: "Cook time *",
              items: (filter, props) => AppConstants.cookTimes,
              type: DropdownType.bottomSheet,
              itemAsString: (item) => item.toString(),
              selectedItem: recipe.cookTime != null
                  ? AppConstants.cookTimes.firstWhere(
                      (t) => TimeParser.fromString(t) == recipe.cookTime,
                      orElse: () => AppConstants.cookTimes.first,
                    )
                  : null,
              onChanged: (value) {
                if (value != null) {
                  _cubit.updateRecipe(
                    recipe.copyWith(cookTime: TimeParser.fromString(value)),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            CustomDropdownSearch<String>(
              label: "Prep time *",
              items: (filter, props) => AppConstants.prepTimes,
              type: DropdownType.bottomSheet,
              itemAsString: (item) => item.toString(),
              selectedItem: recipe.prepTime != null
                  ? AppConstants.prepTimes.firstWhere(
                      (t) => TimeParser.fromString(t) == recipe.prepTime,
                      orElse: () => AppConstants.prepTimes.first,
                    )
                  : null,
              onChanged: (value) {
                if (value != null) {
                  _cubit.updateRecipe(
                    recipe.copyWith(prepTime: TimeParser.fromString(value)),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            CustomDropdownSearch<Difficulty>(
              label: 'Difficulty',
              items: (filter, props) => AppConstants.difficulties.keys.toList(),
              type: DropdownType.menu,
              selectedItem: recipe.difficulty,
              itemAsString: (d) => AppConstants.difficulties[d] ?? "",
              onChanged: (value) {
                _cubit.updateRecipe(recipe.copyWith(difficulty: value));
              },
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomDropdownSearch<CategoryModel>.multiSelection(
                        label: 'Categories',
                        compareFn: (a, b) => a?.id == b?.id,
                        onFind: (String? filter, int page, int limit) async {
                          filter = filter ?? '';
                          return await _categories(filter, page, limit);
                        },
                        type: DropdownType.bottomSheet,
                        selectedItems:
                            _listCategories
                                ?.where(
                                  (cat) => state.categories.contains(
                                    cat.description,
                                  ),
                                )
                                .toList() ??
                            [],
                        itemAsString: (cat) => cat.description ?? '',
                        onChangedMulti: (selectedList) {
                          final selectedDescriptions = selectedList
                              .map((c) => c.description)
                              .whereType<String>()
                              .toList();

                          _cubit.setCategories(selectedDescriptions);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Nút Add category mới
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: IconButton(
                        onPressed: () => _showAddCategoryBottomSheet(context),
                        icon: Icon(
                          Icons.add_circle,
                          color: Colors.green.shade600,
                          size: 32,
                        ),
                        tooltip: 'Add new category',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: state.categories.map((categoryName) {
                        // Tìm category trong list đã load
                        final c = _listCategories?.firstWhere(
                              (cat) => cat.description == categoryName,
                          orElse: () => CategoryModel(description: categoryName),
                        );

                        final description = c?.description ?? "Unknown";
                        final iconUrl = c?.iconUrl;
                        final isNewCategory = c?.id == null;

                        return Chip(
                          label: Text(
                            description,
                            style: const TextStyle(fontSize: 13),
                          ),
                          avatar: (iconUrl ?? '').isNotEmpty
                              ? CircleAvatar(
                            backgroundImage: NetworkImage(iconUrl!),
                            radius: 14,
                          )
                              : CircleAvatar(
                            radius: 14,
                            backgroundColor: isNewCategory
                                ? Colors.orange.shade200
                                : null,
                            child: Icon(
                              Icons.category,
                              size: 16,
                              color: isNewCategory ? Colors.white : null,
                            ),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            _cubit.removeCategory(categoryName);
                          },
                          backgroundColor: isNewCategory
                              ? Colors.orange.shade50
                              : Colors.grey.shade100,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 0,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomDropdownSearch<ProvinceModel>(
                    label: "Province",
                    onFind: (String? filter, int page, int limit) async {
                      debugPrint('Loading page: $page, limit: $limit');
                      return await _province(
                        keyword: filter,
                        limit: limit,
                        page: page,
                      );
                    },
                    type: DropdownType.bottomSheet,
                    selectedItem:
                        (recipe.region != null && recipe.region!.isNotEmpty)
                        ? ProvinceModel(name: recipe.region!)
                        : null,
                    itemAsString: (p) => p.name,
                    compareFn: (a, b) => a?.code == b?.code,
                    onChanged: (province) {
                      setState(() {
                        _selectedProvince = province;
                      });
                      _cubit.updateRecipe(
                        recipe.copyWith(region: _selectedProvince?.name),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Add New Category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // TextField
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                hintText: 'Enter category name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.green.shade300,
                    width: 2,
                  ),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _cubit.addCategory(value.trim());
                  _categoryController.clear();
                  Navigator.of(sheetContext).pop();
                }
              },
            ),
            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _categoryController.clear();
                      Navigator.of(sheetContext).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final value = _categoryController.text.trim();
                      if (value.isNotEmpty) {
                        _cubit.addCategory(value);
                        _categoryController.clear();
                        Navigator.of(sheetContext).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
