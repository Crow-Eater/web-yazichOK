import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/breakpoints.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';

/// Main screen matching screenshot design
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthCubit is already provided by AppShell
    return const _MainContent();
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Navigate to sign in if user is logged out
          context.go('/signin');
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Row(
          children: [
            // Main content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // App bar
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    title: BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final user = state is AuthAuthenticated ? state.user : null;
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: colorScheme.primaryContainer,
                              child: Text(
                                user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${user?.displayName ?? 'User'}',
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  'Ready to practice?',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                        tooltip: 'View notifications',
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),

                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Practice Features Section
                        Text(
                          'Practice Features',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),

                        // Feature cards row
                        Row(
                          children: [
                            // Speech Practice card (Blue)
                            Expanded(
                              child: _FeatureCard(
                                title: 'Speech Practice',
                                subtitle: 'Improve pronunciation',
                                icon: Icons.mic,
                                gradient: AppTheme.blueGradient,
                                onTap: () {
                                  context.push('/speaking/topics');
                                },
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Flashcards card (Purple)
                            Expanded(
                              child: _FeatureCard(
                                title: 'Flashcards',
                                subtitle: 'Learn new words',
                                icon: Icons.style,
                                gradient: AppTheme.purpleGradient,
                                onTap: () {
                                  context.push('/flashcards');
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Recommended Articles Section
                        Text(
                          'Recommended Articles',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),

                        // Article cards
                        _ArticleCard(
                          title: 'The Future of Technology',
                          level: 'Advanced',
                          readTime: '5 min read',
                          onTap: () {
                            context.push('/articles/art-1');
                          },
                        ),
                        const SizedBox(height: 12),
                        _ArticleCard(
                          title: 'Effective Study Techniques for Language Learners',
                          level: 'Intermediate',
                          readTime: '4 min read',
                          onTap: () {
                            context.push('/articles/art-2');
                          },
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            // Weekly Progress Sidebar (only show on larger screens)
            if (MediaQuery.of(context).size.width > Breakpoints.desktop)
              Container(
                width: 320,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    left: BorderSide(
                      color: colorScheme.outline,
                      width: 1,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Progress',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),

                      // Stats
                      _StatItem(
                        label: 'Words Learned',
                        value: '127',
                        color: AppTheme.primaryPurple,
                      ),
                      const SizedBox(height: 16),
                      _StatItem(
                        label: 'Practice Sessions',
                        value: '15',
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(height: 16),
                      _StatItem(
                        label: 'Streak Days',
                        value: '7',
                        color: AppTheme.greenAccent,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Feature card widget
class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Article card widget
class _ArticleCard extends StatelessWidget {
  final String title;
  final String level;
  final String readTime;
  final VoidCallback onTap;

  const _ArticleCard({
    required this.title,
    required this.level,
    required this.readTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.article,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          level,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        readTime,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat item widget
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
