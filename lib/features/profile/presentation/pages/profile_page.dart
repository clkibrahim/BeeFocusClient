import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/presentation/widgets/app_drawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _focusReminders = true;
  bool _weeklyReports = true;
  bool _darkMode = false;

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
        title: const Text('Profil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Buraya çıkış işlemi bağlanabilir
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Çıkış işlemi için bağlanın')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            _ProfileHeader(),
            const SizedBox(height: 16),
            _StatsRow(),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Tercihler',
              child: Column(
                children: [
                  _PreferenceTile(
                    icon: Icons.alarm,
                    label: 'Odak hatırlatıcıları',
                    value: _focusReminders,
                    onChanged: (v) => setState(() => _focusReminders = v),
                  ),
                  const Divider(height: 1),
                  _PreferenceTile(
                    icon: Icons.insights_outlined,
                    label: 'Haftalık rapor gönder',
                    value: _weeklyReports,
                    onChanged: (v) => setState(() => _weeklyReports = v),
                  ),
                  const Divider(height: 1),
                  _PreferenceTile(
                    icon: Icons.dark_mode_outlined,
                    label: 'Koyu tema',
                    value: _darkMode,
                    onChanged: (v) => setState(() => _darkMode = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'İlerleme Rozetleri',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _BadgeChip(label: '7 Gün Serisi', icon: Icons.local_fire_department),
                  _BadgeChip(label: '5 Saat', icon: Icons.timer),
                  _BadgeChip(label: 'İlk Hedef', icon: Icons.emoji_events_outlined),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Hızlı Erişim',
              child: Column(
                children: [
                  _LinkTile(
                    icon: Icons.edit_outlined,
                    label: 'Profili düzenle',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil düzenleme bağlanmadı')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _LinkTile(
                    icon: Icons.security_outlined,
                    label: 'Güvenlik',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Güvenlik ayarları bağlanmadı')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _LinkTile(
                    icon: Icons.help_outline,
                    label: 'Destek',
                    onTap: () => context.push('/reports'),
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

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'B',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.darkBrown,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BeeFocus Kullanıcısı',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'bee@example.com',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.mutedBrown),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.verified_outlined, size: 18, color: AppColors.success),
                  const SizedBox(width: 6),
                  Text(
                    'Premium',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.mutedBrown),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil düzenleme bağlanmadı')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: const [
        Expanded(
          child: _StatCard(
            label: 'Toplam süre',
            value: '32s 10d',
            icon: Icons.timer_outlined,
            color: AppColors.warning,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Haftalık hedef',
            value: '12 / 15s',
            icon: Icons.track_changes,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.darkBrown),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
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

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
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

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      avatar: Icon(icon, size: 18, color: AppColors.darkBrown),
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.darkBrown,
            ),
      ),
      backgroundColor: AppColors.primary.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

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
      trailing: const Icon(Icons.chevron_right, color: AppColors.mutedBrown),
      onTap: onTap,
    );
  }
}
