import '../../domain/repositories/network_repository.dart';
import '../../domain/managers/auth_manager.dart';
import '../../domain/managers/audio_manager.dart';
import '../../domain/managers/recorder_manager.dart';
import '../../data/repositories/mock_network_repository.dart';
import '../../data/managers/mock_auth_manager.dart';
import '../../data/managers/local_audio_manager.dart';
import '../../data/managers/web_recorder_manager.dart';
import '../../presentation/speaking/cubit/speech_cubit.dart';

/// Service Locator for dependency injection
/// Provides singleton instances of repositories and managers
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  late NetworkRepository networkRepository;
  late AuthManager authManager;
  late AudioManager audioManager;
  late RecorderManager recorderManager;

  // Lazy-initialized cubits for routes that need shared state
  late final SpeechCubit _speechCubit = SpeechCubit(networkRepository, recorderManager);

  SpeechCubit get speechCubit => _speechCubit;

  bool _isInitialized = false;

  /// Initialize all services
  /// Call this once at app startup
  void setup() {
    // Dispose old instances if already initialized
    if (_isInitialized) {
      dispose();
    }

    // Initialize with mock implementations
    networkRepository = MockNetworkRepository();
    authManager = MockAuthManager();
    audioManager = LocalAudioManager();
    recorderManager = WebRecorderManager();
    _isInitialized = true;
  }

  /// Reset all services (useful for testing)
  void reset() {
    setup();
  }

  /// Dispose all services
  void dispose() {
    if (authManager is MockAuthManager) {
      (authManager as MockAuthManager).dispose();
    }
    audioManager.dispose();
    recorderManager.dispose();

    // Dispose singleton cubit to prevent memory leaks
    if (_isInitialized) {
      _speechCubit.close();
    }
  }
}

/// Global service locator instance
final sl = ServiceLocator();
