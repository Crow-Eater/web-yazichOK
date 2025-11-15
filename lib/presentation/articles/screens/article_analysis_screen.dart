import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/articles_cubit.dart';
import '../cubit/articles_state.dart';
import '../widgets/vocabulary_list.dart';
import '../widgets/grammar_points_list.dart';
import '../widgets/analysis_summary.dart';

/// Article analysis screen showing vocabulary, grammar, and summary
class ArticleAnalysisScreen extends StatelessWidget {
  final String articleId;

  const ArticleAnalysisScreen({
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
        title: const Text('Article Analysis'),
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
          // Processing state
          if (state is ArticleAnalysisProcessing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'Analyzing Your Article...',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while we extract key information',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
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
                    'Analysis Failed',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ArticlesCubit>().analyzeArticle(articleId);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Completed state
          if (state is ArticleAnalysisCompleted) {
            final article = state.article;
            final analysis = state.analysis;

            return LayoutBuilder(
              builder: (context, constraints) {
                // Center content on wide screens with max width
                final isWideScreen = constraints.maxWidth > 900;
                final maxWidth = isWideScreen ? 800.0 : double.infinity;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: CustomScrollView(
                      slivers: [
                        // Header with article title
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  size: 48,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Analysis Results',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  article.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Content sections
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // Summary
                              AnalysisSummary(summary: analysis.summary),
                              const SizedBox(height: 24),

                              // Vocabulary
                              VocabularyList(
                                vocabularyItems: analysis.vocabulary,
                              ),
                              const SizedBox(height: 24),

                              // Grammar Points
                              GrammarPointsList(
                                grammarPoints: analysis.grammarPoints,
                              ),
                              const SizedBox(height: 24),

                              // Action buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => context.pop(),
                                      icon: const Icon(Icons.arrow_back),
                                      label: const Text('Back to Article'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                            ]),
                          ),
                        ),
                      ],
                    ),
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
}
