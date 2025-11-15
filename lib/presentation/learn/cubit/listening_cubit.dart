import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yazich_ok/data/models/audio_record.dart';
import 'package:yazich_ok/domain/managers/audio_manager.dart';
import 'package:yazich_ok/domain/repositories/network_repository.dart';
import 'package:yazich_ok/presentation/learn/cubit/listening_state.dart';

/// Cubit for managing Listening Practice state
class ListeningCubit extends Cubit<ListeningState> {
  final NetworkRepository _networkRepository;
  final AudioManager _audioManager;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<bool>? _playingSubscription;

  ListeningCubit(this._networkRepository, this._audioManager)
      : super(const ListeningInitial());

  /// Load audio records
  Future<void> loadRecords() async {
    try {
      emit(const ListeningLoading());
      final records = await _networkRepository.getAudioRecords();

      if (records.isEmpty) {
        emit(const ListeningError('No audio records available'));
        return;
      }

      // Auto-select first record
      final firstRecord = records.first;
      await _selectRecord(firstRecord, records);
    } catch (e) {
      emit(ListeningError('Failed to load audio records: ${e.toString()}'));
    }
  }

  /// Select an audio record to play
  Future<void> selectRecord(AudioRecord record) async {
    if (state is! ListeningLoaded) return;

    final currentState = state as ListeningLoaded;
    await _selectRecord(record, currentState.records);
  }

  Future<void> _selectRecord(
      AudioRecord record, List<AudioRecord> records) async {
    try {
      // Cancel previous subscriptions
      await _cancelSubscriptions();

      // Load the audio
      await _audioManager.load(record);

      // Setup listeners
      _positionSubscription =
          _audioManager.positionStream.listen((position) {
        if (state is ListeningLoaded) {
          final currentState = state as ListeningLoaded;
          emit(currentState.copyWith(position: position));
        }
      });

      _durationSubscription =
          _audioManager.durationStream.listen((duration) {
        if (state is ListeningLoaded) {
          final currentState = state as ListeningLoaded;
          emit(currentState.copyWith(duration: duration));
        }
      });

      _playingSubscription =
          _audioManager.playbackStateStream.listen((isPlaying) {
        if (state is ListeningLoaded) {
          final currentState = state as ListeningLoaded;
          emit(currentState.copyWith(isPlaying: isPlaying));
        }
      });

      emit(ListeningLoaded(
        records: records,
        selectedRecord: record,
        isPlaying: false,
        position: Duration.zero,
        duration: Duration.zero,
      ));
    } catch (e) {
      emit(ListeningError('Failed to load audio: ${e.toString()}'));
    }
  }

  /// Play audio
  Future<void> play() async {
    try {
      await _audioManager.play();
    } catch (e) {
      emit(ListeningError('Failed to play audio: ${e.toString()}'));
    }
  }

  /// Pause audio
  Future<void> pause() async {
    try {
      await _audioManager.pause();
    } catch (e) {
      emit(ListeningError('Failed to pause audio: ${e.toString()}'));
    }
  }

  /// Seek forward by specified seconds
  Future<void> seekForward(int seconds) async {
    if (state is! ListeningLoaded) return;

    try {
      final currentState = state as ListeningLoaded;
      final newPosition = currentState.position + Duration(seconds: seconds);
      final maxPosition = currentState.duration;

      if (newPosition <= maxPosition) {
        await _audioManager.seek(newPosition);
      } else {
        await _audioManager.seek(maxPosition);
      }
    } catch (e) {
      emit(ListeningError('Failed to seek: ${e.toString()}'));
    }
  }

  /// Seek backward by specified seconds
  Future<void> seekBackward(int seconds) async {
    if (state is! ListeningLoaded) return;

    try {
      final currentState = state as ListeningLoaded;
      final newPosition = currentState.position - Duration(seconds: seconds);

      if (newPosition >= Duration.zero) {
        await _audioManager.seek(newPosition);
      } else {
        await _audioManager.seek(Duration.zero);
      }
    } catch (e) {
      emit(ListeningError('Failed to seek: ${e.toString()}'));
    }
  }

  /// Seek to specific position
  Future<void> seekTo(Duration position) async {
    try {
      await _audioManager.seek(position);
    } catch (e) {
      emit(ListeningError('Failed to seek: ${e.toString()}'));
    }
  }

  Future<void> _cancelSubscriptions() async {
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _playingSubscription?.cancel();
    _positionSubscription = null;
    _durationSubscription = null;
    _playingSubscription = null;
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    _audioManager.dispose();
    return super.close();
  }
}
