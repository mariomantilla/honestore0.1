import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:honestore/secrets.env.dart';

class Airtable {

  static const String host = 'api.airtable.com';
  static const String base = '/v0/appft8jvxQwHFoE4f/';

  Uri _buildUri(String resource, Map<String, dynamic> params) => Uri.https(
      'api.airtable.com',
      '/v0/appft8jvxQwHFoE4f/' + resource,
      params
  );

  Future<http.Response> get(String resource, params) async => await http.get(
    _buildUri(resource, params),
    headers: {
      'Authorization': 'Bearer ' + airTableKey
    }
  );

  Future<List> getRecords(String resource, [params]) async {
    final response = await get(resource, params);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['records'];
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load products');
    }

  }

}