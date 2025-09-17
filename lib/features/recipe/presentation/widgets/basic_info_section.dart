import 'dart:io';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/core/utils/media_picker.dart';
import 'package:eefood/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/domain/entities/recipe.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final _fileUpload = getIt<FileUploader>();
  final List<String> _cookTimes = [
    '5 min',
    '10 min',
    '15 min',
    '20 min',
    '30 min',
    '45 min',
    '1 hour',
    '1 hour 30 min',
    '2 hours',
    '2+ hours',
  ];
  final List<String> _prepTimes = [
    '5 min',
    '10 min',
    '15 min',
    '20 min',
    '30 min',
    '45 min',
    '1 hour',
  ];
  final Map<Difficulty, String> _difficulties = {
    Difficulty.EASY: 'Easy',
    Difficulty.MEDIUM: 'Medium',
    Difficulty.HARD: 'Hard',
  };
  final List<String> _regions = [
    'Vietnam',
    'Asian',
    'European',
    'North American',
    'South American',
    'African',
    'Other',
  ];

  File? _imageFile;
  File? _videoFile;
  final PageController _pageController = PageController(viewportFraction: 0.9);
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

  int _parseTime(String value) {
    int minutes = 0;
    if (value.contains('hour')) {
      final parts = value.split(' ');
      for (int i = 0; i < parts.length; i++) {
        if (parts[i] == 'hour' || parts[i] == 'hours') {
          minutes += int.parse(parts[i - 1]) * 60;
        } else if (parts[i] == 'min') {
          minutes += int.parse(parts[i - 1]);
        }
      }
    } else {
      minutes = int.parse(value.replaceAll(' min', ''));
    }
    if (value == '2+ hours') minutes = 120;
    return minutes;
  }

  Widget _buildMediaPage(bool isImage) {
    final file = isImage ? _imageFile : _videoFile;
    final url = isImage ? widget.recipe.imageUrl : widget.recipe.videoUrl;
    final hasMedia = file != null || (url != null && url.isNotEmpty);

    return GestureDetector(
      onTap: isImage ? _pickImage : _pickVideo,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: hasMedia
            ? Stack(
                fit: StackFit.expand,
                children: [
                  if (file != null)
                    Image.file(file, fit: BoxFit.cover)
                  else if (url != null)
                    Image.network(url, fit: BoxFit.cover),
                  if (!isImage)
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 50,
                        color: Colors.white70,
                      ),
                    ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isImage ? Icons.add_photo_alternate : Icons.videocam,
                      size: 40,
                      color: Colors.grey,
                    ),
                    Text(
                      isImage ? 'Add recipe cover image' : 'Add recipe video',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
      ),
    );
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
      _buildMediaPage(true), // Image
      _buildMediaPage(false), // Video
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
                child: mediaPages[index]);
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
        DropdownButtonFormField<String>(
          value: widget.recipe.cookTime != null
              ? _cookTimes.firstWhere(
                  (t) => _parseTime(t) == widget.recipe.cookTime,
                  orElse: () => _cookTimes[0],
                )
              : null,
          decoration: _dropdownDecoration('Cook time *'),
          dropdownColor: Colors.white,
          items: _cookTimes.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.recipe.cookTime = _parseTime(value);
              widget.onRecipeUpdated();
            }
          },
          validator: (value) {
            if (value == null) {
              return 'Please select cook time';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: widget.recipe.prepTime != null
              ? _prepTimes.firstWhere(
                  (t) => _parseTime(t) == widget.recipe.prepTime,
                  orElse: () => _prepTimes[0],
                )
              : null,
          decoration: _dropdownDecoration('Prep time'),
          dropdownColor: Colors.white,
          items: _prepTimes.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.recipe.prepTime = _parseTime(value);
              widget.onRecipeUpdated();
            }
          },
          validator: (value) {
            if (value == null) {
              return 'Please select prep time';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<Difficulty>(
          value: widget.recipe.difficulty,
          decoration: _dropdownDecoration('Difficulty'),
          dropdownColor: Colors.white,
          items: _difficulties.entries.map((entry) {
            return DropdownMenuItem<Difficulty>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            widget.recipe.difficulty = value;
            widget.onRecipeUpdated();
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: widget.recipe.region,
          decoration: _dropdownDecoration('Region'),
          dropdownColor: Colors.white,
          items: _regions.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (value) {
            widget.recipe.region = value;
            widget.onRecipeUpdated();
          },
        ),
      ],
    );
  }
}
