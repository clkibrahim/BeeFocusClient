import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/subject_model.dart';
import '../../data/subjects_api.dart';

final subjectsApiProvider = Provider<SubjectsApi>((ref) {
  return SubjectsApi();
});

final subjectsProvider = FutureProvider.autoDispose<List<Subject>>((ref) async {
  final api = ref.watch(subjectsApiProvider);
  return api.fetchAll();
});
