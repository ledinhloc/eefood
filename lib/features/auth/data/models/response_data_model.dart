class ResponseDataModel<T> {
  final int status;
  final String message;
  final T? data;

  ResponseDataModel({
    required this.status,
    required this.message,
    this.data
  });

  factory ResponseDataModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    return ResponseDataModel<T>(
      status: json['status'] as int,
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value)? toJsonT) {
    final Map<String, dynamic> result = {
      'status': status,
      'message': message,
    };

    if (data != null && toJsonT != null) {
      result['data'] = toJsonT(data as T);
    }

    return result;
  }
}