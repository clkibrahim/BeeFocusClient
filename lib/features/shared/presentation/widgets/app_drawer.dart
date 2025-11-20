import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final current = GoRouterState.of(context).name;

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Image.asset('assets/images/bee.png'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'BeeFocus',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            _DrawerItem(
              icon: Icons.timer_outlined,
              label: 'Sayaç',
              isActive: current == 'timer',
              onTap: () => context.goNamed('timer'),
            ),
            _DrawerItem(
              icon: Icons.menu_book_outlined,
              label: 'Dersler',
              isActive: current == 'subjects',
              onTap: () => context.goNamed('subjects'),
            ),
            _DrawerItem(
              icon: Icons.groups_outlined,
              label: 'Grup',
              onTap: () {},
            ),
            _DrawerItem(
              icon: Icons.bar_chart_outlined,
              label: 'Raporlar',
              isActive: current == 'reports',
              onTap: () => context.goNamed('reports'),
            ),
            _DrawerItem(
              icon: Icons.person_outline,
              label: 'Profil',
              isActive: current == 'profile',
              onTap: () => context.goNamed('profile'),
            ),
            const Spacer(),
            const Divider(),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Ayarlar',
              onTap: () {},
            ),
            _DrawerItem(icon: Icons.logout, label: 'Çıkış Yap', onTap: () {}),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.darkBrown : AppColors.mutedBrown;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary.withValues(alpha: 0.35) : null,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 14),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
