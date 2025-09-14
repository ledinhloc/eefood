import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';

class InstructionBottomSheet extends StatefulWidget {
  final Function(RecipeStepModel) onAddInstruction;

  const InstructionBottomSheet({
    Key? key,
    required this.onAddInstruction,
  }) : super(key: key);

  @override
  _InstructionBottomSheetState createState() => _InstructionBottomSheetState();
}

class _InstructionBottomSheetState extends State<InstructionBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _stepTimeController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  File? _video;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _video = File(video.path);
      });
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Instruction Step', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          const Text('Add Media (optional)', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Add Image'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.videocam),
                label: const Text('Add Video'),
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
                    icon: const Icon(Icons.close, size: 16, color: Colors.white),
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
                  child: const Icon(Icons.play_circle_fill, size: 50, color: Colors.white70),
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
                    widget.onAddInstruction(
                      RecipeStepModel(
                        stepNumber: 0,
                        instruction: _textController.text,
                        imageUrl: _image?.path,
                        videoUrl: _video?.path,
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