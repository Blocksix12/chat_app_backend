class ResponseModel<T> {
  final bool success;
  final String message;
  final T? data;
  final dynamic errors;

  ResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ResponseModel.fromMap(
    Map<String, dynamic> map, {
    T Function(dynamic json)? fromJsonT,
  }) {
    return ResponseModel<T>(
      success: map['success'] as bool? ?? false,
      message: map['message'] as String? ?? '',
      data: map['data'] != null && fromJsonT != null
          ? fromJsonT(map['data'])
          : map['data'] as T?,
      errors: map['errors'],
    );
  }

  Map<String, dynamic> toMap({dynamic Function(T value)? toJsonT}) {
    return {
      'success': success,
      'message': message,
      if (data != null)
        'data': toJsonT != null ? toJsonT(data as T) : data,
      if (errors != null) 'errors': errors,
    };
  }
}
