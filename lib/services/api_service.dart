import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class ApiService {
  // Use 127.0.0.1 for Chrome/Web.
  // (Use 10.0.2.2 ONLY if you switch to an Android Emulator later)
  static const String baseUrl = 'http://10.241.12.127:8000/api';

  // Fetch all articles
  Future<List<Article>> getArticles() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/articles'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // This will catch timeout or "Connection Refused"
      throw Exception('Connection failed: $e');
    }
  }

  // Fetch articles filtered by category
  Future<List<Article>> getArticlesByCategory(String category) async {
    try {
      // If category is 'All', just get everything
      if (category == 'All') return getArticles();

      final response = await http
          .get(Uri.parse('$baseUrl/articles?category=$category'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }
}
