import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/articles_cubit.dart';
import '../cubit/articles_state.dart';
import '../widgets/article_card.dart';

/// Articles preview screen showing list of all available articles
class ArticlesPreviewScreen extends StatelessWidget {
  const ArticlesPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Articles'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      body: BlocBuilder<ArticlesCubit, ArticlesState>(
        builder: (context, state) {
          // Loading state
          if (state is ArticlesLoading) {
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
                    'Oops! Something went wrong',
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
                      context.read<ArticlesCubit>().loadArticles();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Loaded state
          if (state is ArticlesLoaded) {
            final articles = state.articles;

            // Empty state
            if (articles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 64,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No articles available',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for new content',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Articles list
            return LayoutBuilder(
              builder: (context, constraints) {
                // Responsive layout: use grid on wider screens
                final isWideScreen = constraints.maxWidth > 768;
                final crossAxisCount = isWideScreen ? 2 : 1;
                final maxWidth = isWideScreen ? 1200.0 : 600.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: isWideScreen
                        ? _buildGridView(articles, crossAxisCount, context)
                        : _buildListView(articles, context),
                  ),
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

  Widget _buildListView(List articles, BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final article = articles[index];
        return ArticleCard(
          article: article,
          onTap: () {
            context.push('/articles/${article.id}');
          },
        );
      },
    );
  }

  Widget _buildGridView(
    List articles,
    int crossAxisCount,
    BuildContext context,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return ArticleCard(
          article: article,
          onTap: () {
            context.push('/articles/${article.id}');
          },
        );
      },
    );
  }
}
