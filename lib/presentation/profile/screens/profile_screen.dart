import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../../core/theme/app_theme.dart';

/// Profile screen showing user information and settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      Text(
                        user?.displayName ?? 'User',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Email
                      Text(
                        user?.email ?? 'user@example.com',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Statistics Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Learning Statistics',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stats Grid
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.book,
                              label: 'Words Learned',
                              value: '127',
                              color: AppTheme.primaryPurple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.school,
                              label: 'Practice Sessions',
                              value: '15',
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.local_fire_department,
                              label: 'Streak Days',
                              value: '7',
                              color: AppTheme.greenAccent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.article,
                              label: 'Articles Read',
                              value: '3',
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Settings Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _SettingsTile(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        onTap: () {
                          // TODO: Navigate to edit profile screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit Profile coming soon!'),
                            ),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        onTap: () {
                          // TODO: Navigate to notifications settings
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notification settings coming soon!'),
                            ),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.language,
                        title: 'Language Preferences',
                        onTap: () {
                          // TODO: Navigate to language settings
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Language settings coming soon!'),
                            ),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () {
                          // TODO: Navigate to help screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Help & Support coming soon!'),
                            ),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'yazichOK',
                            applicationVersion: '1.0.0',
                            applicationLegalese: '© 2024 yazichOK. All rights reserved.',
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Sign Out Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Sign Out'),
                                content: const Text(
                                  'Are you sure you want to sign out?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                      context.read<AuthCubit>().signOut();
                                      context.go('/signin');
                                    },
                                    child: const Text(
                                      'Sign Out',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            'Sign Out',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Settings tile widget
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
