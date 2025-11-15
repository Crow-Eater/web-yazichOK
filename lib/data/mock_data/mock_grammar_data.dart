import '../models/grammar_topic.dart';
import '../models/question.dart';

/// Mock grammar topics from plan.md
final List<GrammarTopic> mockGrammarTopics = [
  const GrammarTopic(
    id: 't-articles',
    title: 'Articles',
    description: 'Learn when to use a, an, and the',
    questionCount: 10,
  ),
  const GrammarTopic(
    id: 't-tenses',
    title: 'Tenses',
    description: 'Master present, past, and future tenses',
    questionCount: 12,
  ),
  const GrammarTopic(
    id: 't-prepositions',
    title: 'Prepositions',
    description: 'Common prepositions and their usage',
    questionCount: 8,
  ),
];

/// Mock questions for grammar topics
final Map<String, List<Question>> mockQuestions = {
  't-articles': [
    const Question(
      id: 'q-1',
      text: 'Choose the correct article: ___ apple a day keeps the doctor away.',
      options: ['A', 'An', 'The', 'No article'],
      correctIndex: 1,
      explanation: "'apple' starts with a vowel sound — use 'An'.",
    ),
    const Question(
      id: 'q-2',
      text: 'Choose the correct article: I saw ___ beautiful rainbow yesterday.',
      options: ['a', 'an', 'the', 'no article'],
      correctIndex: 0,
      explanation: "'beautiful' starts with a consonant sound — use 'a'.",
    ),
    const Question(
      id: 'q-3',
      text: 'Choose the correct article: ___ sun rises in the east.',
      options: ['A', 'An', 'The', 'No article'],
      correctIndex: 2,
      explanation: "Use 'The' for unique things like the sun, moon, earth.",
    ),
    const Question(
      id: 'q-4',
      text: 'Choose the correct article: She is ___ engineer.',
      options: ['a', 'an', 'the', 'no article'],
      correctIndex: 1,
      explanation: "'engineer' starts with a vowel sound — use 'an'.",
    ),
    const Question(
      id: 'q-5',
      text: 'Choose the correct article: I need ___ information about the course.',
      options: ['a', 'an', 'the', 'no article'],
      correctIndex: 3,
      explanation: "'Information' is uncountable — no article needed.",
    ),
    const Question(
      id: 'q-6',
      text: 'Choose the correct article: He plays ___ guitar very well.',
      options: ['a', 'an', 'the', 'no article'],
      correctIndex: 2,
      explanation: "Use 'the' with musical instruments.",
    ),
    const Question(
      id: 'q-7',
      text: 'Choose the correct article: They live in ___ United States.',
      options: ['a', 'an', 'the', 'no article'],
      correctIndex: 2,
      explanation: "Country names with 'United', 'Kingdom', 'Republic' use 'the'.",
    ),
    const Question(
      id: 'q-8',
      text: 'Choose the correct article: I have ___ brother and ___ sister.',
      options: ['a, a', 'an, an', 'a, an', 'the, the'],
      correctIndex: 0,
      explanation: "Use 'a' before consonant sounds.",
    ),
    const Question(
      id: 'q-9',
      text: 'Choose the correct article: This is ___ most interesting book.',
      options: ['a', 'an', 'the', 'no article'],
      correctIndex: 2,
      explanation: "Use 'the' with superlatives (most interesting).",
    ),
    const Question(
      id: 'q-10',
      text: 'Choose the correct article: ___ honesty is the best policy.',
      options: ['A', 'An', 'The', 'No article'],
      correctIndex: 3,
      explanation: "Abstract nouns in general statements don't need articles.",
    ),
  ],
  't-tenses': [
    const Question(
      id: 'q-t1',
      text: 'Which tense is correct: I ___ to school every day.',
      options: ['go', 'went', 'going', 'goes'],
      correctIndex: 0,
      explanation: "Use simple present for regular actions.",
    ),
    const Question(
      id: 'q-t2',
      text: 'Which tense is correct: She ___ a book when I called.',
      options: ['read', 'reads', 'was reading', 'has read'],
      correctIndex: 2,
      explanation: "Use past continuous for an action in progress in the past.",
    ),
  ],
  't-prepositions': [
    const Question(
      id: 'q-p1',
      text: 'Fill in the blank: I arrived ___ the airport.',
      options: ['in', 'at', 'on', 'to'],
      correctIndex: 1,
      explanation: "Use 'at' with specific locations like airport, station.",
    ),
    const Question(
      id: 'q-p2',
      text: 'Fill in the blank: The book is ___ the table.',
      options: ['in', 'at', 'on', 'under'],
      correctIndex: 2,
      explanation: "Use 'on' for surfaces.",
    ),
  ],
};
