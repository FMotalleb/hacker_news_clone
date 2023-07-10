import 'package:dio/dio.dart';
import 'package:hacker_news_clone/core/contracts/data_sources/http.dart';
import 'package:hacker_news_clone/core/contracts/typedefs.dart';
import 'package:hacker_news_clone/core/models/response_model.dart' //
    as internal;

class HttpSource<T> extends IHttpDataSource<T> {
  HttpSource._(this._dioClient, this._mapper);
  final Dio _dioClient;
  final T Function(Json data) _mapper;
  factory HttpSource(
    Uri basePath,
  ) {
    final dioClient = Dio(
      BaseOptions(
        baseUrl: basePath.toString(),
      ),
    );
    return HttpSource._(dioClient, (data) => )
  }
  @override
  Future<internal.Response<T>> get(Uri path) async {
    try {
      final result = await _dioClient.getUri<Json>(path);
      final data = result.data;
      if (data == null) {
        return internal.Response.unknown();
      }
      final mappedData = _mapper(data);
      return internal.Response.ok(mappedData);
    } on DioException catch (e) {
      final response = e.response;
      if (response == null || response.statusCode == null) {
        return internal.Response.unknown();
      }
      return internal.Response.error(
        response.statusCode!,
        response.statusMessage ?? '',
      );
    }
  }
}
