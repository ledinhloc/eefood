class ProvinceModel {
  final String? code;
  final String name;
  final String? type;

  ProvinceModel({ this.code, required this.name,  this.type});

  factory ProvinceModel.fromJson(Map<String, dynamic> j) {
   
    return ProvinceModel(
      code: (j['code'] ?? j['province_code'] ?? j['ma'])?.toString() ?? '',
      name: j['name'] ?? j['province_name'] ?? '',
      type: j['type'] ?? j['province_type'] ?? '',
    );
  }
}

