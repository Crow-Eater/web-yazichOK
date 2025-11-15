# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter web application for language learning platform (yazichOK). Currently a minimal Hello World app being developed into a comprehensive language learning system with flashcards, grammar tests, listening practice, speech assessment, and article reading features.

**Target Platform**: Web (with potential mobile expansion)
**Flutter Version**: 3.35.6 (stable channel)

## Development Commands

### Running the App
```bash
# Install dependencies
flutter pub get

# Run in development mode (web)
flutter run -d chrome

# Build for production
flutter build web --release

# Build with custom base href (for GitHub Pages)
flutter build web --release --base-href /web-yazichOK/
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Code Quality
```bash
# Run linter
flutter analyze

# Format code
flutter format lib/ test/

# Run SonarQube analysis locally (requires Docker & .env with SONAR_TOKEN)
make runsonar
```

### Docker
```bash
# Build and run with Docker Compose
docker compose up -d

# Build with custom base href
docker build --build-arg BASE_HREF=/web-yazichOK/ -t web-yazichok .

# Run Sonar container only
docker compose -f compose.sonar.yaml up -d
```

## Architecture & Patterns

This project follows **Clean Architecture** principles with **BLoC pattern** (specifically Cubits from `flutter_bloc`).

### Layer Separation
```
Widget (View) ↔ Cubit (State Management) ↔ Repositories/Managers ↔ Models
```

**Critical Rule**: Maintain strict separation. Widgets should NEVER directly call repositories/managers—always go through Cubits.

### State Management with Cubit

All business logic uses the **Cubit pattern** from `flutter_bloc`:

- Each feature has a `Cubit` class extending `Cubit<StateClass>`
- State classes are **immutable** (use `freezed` or `equatable`)
- Cubits emit new states via `emit(newState)`
- UI reacts with `BlocBuilder<Cubit, State>` or `BlocConsumer<Cubit, State>`
- Dependencies injected via `BlocProvider`

**State Naming Convention**: Each state class has sub-states like `Initial`, `Loading`, `Loaded`, `Error`

Example:
```dart
// State
class FlashCardsState extends Equatable {
  final List<WordGroup> groups;
  final bool isLoading;
  // ...
}

// Cubit
class FlashCardsCubit extends Cubit<FlashCardsState> {
  final NetworkManager networkManager;
  FlashCardsCubit(this.networkManager) : super(FlashCardsInitial());

  Future<void> loadGroups() async {
    emit(FlashCardsLoading());
    final groups = await networkManager.getFlashcardGroups();
    emit(FlashCardsLoaded(groups));
  }
}

