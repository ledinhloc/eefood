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
//format time
String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));

  if (duration.inHours > 0) {
    return '$hours:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}