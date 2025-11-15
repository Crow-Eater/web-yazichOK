import 'package:flutter_test/flutter_test.dart';
import 'package:yazich_ok/core/di/service_locator.dart';
import 'package:yazich_ok/data/repositories/mock_network_repository.dart';
import 'package:yazich_ok/data/managers/mock_auth_manager.dart';
import 'package:yazich_ok/data/managers/local_audio_manager.dart';
import 'package:yazich_ok/data/managers/web_recorder_manager.dart';

void main() {
  group('ServiceLocator', () {
    test('setup initializes all services', () {
      sl.setup();

      expect(sl.networkRepository, isA<MockNetworkRepository>());
      expect(sl.authManager, isA<MockAuthManager>());
      expect(sl.audioManager, isA<LocalAudioManager>());
      expect(sl.recorderManager, isA<WebRecorderManager>());
    });

    test('reset reinitializes all services', () {
      sl.setup();
      final oldAuthManager = sl.authManager;

      sl.reset();

      expect(sl.authManager, isNot(same(oldAuthManager)));
    });

    test('services are singletons', () {
      sl.setup();
      final networkRepo1 = sl.networkRepository;
      final networkRepo2 = sl.networkRepository;

      expect(networkRepo1, same(networkRepo2));
    });
  });
}
