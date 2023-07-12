import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hacker_news_clone/core/contracts/data_sources/http.dart';
import 'package:hacker_news_clone/core/contracts/typedefs.dart';
import 'package:hacker_news_clone/core/exceptions/parser_exception.dart';
import 'package:hacker_news_clone/core/models/hacker_news_item.dart';
import 'package:hacker_news_clone/core/models/response_model.dart' //
    as internal;
import 'package:hacker_news_clone/core/utils/dio_curl.dart';
// ignore: implementation_imports
import 'package:hemend_async_log_recorder/src/go_flow/helper.dart';
import 'package:hemend_logger/hemend_logger.dart';

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
    _initializeInterceptor(_dioClient);
  }

  void _initializeInterceptor(Dio dio) {
    dio.interceptors.add(CurlLoggerDioInterceptor(logger: getChild('Curl')));
  }

  final Dio _dioClient;
  final HackerNewsItem Function(Json data) _mapper;
  final Map<int, CancelToken> _cancelTokens = {};
  CancelToken _putCancelToken(int hash) {
    final token = CancelToken();
    _cancelTokens[hash] = token;
    return token;
  }

  void _removeToken(int hash) => _cancelTokens.remove(hash);
  void _cancelConnection(int hash) {
    warning('canceling request with hash $hash');
    _cancelTokens[hash]?.cancel();
  }

  internal.Response<T> unknownException<T>() => internal.Response.unknown();
  @override
  Future<internal.Response<HackerNewsItem>> get(String path) async {
    return asyncFlow<internal.Response<HackerNewsItem>>(
      (deffer) async {
        deffer(
          (result) async {
            _removeToken(path.hashCode);
            return result;
          },
        );
        deffer(
          (result) async {
            final exception = result.exception;
            if (exception is DioException) {
              return (
                result: _onDioException<HackerNewsItem>(exception),
                exception: null,
              );
            }
            if (exception is ParserException) {
              severe(result);
            }
            return result;
          },
        );
        final result = await _dioClient.get<Json>(
          path,
          cancelToken: _putCancelToken(path.hashCode),
        );
        final data = result.data;
        if (data == null) {
          warning('Request to path: $path resulted in null response');
          return (result: unknownException<HackerNewsItem>(), exception: null);
        }
        finest(jsonEncode(data));
        final mappedData = _mapper(data);

        return (result: internal.Response.ok(mappedData), exception: null);
      },
    ).then(
      (value) => value?.result ?? unknownException(),
    );
  }

  @override
  Future<internal.Response<String>> getRaw(String path) async {
    return asyncFlow<internal.Response<String>>(
      (deffer) async {
        deffer(
          (result) async {
            _removeToken(path.hashCode);
            return result;
          },
        );
        deffer(
          (result) async {
            final exception = result.exception;
            if (exception is DioException) {
              return (
                result: _onDioException<String>(exception),
                exception: null,
              );
            }
            return result;
          },
        );
        final result = await _dioClient.get<String>(
          path,
          cancelToken: _putCancelToken(path.hashCode),
        );
        final data = result.data;
        if (data == null) {
          warning('Request to path: $path resulted in null response');
          return (result: unknownException<String>(), exception: null);
        }
        return (result: internal.Response.ok(data), exception: null);
      },
    ).then(
      (value) => value?.result ?? unknownException(),
    );
  }

  internal.Response<T> _onDioException<T>(DioException e) {
    final response = e.response;
    shout(
      '''
Request failed
  Code: `${response?.statusCode}`
  Response:
    ${response?.data}
''',
    );
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
  Future<void> discardRequestByHash(int hash) async => _cancelConnection(hash);
}
