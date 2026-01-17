import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/presentation/widgets/app_drawer.dart';
import '../../../timer/presentation/state/sessions_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _focusReminders = true;
  bool _weeklySummary = true;
  bool _soundEffects = true;
  bool _isSyncing = false;
  
  int _totalSessions = 0;
  int _unsyncedSessions = 0;
  String _lastError = '';

  @override
  void initState() {
    super.initState();
    _loadSessionStats();
  }

  Future<void> _loadSessionStats() async {
    try {
      final localService = ref.read(sessionsLocalServiceProvider);
      final allSessions = await localService.getAllSessions();
      final unsyncedCompleted = await localService.getUnsyncedCompletedSessions();
      
      // Debug: tüm session'ları logla
      await localService.debugPrintAllSessions();
      
      if (mounted) {
        setState(() {
          _totalSessions = allSessions.length;
          _unsyncedSessions = unsyncedCompleted.length;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading session stats: $e');
    }
  }

  Future<void> _syncNow() async {
    setState(() {
      _isSyncing = true;
      _lastError = '';
    });
    
    try {
      // Önce stats'ı yenile
      await _loadSessionStats();
      
      final repository = ref.read(sessionsRepositoryProvider);
      await repository.syncUnsyncedSessions();
      
      // Sync sonrası stats'ı yenile
      await _loadSessionStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Senkronizasyon tamamlandı')),
        );
      }
    } catch (e) {
      setState(() => _lastError = e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Senkronizasyon hatası: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Ayarlar'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Senkronizasyon',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Debug bilgisi
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📊 Local DB Durumu:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Toplam session: $_totalSessions'),
                        Text('Senkronize edilmemiş: $_unsyncedSessions', 
                          style: TextStyle(
                            color: _unsyncedSessions > 0 ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_lastError.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('❌ Son hata: $_lastError', 
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.sync),
                    title: const Text('Verileri Senkronize Et'),
                    subtitle: Text(_unsyncedSessions > 0 
                      ? '$_unsyncedSessions session bekliyor'
                      : 'Tüm veriler senkronize'),
                    trailing: _isSyncing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _isSyncing ? null : _syncNow,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.refresh),
                    title: const Text('Durumu Yenile'),
                    onTap: _loadSessionStats,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Odak Tercihleri',
              child: Column(
                children: [
                  _SwitchTile(
                    icon: Icons.alarm,
                    label: 'Odak hatırlatıcıları',
                    value: _focusReminders,
                    onChanged: (v) => setState(() => _focusReminders = v),
                  ),
                  const Divider(height: 1),
                  _SwitchTile(
                    icon: Icons.insights_outlined,
                    label: 'Haftalık özet bildirimi',
                    value: _weeklySummary,
                    onChanged: (v) => setState(() => _weeklySummary = v),
                  ),
                  const Divider(height: 1),
                  _SwitchTile(
                    icon: Icons.volume_up_outlined,
                    label: 'Ses efektleri',
                    value: _soundEffects,
                    onChanged: (v) => setState(() => _soundEffects = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Uygulama',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ayarlar şu an sadece bu cihazda geçerlidir. '
                    'İleride hesap ile eşleştirme ve çoklu cihaz senkronu eklenecek.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.mutedBrown),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkBrown,
                ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.mutedBrown),
      title: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
