import '../models/word_group.dart';
import '../models/flash_card.dart';

/// Mock flashcard data from plan.md
final List<WordGroup> mockFlashcardGroups = [
  WordGroup(
    id: 'g-travel',
    title: 'Travel',
    words: [
      const FlashCard(
        id: 'w-1',
        word: 'luggage',
        transcription: 'ˈlʌɡ.ɪdʒ',
        translation: 'багаж',
      ),
      const FlashCard(
        id: 'w-2',
        word: 'departure',
        transcription: 'dɪˈpɑːr.tʃər',
        translation: 'відправлення',
      ),
      const FlashCard(
        id: 'w-3',
        word: 'passport',
        transcription: 'ˈpɑːs.pɔːrt',
        translation: 'паспорт',
      ),
      const FlashCard(
        id: 'w-4',
        word: 'boarding',
        transcription: 'ˈbɔːr.dɪŋ',
        translation: 'посадка',
      ),
    ],
  ),
  WordGroup(
    id: 'g-cafe',
    title: 'Cafe',
    words: [
      const FlashCard(
        id: 'w-10',
        word: 'barista',
        transcription: 'bəˈriː.stə',
        translation: 'бариста',
      ),
      const FlashCard(
        id: 'w-11',
        word: 'espresso',
        transcription: 'eˈspres.oʊ',
        translation: 'еспресо',
      ),
      const FlashCard(
        id: 'w-12',
        word: 'latte',
        transcription: 'ˈlɑː.teɪ',
        translation: 'лате',
      ),
    ],
  ),
  WordGroup(
    id: 'g-education',
    title: 'Education',
    words: [
      const FlashCard(
        id: 'w-20',
        word: 'curriculum',
        transcription: 'kəˈrɪk.jə.ləm',
        translation: 'навчальний план',
      ),
      const FlashCard(
        id: 'w-21',
        word: 'assignment',
        transcription: 'əˈsaɪn.mənt',
        translation: 'завдання',
      ),
      const FlashCard(
        id: 'w-22',
        word: 'semester',
        transcription: 'səˈmes.tər',
        translation: 'семестр',
      ),
    ],
  ),
];
