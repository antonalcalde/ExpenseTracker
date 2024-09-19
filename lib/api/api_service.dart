import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<List<dynamic>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<Map<String, dynamic>> addCategory(String title) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': title}),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add category');
    }
  }

  Future<Map<String, dynamic>> updateCategory(int id, {String? title, int? entries, double? totalAmount}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/categories/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': title,
        'entries': entries,
        'total_amount': totalAmount,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update category');
    }
  }

  Future<void> deleteCategory(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/categories/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete category');
    }
  }
}
