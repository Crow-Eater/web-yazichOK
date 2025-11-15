import 'package:flutter_test/flutter_test.dart';
import 'package:web/data/models/word_group.dart';
import 'package:web/data/models/flash_card.dart';

void main() {
  group('WordGroup', () {
    test('creates instance correctly', () {
      const group = WordGroup(
        id: 'g-1',
        title: 'Travel',
        words: [],
      );

      expect(group.id, 'g-1');
      expect(group.title, 'Travel');
      expect(group.words, isEmpty);
      expect(group.wordCount, 0);
    });

    test('wordCount returns correct count', () {
      const group = WordGroup(
        id: 'g-1',
        title: 'Travel',
        words: [
          FlashCard(
            id: 'w-1',
            word: 'luggage',
            transcription: 'ˈlʌɡ.ɪdʒ',
            translation: 'багаж',
          ),
          FlashCard(
            id: 'w-2',
            word: 'departure',
            transcription: 'dɪˈpɑːr.tʃər',
            translation: 'відправлення',
          ),
        ],
      );

      expect(group.wordCount, 2);
    });

    test('fromJson creates correct instance', () {
      final json = {
        'id': 'g-1',
        'title': 'Travel',
        'words': [
          {
            'id': 'w-1',
            'word': 'luggage',
            'transcription': 'ˈlʌɡ.ɪdʒ',
            'translation': 'багаж',
          }
        ],
      };

      final group = WordGroup.fromJson(json);

      expect(group.id, 'g-1');
      expect(group.title, 'Travel');
      expect(group.words.length, 1);
      expect(group.words[0].word, 'luggage');
    });

    test('toJson creates correct map', () {
      const group = WordGroup(
        id: 'g-1',
        title: 'Travel',
        words: [
          FlashCard(
            id: 'w-1',
            word: 'luggage',
            transcription: 'ˈlʌɡ.ɪdʒ',
            translation: 'багаж',
          ),
        ],
      );

      final json = group.toJson();

      expect(json['id'], 'g-1');
      expect(json['title'], 'Travel');
      expect(json['words'], isList);
      expect((json['words'] as List).length, 1);
    });
  });
}
