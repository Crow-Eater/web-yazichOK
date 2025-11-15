import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import 'placeholder_screen.dart';
import '../../presentation/auth/screens/sign_in_screen.dart';
import '../../presentation/auth/screens/sign_up_screen.dart';
import '../../presentation/main/screens/main_screen.dart';

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
          builder: (context, state) => const PlaceholderScreen(
            routeName: 'FlashCards',
          ),
        ),
        GoRoute(
          path: Routes.addWord,
          builder: (context, state) => const PlaceholderScreen(
            routeName: 'Add Word',
          ),
        ),
        GoRoute(
          path: Routes.addGroup,
          builder: (context, state) => const PlaceholderScreen(
            routeName: 'Add Group',
          ),
        ),
        GoRoute(
          path: Routes.memoriseWords,
          builder: (context, state) {
            final groupId = state.pathParameters['groupId'] ?? '';
            return PlaceholderScreen(
              routeName: 'Memorise Words',
              params: {'groupId': groupId},
            );
          },
        ),

        // Learn
        GoRoute(
          path: Routes.learn,
          builder: (context, state) => const PlaceholderScreen(
            routeName: 'Learn',
          ),
        ),
        GoRoute(
          path: Routes.grammarTopics,
          builder: (context, state) => const PlaceholderScreen(
            routeName: 'Grammar Topics',
          ),
        ),
        GoRoute(
          path: Routes.test,
          builder: (context, state) {
            final topicId = state.pathParameters['topicId'] ?? '';
            return PlaceholderScreen(
              routeName: 'Test',
              params: {'topicId': topicId},
            );
          },
        ),
        GoRoute(
          path: Routes.listening,
          builder: (context, state) => const PlaceholderScreen(
            routeName: 'Listening Practice',
          ),
        ),

        // Speaking
        GoRoute(
          path: Routes.speakingTopics,
          builder: (context, state) => const PlaceholderScreen(
            routeName: 'Speaking Topics',
          ),
        ),
        GoRoute(
          path: Routes.recording,
          builder: (context, state) => const PlaceholderScreen(
            routeName: 'Recording',
          ),
        ),
        GoRoute(
          path: Routes.assessment,
          builder: (context, state) => const PlaceholderScreen(
            routeName: 'Speaking Assessment',
          ),
        ),
        GoRoute(
          path: Routes.speakingResults,
          builder: (context, state) => const PlaceholderScreen(
            routeName: 'Speaking Results',
          ),
        ),

        // Articles
        GoRoute(
          path: Routes.articles,
          builder: (context, state) => const PlaceholderScreen(
            routeName: 'Articles',
          ),
        ),
        GoRoute(
          path: Routes.article,
          builder: (context, state) {
            final articleId = state.pathParameters['articleId'] ?? '';
            return PlaceholderScreen(
              routeName: 'Article',
              params: {'articleId': articleId},
            );
          },
        ),
        GoRoute(
          path: Routes.articleAnalysis,
          builder: (context, state) {
            final articleId = state.pathParameters['articleId'] ?? '';
            return PlaceholderScreen(
              routeName: 'Article Analysis',
              params: {'articleId': articleId},
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