// Widget
BlocBuilder<FlashCardsCubit, FlashCardsState>(
  builder: (context, state) {
    if (state is FlashCardsLoading) return CircularProgressIndicator();
    if (state is FlashCardsLoaded) return ListView(...);
    return SizedBox.shrink();
  },
)
```

### Dependency Injection

- Use `BlocProvider` to inject Cubits with their dependencies
- Use `RepositoryProvider` for app-wide services
- Cubits receive dependencies via constructor injection
- All services must be interfaces to enable mock/real swapping

Example:
```dart
BlocProvider(
  create: (context) => FlashCardsCubit(
    context.read<NetworkManager>(),
  ),
  child: FlashCardsScreen(),
)
```

### Mock-First Architecture

**Critical for Implementation**: All features start with mock implementations that can be swapped for real services later.

- `NetworkManager` interface → `MockNetworkManager` (initially) / `HttpNetworkManager` (later)
- `AudioManager` interface → `LocalAudioManager` (initially) / `RemoteAudioManager` (later)
- `RecorderManager` interface → `WebRecorderManager` (web-specific)
- `AuthManager` interface → `MockAuthManager` (initially) / real auth provider (later)

Mock implementations use deterministic data, in-memory storage, or local assets.

### Routing

Use `go_router` (or Navigator 2.0) for web-friendly deep linking. Each screen must have a meaningful URL path.

**Route Structure** (from plan.md):
- `/` → Main screen
- `/flashcards` → FlashCards
- `/flashcards/group/:groupId` → MemoriseWords
- `/learn` → Learn screen
- `/learn/grammar-topics` → Grammar topics
- `/learn/test/:topicId` → Test screen
- `/learn/listening` → Listening practice
- `/auth/signin` → Sign in
- `/auth/signup` → Sign up
- `/speaking/topics` → Speaking topics
- `/articles` → Articles list
- `/articles/:articleId` → Article detail

## Naming Conventions

### Screens (Widgets)
`<Feature>Screen` pattern: `FlashCardsScreen`, `MemoriseWordsScreen`, `LearnScreen`, `TestScreen`, etc.

### Cubits
`<Feature>Cubit` pattern: `FlashCardsCubit`, `MemoriseCubit`, `LearnCubit`, `TestCubit`, `AuthCubit`, etc.

### State Classes
`<Feature>State` with sub-states: `FlashCardsInitial`, `FlashCardsLoading`, `FlashCardsLoaded`, `FlashCardsError`

### Services/Managers
Interface + Implementation pattern:
- `NetworkManager` (interface) → `MockNetworkManager`, `HttpNetworkManager`
- `AudioManager` (interface) → `LocalAudioManager`, `RemoteAudioManager`
- `RecorderManager` (interface) → `WebRecorderManager`

### Models
Clear, descriptive names: `WordGroup`, `FlashCard`, `GrammarTopic`, `Question`, `AudioRecord`, `User`, `Article`

## Feature Modules (from plan.md)

The application is organized into distinct feature modules. Each module has its own screens, Cubits, and state:

1. **Flash Cards**: Word groups, memorization flow with statistics
2. **Grammar Tests**: Topic selection, question flow with check/continue logic
3. **Listening Practice**: Audio player with playlist, seek controls
4. **Authentication**: Sign in/up with validation
5. **Speech Assessment**: Recording, assessment results, history
6. **Articles**: Reading interface, vocabulary/grammar analysis

Refer to `plan.md` for complete feature specifications, UI structure, mock data, and acceptance criteria.

## Web-Specific Considerations

- Audio playback: Use `just_audio` with web backend support
- Recording: Use `WebRecorderManager` with Web Audio API or browser-compatible package
- Responsive layout: Components should center and scale for desktop/tablet widths
- Keyboard accessibility: Ensure tab navigation and Enter key support
- Use semantic widgets for accessibility (a11y)

## CI/CD & Deployment

### GitHub Actions
- **actions.yaml**: Runs tests on PR/push, builds Docker image for main/production
- **deploy.yml**: Deploys to GitHub Pages on main branch push

### Deployment Targets
- **GitHub Pages**: Base href is `/web-yazichOK/`
- **Docker**: Multi-stage build with nginx serving static files
- **Container Registry**: Images pushed to ghcr.io

### SonarQube
- Local analysis via `make runsonar` (requires SONAR_TOKEN in .env)
- Project key: `web-yazichOK`
- Coverage reports from `coverage/lcov.info`
- Excludes: build artifacts, tests, generated files (*.g.dart)

## Important Development Guidelines

### State Management Rules
1. Only ONE Cubit should be `in_progress` at a time per feature
2. State should be immutable—always emit new state instances
3. Never mutate state directly
4. Handle all states (initial, loading, loaded, error) in widgets

### Data Flow
- User interaction → Widget calls Cubit method → Cubit calls Repository/Manager → Cubit emits new state → Widget rebuilds

### Testing Strategy
- Widget tests for UI components
- Unit tests for Cubits (business logic)
- Mock repositories/managers using `mocktail` or `mockito`

### Code Quality Standards
- Run `flutter analyze` before committing
- Maintain test coverage (run with `--coverage`)
- Format code with `flutter format`

## Project Status

**Current State**: Minimal Hello World application
**Target State**: Full-featured language learning platform (see `plan.md` for complete specifications)

The codebase is designed to scale from mock implementations to real backend integrations without major refactoring, thanks to interface-based architecture and dependency injection.
