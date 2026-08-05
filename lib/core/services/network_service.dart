import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'logger_service.dart';

class NetworkService {
  NetworkService._();

  static final http.Client _client = http.Client();

  static http.Client get client => _client;

  static Future<bool> get isConnected async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    if (!await isConnected) throw const SocketException('No Internet Connection');
    LoggerService.debug('GET -> $url');
    return await _client.get(url, headers: headers).timeout(AppConfig.apiTimeout);
  }

  static Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    if (!await isConnected) throw const SocketException('No Internet Connection');
    LoggerService.debug('POST -> $url');
    return await _client.post(url, headers: headers, body: body).timeout(AppConfig.apiTimeout);
  }

  static Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body}) async {
    if (!await isConnected) throw const SocketException('No Internet Connection');
    LoggerService.debug('PUT -> $url');
    return await _client.put(url, headers: headers, body: body).timeout(AppConfig.apiTimeout);
  }

  static Future<http.Response> delete(Uri url, {Map<String, String>? headers}) async {
    if (!await isConnected) throw const SocketException('No Internet Connection');
    LoggerService.debug('DELETE -> $url');
    return await _client.delete(url, headers: headers).timeout(AppConfig.apiTimeout);
  }
}