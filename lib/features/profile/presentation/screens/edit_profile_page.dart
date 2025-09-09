import 'dart:io';

import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/media_picker.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/core/widgets/user_avatar.dart';
import 'package:eefood/features/auth/data/models/UserModel.dart';
import 'package:eefood/features/profile/domain/usecases/profile_usecase.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/file_upload.dart';
import '../../../auth/domain/entities/user.dart';

class EditProfilePage extends StatefulWidget {
  final User user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController roleController;
  late TextEditingController dobController;
  late TextEditingController genderController;
  late TextEditingController streetController;
  late TextEditingController cityController;
  File? _avatarFile;
  ImageProvider? imageProvider ;

  final ImagePicker _picker = ImagePicker();
  final UpdateProfile _updateProfile = getIt<UpdateProfile>();
  final _fileUploader = getIt<FileUploader>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    usernameController = TextEditingController(text: widget.user.username);
    emailController = TextEditingController(text: widget.user.email);
    roleController = TextEditingController(text: widget.user.role);
    dobController = TextEditingController(text: widget.user.dob);
    genderController = TextEditingController(text: widget.user.gender);
    streetController = TextEditingController(text: widget.user.address?.street);
    cityController = TextEditingController(text: widget.user.address?.city);
    if(widget.user.avatarUrl!=null){
      imageProvider = NetworkImage(widget.user.avatarUrl!);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    usernameController.dispose();
    emailController.dispose();
    roleController.dispose();
    dobController.dispose();
    genderController.dispose();
    streetController.dispose();
    cityController.dispose();
    super.dispose();
  }

  //chon anh
  Future<void> _handleChangeAvatar() async {
    final pickedFile = await MediaPicker.pickImage();
    if (pickedFile != null) {
      setState(() {
        _avatarFile = pickedFile;
        imageProvider = FileImage(_avatarFile!);
      });
    }
  }

  //chon ngay sinh
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(dobController.text) ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = picked.toIso8601String().split("T").first;
      });
    }
  }

  //luu thay doi
  Future<void> _onSave() async {
    String? urlImage;
    if(_avatarFile!=null){
      urlImage = await _fileUploader.uploadFile(_avatarFile!);
    }

    final result = await _updateProfile(
        UserModel(
            id: widget.user.id,
            username: usernameController.text,
            email: emailController.text,
            dob: dobController.text,
            gender: genderController.text,
            address: AddressModel(city: cityController.text, street: streetController.text),
            avatarUrl: urlImage,
        ));

    if(!mounted) return;
    if (result.isSuccess) {
      showCustomSnackBar(context, 'Đã lưu thông tin thành công');
      Navigator.pop(context, true);
    }else{
      showCustomSnackBar(context, 'Lưu thất bại!', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_avatarFile!=null){
      imageProvider = FileImage(_avatarFile!);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit profile'),
        actions: [
          IconButton(onPressed: _onSave, icon: const Icon(Icons.check)),
        ],
      ),
      body:SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                UserAvatar(username: widget.user.username, imageProvider: imageProvider,radius: 60,),
                Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey[300]!, // viền màu xám nhạt
                      width: 2,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: _handleChangeAvatar,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white, // nền xám nhạt
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.red,
                        size: 15,
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField("Username", usernameController),
            _buildTextField("Email", emailController),
            // _buildTextField("Date of Birth", dobController),
            TextFormField(
              controller: dobController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Date of Birth",
                suffixIcon: Icon(Icons.calendar_month_sharp),
              ),
              onTap: _pickDate,
            ),
            // _buildTextField("Gender", genderController),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: genderController.text,
              decoration: const InputDecoration(labelText: "Gender"),
              items: const [
                DropdownMenuItem(value: "MALE", child: Text("MALE")),
                DropdownMenuItem(value: "FEMALE", child: Text("FEMALE")),
                DropdownMenuItem(value: "OTHER", child: Text("OTHER")),
              ],
              onChanged: (value) {
                setState(() {
                  genderController.text = value?? "MALE";
                });
              },
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Address",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            _buildTextField("Street", streetController),
            _buildTextField("City", cityController),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
