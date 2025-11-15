import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/articles_cubit.dart';
import '../cubit/articles_state.dart';
import '../widgets/article_header.dart';
import '../widgets/article_content.dart';

/// Article reading screen showing full article content
class ArticleScreen extends StatelessWidget {
  final String articleId;

  const ArticleScreen({
    super.key,
    required this.articleId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<ArticlesCubit, ArticlesState>(
        builder: (context, state) {
          // Loading state
          if (state is ArticleLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (state is ArticlesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load article',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ArticlesCubit>().loadArticle(articleId);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Loaded state
          if (state is ArticleLoaded) {
            final article = state.article;

            return LayoutBuilder(
              builder: (context, constraints) {
                // Center content on wide screens with max width
                final isWideScreen = constraints.maxWidth > 900;
                final maxWidth = isWideScreen ? 800.0 : double.infinity;

                return Stack(
                  children: [
                    // Scrollable content
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: CustomScrollView(
                          slivers: [
                            // Article header
                            SliverToBoxAdapter(
                              child: ArticleHeader(article: article),
                            ),

                            // Article content
                            SliverToBoxAdapter(
                              child: ArticleContent(content: article.content),
                            ),

                            // Bottom padding for floating button
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 100),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Floating "Analyze Article" button
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.push('/articles/$articleId/analysis');
                            },
                            icon: const Icon(Icons.analytics_outlined),
                            label: const Text('Analyze Article'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }

          // Initial or unknown state
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
