import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/subject_model.dart';

/// Şu an seçili olan dersi (tam obje olarak) tutar.
final selectedSubjectProvider = StateProvider<Subject?>((ref) => null);
