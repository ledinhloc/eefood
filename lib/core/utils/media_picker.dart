import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/* chon Image, Video, File trong may*/
class MediaPicker{
  static Future<bool> _checkPermission(Permission permission) async{
    var status = await permission.status;
    if(status.isDenied){
      status = await permission.request();
    }

    return status.isGranted;
  }

  static Future<File?> pickImage() async{
    if(!await _checkPermission(Permission.photos)) return null;

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    return picked != null ? File(picked.path) : null;
  }

  static Future<File?> pickVideo() async{
    if(!await _checkPermission(Permission.videos)) return null;

    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    return picked != null ? File(picked.path) : null;
  }

  // static Future<File?> pickFile() async {
  //   if(!await _checkPermission(Permission.storage)) return null;
  //
  //   final result = await FilePicker.platform.pickFiles();
  //   if(result != null && result.files.single.path != null){
  //     return File(result.files.single.path!);
  //   }
  //   return null;
  // }
}