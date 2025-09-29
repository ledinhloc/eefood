import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/* chon Image, Video, File trong may*/
class MediaPicker{
  static Future<bool> _checkPermission(Permission permission) async{
    // Android 13 trở lên
    if(Platform.isAndroid && (await _getSdkInt()) >=33) {
      var status = await permission.status;
      if(status.isDenied){
        status = await permission.request();
      }
      return status.isGranted;
    }
    else {
      // Android 12 trở xuống
      var status = await Permission.storage.status;
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
      return status.isGranted;
    }
    
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

  static Future<int> _getSdkInt() async {
    final sdkInt = await DeviceInfoPlugin().androidInfo.then((info) => info.version.sdkInt);
    return sdkInt;
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