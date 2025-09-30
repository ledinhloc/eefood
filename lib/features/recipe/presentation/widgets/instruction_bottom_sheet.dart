import 'dart:io';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/core/utils/media_picker.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';

class InstructionBottomSheet extends StatefulWidget {
  final Function(RecipeStepModel, {int? index}) onSaveInstruction;
  final RecipeStepModel? editingInstruction;
  final int? editingIndex;

  const InstructionBottomSheet({
    Key? key,
    required this.onSaveInstruction,
    this.editingInstruction,
    this.editingIndex,
  }) : super(key: key);

  @override
  _InstructionBottomSheetState createState() => _InstructionBottomSheetState();
}

class _InstructionBottomSheetState extends State<InstructionBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _stepTimeController = TextEditingController();
  final _fileUpload = getIt<FileUploader>();
  File? _image;
  File? _video;
  String? urlImage;
  String? urlVideo;

  @override
  void initState() {
    super.initState();
    if (widget.editingInstruction != null) {
      final step = widget.editingInstruction!;
      _textController.text = step.instruction ?? '';
      if (step.stepTime != null) {
        _stepTimeController.text = step.stepTime.toString();
      }
      if (step.imageUrl != null) {
        _image = File(step.imageUrl!);
      }
      if (step.videoUrl != null) {
        _video = File(step.videoUrl!);
      }
    }
  }

  Future<void> _pickImage() async {
    final File? image = await MediaPicker.pickImage();
    if (image != null) {
      final url = await _fileUpload.uploadFile(image);
      if (url.isNotEmpty) {
        setState(() {
          urlImage = url;
          _image = image;
        });
      }
    }
  }

  Future<void> _pickVideo() async {
    final File? video = await MediaPicker.pickVideo();
    if (video != null) {
      final url = await _fileUpload.uploadFile(video);
      if (url.isNotEmpty) {
        setState(() {
          urlVideo = url;
          _video = video;
        });
      }
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  void _removeVideo() {
    setState(() {
      _video = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Instruction Step',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Instruction',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _stepTimeController,
            decoration: const InputDecoration(
              labelText: 'Step Time (minutes)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          const Text(
            'Add Media (optional)',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 28, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("Add image", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _pickVideo,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam, size: 28, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("Add video", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_image != null) ...[
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                    onPressed: _removeImage,
                  ),
                ),
              ],
            ),
          ],
          if (_video != null) ...[
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(_video!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const Icon(
                    Icons.play_circle_fill,
                    size: 50,
                    color: Colors.white70,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _removeVideo,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    widget.onSaveInstruction(
                      RecipeStepModel(
                        stepNumber: widget.editingInstruction!.stepNumber,
                        instruction: _textController.text,
                        imageUrl: urlImage,
                        videoUrl: urlVideo,
                        stepTime: int.tryParse(_stepTimeController.text),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Step'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
