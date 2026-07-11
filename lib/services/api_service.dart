import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tick_it/models/quote_model.dart';

class ApiService {
  static const String _quoteUrl = 'https://dummyjson.com/quotes/random';

  Future<QuoteModel> fetchRandomQuote() async {
    try {
      final response = await http.get(Uri.parse(_quoteUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return QuoteModel.fromJson(data);
      } else {
        throw Exception('Failed to load quote. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: Failed to fetch quote ($e)');
    }
  }
}
