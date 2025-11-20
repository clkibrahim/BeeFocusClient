import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import 'subject_model.dart';

class SubjectsApi {
  SubjectsApi({Dio? dio}) : _dio = dio ?? createDio();

  final Dio _dio;

  Future<List<Subject>> fetchAll() async {
    final res = await _dio.get('/api/subjects');
    return _toList(res.data);
  }

  Future<List<Subject>> fetchByCategory(String category) async {
    final res = await _dio.get('/api/subjects/category/$category');
    return _toList(res.data);
  }

  Future<List<Subject>> fetchByField(String field) async {
    final res = await _dio.get('/api/subjects/field/$field');
    return _toList(res.data);
  }

  List<Subject> _toList(dynamic data) {
    if (data is List) {
      return data
          .map((e) => Subject.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw const FormatException('Subjects response is not a list');
  }
}
