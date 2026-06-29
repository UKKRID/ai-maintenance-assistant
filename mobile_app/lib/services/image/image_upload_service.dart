import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../services/api/api_client.dart';

class ImageUploadService {
  final ApiClient _apiClient;

  ImageUploadService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> uploadImage(File file, {String folder = 'general'}) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${_apiClient.baseUrl}/api/upload/upload?folder=$folder'),
      );

      // Add authorization header
      if (_apiClient.token != null) {
        request.headers['Authorization'] = 'Bearer ${_apiClient.token}';
      }

      // Determine mime type
      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(mimeType),
      );

      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = _parseResponse(response.body);
        return data;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Upload error: ${e.toString()}');
    }
  }

  Map<String, dynamic> _parseResponse(String body) {
    // Simple JSON parsing
    final Map<String, dynamic> result = {};
    final cleaned = body.replaceAll('{', '').replaceAll('}', '').replaceAll('"', '');
    final pairs = cleaned.split(',');
    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        result[parts[0].trim()] = parts[1].trim();
      }
    }
    return result;
  }

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '${_apiClient.baseUrl}$path';
  }
}
