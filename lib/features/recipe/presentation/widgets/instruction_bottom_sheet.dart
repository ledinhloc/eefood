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
  List<File> _images = [];
  List<File> _videos = [];
  List<String> urlImages = [];
  List<String> urlVideos = [];
  @override
  void initState() {
    super.initState();
    if (widget.editingInstruction != null) {
      final step = widget.editingInstruction!;
      _textController.text = step.instruction ?? '';
      if (step.stepTime != null) {
        _stepTimeController.text = step.stepTime.toString();
      }

      if (step.imageUrls != null && step.imageUrls!.isNotEmpty) {
        urlImages = List.from(step.imageUrls!);
        _images = step.imageUrls!.map((url) => File(url)).toList();
      }

      if (step.videoUrls != null && step.videoUrls!.isNotEmpty) {
        urlVideos = List.from(step.videoUrls!);
        _videos = step.videoUrls!.map((url) => File(url)).toList();
      }
      // if (step.imageUrl != null) {
      //   _image = File(step.imageUrl!);
      // }
      // if (step.videoUrl != null) {
      //   _video = File(step.videoUrl!);
      // }
    }
  }

  Future<void> _pickImage() async {
    final File? image = await MediaPicker.pickImage();
    if (image != null) {
      final url = await _fileUpload.uploadFile(image);
      if (url.isNotEmpty) {
        setState(() {
          if(!urlImages.contains(url)){
            urlImages.add(url);
            _images.add(image);
          }
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
          if(!urlVideos.contains(url)){
            urlVideos.add(url);
            _videos.add(video);
          }
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      if(index < _images.length){
        _images.removeAt(index);
      }
      if(index < urlImages.length){
        urlImages.removeAt(index);
      }
    });
  }

  void _removeVideo(int index) {
    setState(() {
      if(index < _videos.length){
        _videos.removeAt(index);
      }
      if(index < urlVideos.length){
        urlVideos.removeAt(index);
      }
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

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_images.length, (index) {
              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(_images[index]),
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
                      onPressed: () => _removeImage(index),
                    ),
                  ),
                ],
              );
            }),
          ),

          Column(
            children: List.generate(_videos.length, (index){
              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(_videos[index]),
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
                      onPressed: () => _removeVideo(index),
                    ),
                  ),
                ],
              );
            }),
          ),

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
                        imageUrls: urlVideos.isNotEmpty ? urlImages : null,
                        videoUrls: urlVideos.isNotEmpty ? urlVideos : null,
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
