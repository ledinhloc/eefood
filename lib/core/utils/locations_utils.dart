import 'package:eefood/features/chatbot/data/models/location_info_request.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationUtils {
  static bool _permissionChecked = false;

  static Future<void> _ensurePermission() async {
    if (_permissionChecked) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service chưa bật');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Quyền vị trí bị từ chối');
    }

    _permissionChecked = true;
  }

  static Future<Position> getCurrentPosition() async {
    await _ensurePermission();

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static String _normalizeProvince(String? rawProvince) {
    if (rawProvince == null || rawProvince.isEmpty) {
      return 'Không xác định';
    }

    String province = rawProvince.trim();

    // Bỏ tiền tố
    province = province
        .replaceFirst(RegExp(r'^Tỉnh\s+', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^Thành phố\s+', caseSensitive: false), '');

    // Chuẩn hóa khoảng trắng
    province = province.replaceAll(RegExp(r'\s+'), ' ');

    // Special cases
    final specialCases = {
      'Ho Chi Minh City': 'Hồ Chí Minh',
      'TP. Ho Chi Minh': 'Hồ Chí Minh',
      'Thua Thien Hue': 'Thừa Thiên-Huế',
      'Thừa Thiên Huế': 'Thừa Thiên-Huế',
      'Hue': 'Thừa Thiên-Huế',
      'Huế': 'Thừa Thiên-Huế',
    };

    if (specialCases.containsKey(province)) {
      return specialCases[province]!;
    }

    return province;
  }

  static Future<String> getProvinceFromPosition(double lat, double lon) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

    if (placemarks.isEmpty) {
      throw Exception('Không xác định được địa chỉ');
    }

    final place = placemarks.first;

    return _normalizeProvince(place.administrativeArea);
  }

  static Future<LocationInfoRequest> getCurrentLocationInfo() async {
    final position = await getCurrentPosition();
    final province = await getProvinceFromPosition(
      position.latitude,
      position.longitude,
    );

    return LocationInfoRequest(
      latitude: position.latitude,
      longitude: position.longitude,
      province: province,
    );
  }
}
