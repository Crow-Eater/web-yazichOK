import 'package:flutter_test/flutter_test.dart';
import 'package:yazich_ok/data/models/flash_card.dart';

void main() {
  group('FlashCard', () {
    test('creates instance correctly', () {
      const card = FlashCard(
        id: 'test-1',
        word: 'test',
        transcription: 'test',
        translation: 'тест',
      );

      expect(card.id, 'test-1');
      expect(card.word, 'test');
      expect(card.transcription, 'test');
      expect(card.translation, 'тест');
    });

    test('fromJson creates correct instance', () {
      final json = {
        'id': 'test-1',
        'word': 'hello',
        'transcription': 'həˈloʊ',
        'translation': 'привіт',
      };

      final card = FlashCard.fromJson(json);

      expect(card.id, 'test-1');
      expect(card.word, 'hello');
      expect(card.transcription, 'həˈloʊ');
      expect(card.translation, 'привіт');
    });

    test('toJson creates correct map', () {
      const card = FlashCard(
        id: 'test-1',
        word: 'hello',
        transcription: 'həˈloʊ',
        translation: 'привіт',
      );

      final json = card.toJson();

      expect(json['id'], 'test-1');
      expect(json['word'], 'hello');
      expect(json['transcription'], 'həˈloʊ');
      expect(json['translation'], 'привіт');
    });

    test('copyWith creates new instance with updated values', () {
      const card = FlashCard(
        id: 'test-1',
        word: 'hello',
        transcription: 'həˈloʊ',
        translation: 'привіт',
      );

      final updated = card.copyWith(translation: 'здоровенькі були');

      expect(updated.id, 'test-1');
      expect(updated.word, 'hello');
      expect(updated.transcription, 'həˈloʊ');
      expect(updated.translation, 'здоровенькі були');
    });

    test('equals works correctly', () {
      const card1 = FlashCard(
        id: 'test-1',
        word: 'hello',
        transcription: 'həˈloʊ',
        translation: 'привіт',
      );

      const card2 = FlashCard(
        id: 'test-1',
        word: 'hello',
        transcription: 'həˈloʊ',
        translation: 'привіт',
      );

      expect(card1, card2);
    });
  });
}
