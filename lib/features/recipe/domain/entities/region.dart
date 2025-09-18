class Province{
  final String code;
  final String name;
  final String type;

   Province({required this.code, required this.name, required this.type});
}

class Ward {
  final String code;
  final String name;
  final String type;
  final String provinceCode;

  Ward({
    required this.code,
    required this.name,
    required this.type,
    required this.provinceCode,
  });

}