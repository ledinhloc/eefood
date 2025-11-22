/*
  validate dữ lieu
 */


//kiem tra email
bool isValidEmail(String email) {
  final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegExp.hasMatch(email);
}

String getLiveKitWsUrl(String baseUrl, {int? wsPort}){
  Uri uri = Uri.parse(baseUrl);
  String scheme = uri.scheme == 'https' ? 'wss' : 'ws';
  int port = wsPort ?? uri.port;
  return Uri(
    scheme: scheme,
    host: uri.host,
    port: port,
    path: ''
  ).toString();
}
