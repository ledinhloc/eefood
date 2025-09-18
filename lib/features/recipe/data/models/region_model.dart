class ProvinceModel {
  final String code;
  final String name;
  final String type;

  ProvinceModel({required this.code, required this.name, required this.type});

  factory ProvinceModel.fromJson(Map<String, dynamic> j) {
   
    return ProvinceModel(
      code: (j['code'] ?? j['province_code'] ?? j['ma'])?.toString() ?? '',
      name: j['name'] ?? j['province_name'] ?? '',
      type: j['type'] ?? j['province_type'] ?? '',
    );
  }
}

class WardModel {
  final String code;
  final String name;
  final String type;
  final String provinceCode;

  WardModel({
    required this.code,
    required this.name,
    required this.type,
    required this.provinceCode,
  });

  factory WardModel.fromJson(Map<String, dynamic> j, {String? provinceCode}) {
    return WardModel(
      code: (j['code'] ?? j['ward_code'] ?? j['ma'])?.toString() ?? '',
      name: j['name'] ?? j['ward_name'] ?? '',
      type: j['type'] ?? j['ward_type'] ?? '',
      provinceCode: provinceCode ?? (j['province_code'] ?? j['provinceCode'] ?? '')?.toString() ?? '',
    );
  }
}