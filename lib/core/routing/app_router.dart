import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../presentation/auth/screens/sign_in_screen.dart';
import '../../presentation/auth/screens/sign_up_screen.dart';
import '../../presentation/main/screens/main_screen.dart';
import '../../presentation/flashcards/screens/flashcards_screen.dart';
import '../../presentation/flashcards/screens/add_new_word_screen.dart';
import '../../presentation/flashcards/screens/add_new_group_screen.dart';
import '../../presentation/flashcards/screens/memorise_words_screen.dart';
import '../../presentation/flashcards/cubit/flashcards_cubit.dart';
import '../../presentation/flashcards/cubit/memorise_cubit.dart';
import '../../presentation/learn/screens/learn_screen.dart';
import '../../presentation/learn/screens/grammar_topics_screen.dart';
import '../../presentation/learn/screens/test_screen.dart';
import '../../presentation/learn/screens/listening_practice_screen.dart';
import '../../presentation/learn/cubit/grammar_topics_cubit.dart';
import '../../presentation/learn/cubit/test_cubit.dart';
import '../../presentation/learn/cubit/listening_cubit.dart';
import '../../presentation/speaking/screens/speaking_topics_screen.dart';
import '../../presentation/speaking/screens/recording_screen.dart';
import '../../presentation/speaking/screens/speaking_assessment_screen.dart';
import '../../presentation/speaking/screens/speaking_results_screen.dart';
import '../../presentation/speaking/cubit/speech_cubit.dart';
import '../../presentation/articles/screens/articles_preview_screen.dart';
import '../../presentation/articles/screens/article_screen.dart';
import '../../presentation/articles/screens/article_analysis_screen.dart';
import '../../presentation/articles/cubit/articles_cubit.dart';
import '../../core/di/service_locator.dart';

/// Configures all app routes using go_router
class AppRouter {
  static GoRouter router({bool requireAuth = false}) {
    return GoRouter(
      initialLocation: Routes.main,
      routes: [
        // Main
        GoRoute(
          path: Routes.main,
          builder: (context, state) => const MainScreen(),
        ),

        // Auth
        GoRoute(
          path: Routes.signIn,
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: Routes.signUp,
          builder: (context, state) => const SignUpScreen(),
        ),

        // FlashCards
        GoRoute(
          path: Routes.flashcards,
          builder: (context, state) => BlocProvider(
            create: (context) => FlashCardsCubit(
              ServiceLocator().networkRepository,
            )..loadGroups(),
            child: const FlashCardsScreen(),
          ),
        ),
        GoRoute(
          path: Routes.addWord,
          builder: (context, state) => BlocProvider(
            create: (context) => FlashCardsCubit(
              ServiceLocator().networkRepository,
            )..loadGroups(),
            child: const AddNewWordScreen(),
          ),
        ),
        GoRoute(
          path: Routes.addGroup,
          builder: (context, state) => BlocProvider(
            create: (context) => FlashCardsCubit(
              ServiceLocator().networkRepository,
            ),
            child: const AddNewGroupScreen(),
          ),
        ),
        GoRoute(
          path: Routes.memoriseWords,
          builder: (context, state) {
            final groupId = state.pathParameters['groupId'] ?? '';
            return BlocProvider(
              create: (context) => MemoriseCubit(
                ServiceLocator().networkRepository,
              )..loadGroup(groupId),
              child: MemoriseWordsScreen(groupId: groupId),
            );
          },
        ),

        // Learn
        GoRoute(
          path: Routes.learn,
          builder: (context, state) => const LearnScreen(),
        ),
        GoRoute(
          path: Routes.grammarTopics,
          builder: (context, state) => BlocProvider(
            create: (context) => GrammarTopicsCubit(
              ServiceLocator().networkRepository,
            )..loadTopics(),
            child: const GrammarTopicsScreen(),
          ),
        ),
        GoRoute(
          path: Routes.test,
          builder: (context, state) {
            final topicId = state.pathParameters['topicId'] ?? '';
            return BlocProvider(
              create: (context) => TestCubit(
                ServiceLocator().networkRepository,
              )..loadTopic(topicId),
              child: TestScreen(topicId: topicId),
            );
          },
        ),
        GoRoute(
          path: Routes.listening,
          builder: (context, state) => BlocProvider(
            create: (context) => ListeningCubit(
              ServiceLocator().networkRepository,
              ServiceLocator().audioManager,
            )..loadRecords(),
            child: const ListeningPracticeScreen(),
          ),
        ),

        // Speaking - All routes use the same singleton SpeechCubit
        GoRoute(
          path: Routes.speakingTopics,
          builder: (context, state) {
            ServiceLocator().speechCubit.loadTopics();
            return BlocProvider.value(
              value: ServiceLocator().speechCubit,
              child: const SpeakingTopicsScreen(),
            );
          },
        ),
        GoRoute(
          path: Routes.recording,
          builder: (context, state) => BlocProvider.value(
            value: ServiceLocator().speechCubit,
            child: const RecordingScreen(),
          ),
        ),
        GoRoute(
          path: Routes.assessment,
          builder: (context, state) => BlocProvider.value(
            value: ServiceLocator().speechCubit,
            child: const SpeakingAssessmentScreen(),
          ),
        ),
        GoRoute(
          path: Routes.speakingResults,
          builder: (context, state) {
            ServiceLocator().speechCubit.loadResultsHistory();
            return BlocProvider.value(
              value: ServiceLocator().speechCubit,
              child: const SpeakingResultsScreen(),
            );
          },
        ),

        // Articles
        GoRoute(
          path: Routes.articles,
          builder: (context, state) => BlocProvider(
            create: (context) => ArticlesCubit(
              ServiceLocator().networkRepository,
            )..loadArticles(),
            child: const ArticlesPreviewScreen(),
          ),
        ),
        GoRoute(
          path: Routes.article,
          builder: (context, state) {
            final articleId = state.pathParameters['articleId'] ?? '';
            return BlocProvider(
              create: (context) => ArticlesCubit(
                ServiceLocator().networkRepository,
              )..loadArticle(articleId),
              child: ArticleScreen(articleId: articleId),
            );
          },
        ),
        GoRoute(
          path: Routes.articleAnalysis,
          builder: (context, state) {
            final articleId = state.pathParameters['articleId'] ?? '';
            return BlocProvider(
              create: (context) => ArticlesCubit(
                ServiceLocator().networkRepository,
              )..analyzeArticle(articleId),
              child: ArticleAnalysisScreen(articleId: articleId),
            );
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                '404 - Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
