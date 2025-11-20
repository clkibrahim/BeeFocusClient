import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/presentation/widgets/app_drawer.dart';
import '../state/subjects_provider.dart';
import '../../data/subject_model.dart';

class SubjectsPage extends ConsumerWidget {
  const SubjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Dersler'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: subjectsAsync.when(
          data: (subjects) {
            final grouped = _groupByCategory(subjects);
            if (grouped.isEmpty) {
              return const Center(child: Text('Kayıt bulunamadı'));
            }
            return ListView(
              children: [
                const SizedBox(height: 12),
                ...grouped.entries.expand(
                  (entry) => [
                    _Section(title: entry.key, items: entry.value),
                    const SizedBox(height: 12),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text(
              'Hata: ${err.toString()}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedBrown),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, List<Subject>> _groupByCategory(List<Subject> subjects) {
    final map = <String, List<Subject>>{};
    for (final s in subjects) {
      final key = _categoryLabel(s.category);
      map.putIfAbsent(key, () => []);
      map[key]!.add(s);
    }
    return map;
  }

  String _categoryLabel(int? category) {
    if (category == null) return 'Dersler';
    switch (category) {
      case 0:
        return 'TYT';
      case 1:
        return 'AYT';
      case 2:
        return 'YDT';
      default:
        return 'Kategori $category';
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});

  final String title;
  final List<Subject> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: items
                .asMap()
                .entries
                .map(
                  (entry) => Column(
                    children: [
                      _SubjectTile(item: entry.value),
                      if (entry.key != items.length - 1)
                        Divider(
                          color: Colors.black.withValues(alpha: 0.05),
                          height: 1,
                          thickness: 1,
                        ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({required this.item});

  final Subject item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        height: 12,
        width: 12,
        decoration: BoxDecoration(
          color: _colorFromHex(item.colorHex) ?? AppColors.softPink,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      title: Text(
        item.name,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.mutedBrown),
      onTap: () {},
    );
  }

  Color? _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      final value = int.parse(hex.replaceAll('#', ''), radix: 16);
      if (hex.length == 6) {
        return Color(0xFF000000 | value);
      }
      if (hex.length == 8) {
        return Color(value);
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
