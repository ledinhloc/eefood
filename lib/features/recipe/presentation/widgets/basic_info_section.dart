import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:eefood/core/constants/app_constants.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/convert_time.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/core/utils/media_picker.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/data/models/region_model.dart';
import 'package:eefood/features/recipe/domain/entities/recipe.dart';
import 'package:eefood/features/recipe/domain/usecases/recipe_usecases.dart';
import 'package:eefood/features/recipe/presentation/widgets/custom_dropdown.dart';
import 'package:eefood/features/recipe/presentation/widgets/media_picker_card.dart';
import 'package:flutter/material.dart';

class BasicInfoSection extends StatefulWidget {
  final RecipeModel recipe;
  final VoidCallback onRecipeUpdated;

  const BasicInfoSection({
    Key? key,
    required this.recipe,
    required this.onRecipeUpdated,
  }) : super(key: key);

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

  ProvinceModel? _selectedProvince;
  WardModel? _selectedWard;

  File? _imageFile;
  File? _videoFile;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe.title);
    _descriptionController = TextEditingController(
      text: widget.recipe.description,
    );
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final File? image = await MediaPicker.pickImage();
    if (image != null) {
      final url = await _fileUpload.uploadFile(image);
      if (url.isNotEmpty) {
        setState(() {
          _imageFile = image;
          widget.recipe.imageUrl = url;
        });
        widget.onRecipeUpdated();
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
          widget.recipe.videoUrl = url;
        });
        widget.onRecipeUpdated();
      }
    }
  }

  String convertRegion(ProvinceModel pm, WardModel wm) {
    return pm.name.toString() + wm.name.toString();
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
    final mediaPages = [
      MediaPickerCard(
        isImage: true,
        file: _imageFile,
        url: widget.recipe.imageUrl,
        onPick: _pickImage,
      ),
      MediaPickerCard(
        isImage: false,
        file: _videoFile,
        url: widget.recipe.videoUrl,
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
          onChanged: (value) {
            widget.recipe.title = value;
            widget.onRecipeUpdated();
          },
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
          onChanged: (value) {
            widget.recipe.description = value;
            widget.onRecipeUpdated();
          },
        ),
        const SizedBox(height: 16),
        CustomDropdownSearch<String>(
          label: "Cook time *",
          items: (String? filter, _) {
            final q = (filter ?? '').trim();
            if (q.isEmpty) {
              return AppConstants.cookTimes;
            }
            return AppConstants.cookTimes
                .where((e) => e.toLowerCase().contains(q.toLowerCase()))
                .toList();
          },
          type: DropdownType.bottomSheet,
          selectedItem: widget.recipe.cookTime != null
              ? AppConstants.cookTimes.firstWhere(
                  (t) => TimeParser.fromString(t) == widget.recipe.cookTime,
                  orElse: () => AppConstants.cookTimes.first,
                )
              : null,
          onChanged: (value) {
            if (value != null) {
              widget.recipe.cookTime = TimeParser.fromString(value);
              widget.onRecipeUpdated();
            }
          },
        ),
        const SizedBox(height: 16),
        CustomDropdownSearch<String>(
          label: "Prep time *",
          items: (String? filter, _) {
            final q = (filter ?? '').trim();
            if (q.isEmpty) {
              return AppConstants.prepTimes;
            }
            return AppConstants.prepTimes
                .where((e) => e.toLowerCase().contains(q.toLowerCase()))
                .toList();
          },
          type: DropdownType.bottomSheet,
          selectedItem: widget.recipe.prepTime != null
              ? AppConstants.prepTimes.firstWhere(
                  (t) => TimeParser.fromString(t) == widget.recipe.prepTime,
                  orElse: () => AppConstants.prepTimes[0],
                )
              : null,
          onChanged: (value) {
            if (value != null) {
              widget.recipe.prepTime = TimeParser.fromString(value);
              widget.onRecipeUpdated();
            }
          },
        ),
        const SizedBox(height: 16),
        CustomDropdownSearch<Difficulty>(
          label: 'Difficulty',
          items: (String? filter, _) {
            return AppConstants.difficulties.keys.toList();
          },
          type: DropdownType.menu,
          selectedItem: widget.recipe.difficulty,
          itemAsString: (d) => AppConstants.difficulties[d] ?? "",
          onChanged: (value) {
            widget.recipe.difficulty = value;
            widget.onRecipeUpdated();
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomDropdownSearch<ProvinceModel>(
                label: "Province",
                items: (String? filter, LoadProps? loadProps) async {
                  final skip = loadProps?.skip ?? 0;
                  final take = loadProps?.take ?? 10;
                  final page = (skip ~/ take) + 1;
                  return await _province(
                    keyword: filter,
                    limit: take,
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
                  widget.onRecipeUpdated();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomDropdownSearch<WardModel>(
                label: "Ward",
                items: (String? filter, LoadProps? loadProps) async {
                  if (_selectedProvince == null) return <WardModel>[];
                  final skip = loadProps?.skip ?? 0;
                  final take = loadProps?.take ?? 10;
                  final page = (skip ~/ take) + 1;
                  return await _ward(
                    _selectedProvince!.code,
                    keyword: filter,
                    limit: take,
                    page: page,
                  );
                },
                type: DropdownType.bottomSheet,
                selectedItem: _selectedWard,
                itemAsString: (w) => w.name,
                compareFn: (a, b) => a?.code == b?.code,
                onChanged: (ward) {
                  setState(() => _selectedWard = ward);
                  widget.recipe.region = convertRegion(
                    _selectedProvince!,
                    _selectedWard!,
                  );
                  widget.onRecipeUpdated();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
