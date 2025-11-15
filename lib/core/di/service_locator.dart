import '../../domain/repositories/network_repository.dart';
import '../../domain/managers/auth_manager.dart';
import '../../domain/managers/audio_manager.dart';
import '../../domain/managers/recorder_manager.dart';
import '../../data/repositories/mock_network_repository.dart';
import '../../data/managers/mock_auth_manager.dart';
import '../../data/managers/local_audio_manager.dart';
import '../../data/managers/web_recorder_manager.dart';

/// Service Locator for dependency injection
/// Provides singleton instances of repositories and managers
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  late final NetworkRepository networkRepository;
  late final AuthManager authManager;
  late final AudioManager audioManager;
  late final RecorderManager recorderManager;

  /// Initialize all services
  /// Call this once at app startup
  void setup() {
    // Initialize with mock implementations
    networkRepository = MockNetworkRepository();
    authManager = MockAuthManager();
    audioManager = LocalAudioManager();
    recorderManager = WebRecorderManager();
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
  }
}

/// Global service locator instance
final sl = ServiceLocator();
