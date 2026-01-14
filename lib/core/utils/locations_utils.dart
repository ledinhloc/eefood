import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationUtils {
  // Xin quyền và lấy vị trí hiện tại
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service chưa bật');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Quyền vị trí bị từ chối');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Quyền vị trí bị từ chối vĩnh viễn');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Lấy tỉnh/thành Việt Nam từ tọa độ
  static Future<String> getProvinceFromPosition(double lat, double lon) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

    if (placemarks.isEmpty) {
      throw Exception('Không xác định được địa chỉ');
    }

    final place = placemarks.first;

    // administrativeArea = tỉnh / thành phố
    return place.administrativeArea ?? 'Không xác định';
  }

  // Gộp: lấy cả tọa độ + tỉnh
  static Future<LocationInfo> getCurrentLocationInfo() async {
    final position = await getCurrentPosition();
    final province = await getProvinceFromPosition(
      position.latitude,
      position.longitude,
    );

    return LocationInfo(
      latitude: position.latitude,
      longitude: position.longitude,
      province: province,
    );
  }
}

class LocationInfo {
  final double latitude;
  final double longitude;
  final String province;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.province,
  });
}
