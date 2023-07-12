import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:hacker_news_clone/core/contracts/data_sources/http.dart';
import 'package:hacker_news_clone/core/contracts/typedefs.dart';
import 'package:hacker_news_clone/core/models/hacker_news_item.dart';
import 'package:hacker_news_clone/core/models/response_model.dart' //
    as internal;
import 'package:hacker_news_clone/core/utils/dio_curl.dart';
import 'package:hemend_logger/hemend_logger.dart';

// final _envHttpProxy = Platform.environment['HTTP_PROXY'];

class HttpSource extends IHttpDataSource<HackerNewsItem> with LogableObject {
  factory HttpSource() {
    final dioClient = Dio(
      BaseOptions(
        baseUrl: 'https://hacker-news.firebaseio.com/v0/',
        connectTimeout: const Duration(seconds: 5),
      ),
    );
    return HttpSource._(dioClient, HackerNewsItem.fromMap);
  }

  HttpSource._(this._dioClient, this._mapper) {
    _initializeProxy(_dioClient);
    _initializeInterceptor(_dioClient);
  }

  void _initializeProxy(Dio dio) {
    // (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    //   final client = HttpClient();
    //   // if (_envHttpProxy != null) {
    //   // info('Proxy configuration found: $_envHttpProxy');
    //   client..badCertificateCallback = ((_, __, ___) => true);
    //   // ..findProxy = HttpClient.findProxyFromEnvironment;
    //   // }
    //   return client;
    // };
  }

  void _initializeInterceptor(Dio dio) {
    dio.interceptors.add(CurlLoggerDioInterceptor(logger: getChild('Curl')));
  }

  final Dio _dioClient;
  final HackerNewsItem Function(Json data) _mapper;
  @override
  Future<internal.Response<HackerNewsItem>> get(String path) async {
    try {
      final result = await _dioClient.get<Json>(path);
      final data = result.data;
      if (data == null) {
        warning('Request to path: $path resulted in null response');
        return internal.Response.unknown();
      }
      final mappedData = _mapper(data);
      return internal.Response.ok(mappedData);
    } on DioException catch (e) {
      return _onDioException(e);
    }
  }

  internal.Response<T> _onDioException<T>(DioException e) {
    final response = e.response;
    shout('Request failed\nCode:${response?.statusCode}\nResponse:\n${response?.data}');
    if (response == null || response.statusCode == null) {
      return internal.Response.unknown();
    }

    return internal.Response.error(
      response.statusCode!,
      response.statusMessage ?? '',
    );
  }

  @override
  String get loggerName => 'Http';

  @override
  Future<internal.Response<String>> getRaw(String path) async {
    try {
      final result = await _dioClient.get<String>(path);
      final data = result.data;
      if (data == null) {
        warning('Request to path: $path resulted in null response');
        return internal.Response.unknown();
      }
      return internal.Response.ok(data);
    } on DioException catch (e) {
      return _onDioException(e);
    }
  }
}
