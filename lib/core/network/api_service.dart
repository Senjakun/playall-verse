import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'package:playall_verse/shared/models/content_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> _get(String endpoint, {Map<String, String>? params}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint').replace(queryParameters: params);
    try {
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      print('API Error: ${response.statusCode} - ${response.body}');
      throw Exception('HTTP ${response.statusCode}');
    } catch (e) {
      print('Network Error: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
    try {
      final response = await http.post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Content
  Future<({List<ContentModel> content, PaginationModel pagination})> getContent({
    required String type,
    int page = 1,
    String? search,
    String? genre,
    String? status,
  }) async {
    final params = <String, String>{
      'type': type,
      'page': page.toString(),
      'limit': AppConstants.pageSize.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (genre != null) 'genre': genre,
      if (status != null) 'status': status,
    };
    final data = await _get(AppConstants.contentEndpoint, params: params);
    final items = (data['content'] as List? ?? [])
        .map((e) => ContentModel.fromJson(e))
        .toList();
    final pagination = PaginationModel.fromJson(data['pagination'] ?? {});
    return (content: items, pagination: pagination);
  }

  Future<ContentModel?> getContentDetail(int id) async {
    final data = await _get(AppConstants.contentEndpoint, params: {'id': id.toString()});
    final item = data['content'];
    if (item == null) return null;
    return ContentModel.fromJson(item is List ? item.first : item);
  }

  Future<List<EpisodeModel>> getEpisodes(int contentId) async {
    final data = await _get(AppConstants.episodesEndpoint, params: {'content_id': contentId.toString()});
    return (data['episodes'] as List? ?? []).map((e) => EpisodeModel.fromJson(e)).toList();
  }

  // Auth
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _post('${AppConstants.authEndpoint}?action=login', {
      'email': email,
      'password': password,
    });
    if (res['token'] != null) setToken(res['token']);
    return res;
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    return await _post('${AppConstants.authEndpoint}?action=register', {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> getMe() async {
    return await _get('${AppConstants.authEndpoint}?action=me');
  }

  // Bookmarks
  Future<List<ContentModel>> getBookmarks() async {
    final data = await _get(AppConstants.bookmarksEndpoint);
    return (data['bookmarks'] as List? ?? []).map((e) => ContentModel.fromJson(e)).toList();
  }

  Future<bool> toggleBookmark(int contentId) async {
    final res = await _post(AppConstants.bookmarksEndpoint, {'content_id': contentId});
    return res['bookmarked'] == true;
  }

  // History
  Future<void> addHistory(int contentId, {int? episodeNumber}) async {
    await _post(AppConstants.historyEndpoint, {
      'content_id': contentId,
      if (episodeNumber != null) 'episode_number': episodeNumber,
    });
  }

  Future<List<ContentModel>> getHistory() async {
    final data = await _get(AppConstants.historyEndpoint);
    return (data['history'] as List? ?? []).map((e) => ContentModel.fromJson(e)).toList();
  }
}
