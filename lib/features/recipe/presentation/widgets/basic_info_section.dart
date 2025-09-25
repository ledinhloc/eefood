import 'dart:io';
import 'package:eefood/core/constants/app_constants.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/convert_time.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/core/utils/media_picker.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:eefood/features/recipe/data/models/category_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/region_model.dart';
import 'package:eefood/features/recipe/domain/entities/recipe.dart';
import 'package:eefood/features/recipe/domain/usecases/recipe_usecases.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_cubit.dart';
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
  final PageController _pageController = PageController(viewportFraction: 0.9);

  final _fileUpload = getIt<FileUploader>();
  final Province _province = getIt<Province>();
  final Ward _ward = getIt<Ward>();
  final Categories _categories = getIt<Categories>();
  final RecipeCrudCubit _recipeCrudCubit = getIt<RecipeCrudCubit>();

  ProvinceModel? _selectedProvince;
  WardModel? _selectedWard;
  CategoryModel? _selectedCategory;

  File? _imageFile;
  File? _videoFile;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: _recipeCrudCubit.state.recipe.title,
    );
    _descriptionController = TextEditingController(
      text: _recipeCrudCubit.state.recipe.description,
    );
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateTitle);
    _descriptionController.removeListener(_updateDescription);
    _titleController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _updateTitle() {
    _recipeCrudCubit.updateRecipe(
      _recipeCrudCubit.state.recipe.copyWith(title: _titleController.text),
    );
  }

  void _updateDescription() {
    _recipeCrudCubit.updateRecipe(
      _recipeCrudCubit.state.recipe.copyWith(
        description: _descriptionController.text,
      ),
    );
  }

  Future<void> _pickImage() async {
    final File? image = await MediaPicker.pickImage();
    if (image != null) {
      final url = await _fileUpload.uploadFile(image);
      if (url.isNotEmpty) {
        final cubit = context.read<RecipeCrudCubit>();
        setState(() {
          _imageFile = image;
        });

        cubit.updateRecipe(cubit.state.recipe.copyWith(imageUrl: url));
      }
    }
  }

  Future<void> _pickVideo() async {
    final File? video = await MediaPicker.pickVideo();
    if (video != null) {
      final url = await _fileUpload.uploadFile(video);
      if (url.isNotEmpty) {
        final cubit = context.read<RecipeCrudCubit>();
        setState(() {
          _videoFile = video;
        });

        cubit.updateRecipe(cubit.state.recipe.copyWith(videoUrl: url));
      }
    }
  }

  String convertRegion(ProvinceModel pm, WardModel wm) {
    return 'Xã/phường ${wm.name} , thành phố ${pm.name}';
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
    final cubit = context.read<RecipeCrudCubit>();
    final state = context.watch<RecipeCrudCubit>().state;
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
        ),
        const SizedBox(height: 16),
        CustomDropdownSearch<String>(
          label: "Cook time *",
          items: (filter, props) => AppConstants.cookTimes,
          type: DropdownType.bottomSheet,
          selectedItem: recipe.cookTime != null
              ? AppConstants.cookTimes.firstWhere(
                  (t) => TimeParser.fromString(t) == recipe.cookTime,
                  orElse: () => AppConstants.cookTimes.first,
                )
              : null,
          onChanged: (value) {
            if (value != null) {
              cubit.updateRecipe(
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
          selectedItem: recipe.prepTime != null
              ? AppConstants.prepTimes.firstWhere(
                  (t) => TimeParser.fromString(t) == recipe.prepTime,
                  orElse: () => AppConstants.prepTimes.first,
                )
              : null,
          onChanged: (value) {
            if (value != null) {
              cubit.updateRecipe(
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
            cubit.updateRecipe(recipe.copyWith(difficulty: value));
          },
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomDropdownSearch<CategoryModel>.multiSelection(
              label: 'Categories',
              onFind: (String? filter, int page, int limit) async {
                debugPrint('Loading page: $page, limit: $limit');
                return await _categories(filter,page,limit);
              },
              type: DropdownType.menu,
              selectedItems: state.categories,
              itemAsString: (cat) => cat.description ?? '',
              onChangedMulti: (selectedList) {
                // Add or update
                for (var cat in selectedList) {
                  final idx = state.categories.indexWhere(
                    (c) => c.id == cat.id,
                  );
                  if (idx == -1) {
                    cubit.addCategory(cat);
                  } else {
                    cubit.updateCategory(idx, cat);
                  }
                }
                // Remove
                final removed = state.categories
                    .where((c) => !selectedList.any((s) => s.id == c.id))
                    .toList();
                for (var r in removed) {
                  final idx = state.categories.indexWhere((c) => c.id == r.id);
                  if (idx != -1) cubit.removeCategory(idx);
                }
              },
            ),
            Wrap(
              spacing: 6,
              runSpacing: -8,
              children: state.categories.map((c) {
                return Chip(
                  label: Text(c.description ?? ""),
                  avatar: c.iconUrl != null
                      ? CircleAvatar(backgroundImage: NetworkImage(c.iconUrl!))
                      : const CircleAvatar(
                          child: Icon(Icons.category, size: 16),
                        ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    final index = state.categories.indexWhere(
                      (cat) => cat.id == c.id,
                    );
                    if (index != -1) cubit.removeCategory(index);
                  },
                );
              }).toList(),
            ),
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
                selectedItem: _selectedProvince,
                itemAsString: (p) => p.name,
                compareFn: (a, b) => a?.code == b?.code,
                onChanged: (province) {
                  setState(() {
                    _selectedProvince = province;
                    _selectedWard = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomDropdownSearch<WardModel>(
                label: "Ward",
                onFind: (String? filter, int page, int limit) async {
                  if (_selectedProvince == null) return <WardModel>[];
                  debugPrint('Loading page: $page, limit: $limit');
                  return await _ward(
                    _selectedProvince!.code,
                    keyword: filter,
                    limit: limit,
                    page: page,
                  );
                },
                type: DropdownType.bottomSheet,
                selectedItem: _selectedWard,
                itemAsString: (w) => w.name,
                compareFn: (a, b) => a?.code == b?.code,
                onChanged: (ward) {
                  setState(() => _selectedWard = ward);
                  cubit.updateRecipe(
                    recipe.copyWith(
                      region: convertRegion(_selectedProvince!, _selectedWard!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
