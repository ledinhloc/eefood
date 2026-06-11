/*
  validate dữ lieu
 */


//kiem tra email
bool isValidEmail(String email) {
  final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegExp.hasMatch(email);
}

String getLiveKitWsUrl(String baseUrl) {
  final uri = Uri.parse(baseUrl);

  final isHttps = uri.scheme == 'https';

  return Uri(
    scheme: isHttps ? 'wss' : 'ws',
    host: isHttps ? 'livekit.${uri.host}' : uri.host,
    port: isHttps ? null : 7880,
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