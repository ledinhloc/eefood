import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,       // Số lượng dòng trong stack trace (hiển thị file/dòng code)
    errorMethodCount: 8,  // Số dòng stack trace khi có lỗi
    lineLength: 80,       // Độ rộng của đường kẻ ngang
    colors: true,         // Hiển thị màu sắc
    printEmojis: true,    // Hiện icon (e.g. 💡, ⛔)
  ),
);

//cach dung
// // 1. Log thông tin thông thường (Màu xanh dương/trắng)
// logger.i("Đã gọi hàm fetchPosts thành công");
//
// // 2. Log cảnh báo (Màu vàng)
// logger.w("Cảnh báo: User chưa đăng nhập, chỉ xem được bài viết công khai");
//
// // 3. Log lỗi (Màu đỏ) - Hiển thị chi tiết lỗi và file gây lỗi
// try {
// // code gây lỗi...
// } catch (e, stacktrace) {
// logger.e("Lỗi khi fetch API!", error: e, stackTrace: stacktrace);
// }
//
// // 4. Log cực kỳ chi tiết (Màu xám) - Dùng khi debug sâu
// logger.d("Payload gửi lên: ${jsonEncode(data)}");