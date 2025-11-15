import '../models/speaking_topic.dart';

/// Mock speaking topics from plan.md
final List<SpeakingTopic> mockSpeakingTopics = [
  const SpeakingTopic(
    id: 'st-1',
    title: 'Describe your favorite vacation',
    description:
        'Talk about a memorable trip you took. Include details about the destination, activities, and why it was special.',
    difficulty: 'intermediate',
    timeLimit: 120,
  ),
  const SpeakingTopic(
    id: 'st-2',
    title: 'Discuss your daily routine',
    description: 'Describe a typical day in your life from morning to evening.',
    difficulty: 'beginner',
    timeLimit: 90,
  ),
  const SpeakingTopic(
    id: 'st-3',
    title: 'Explain a hobby or interest',
    description:
        'Talk about something you enjoy doing in your free time. Why do you like it?',
    difficulty: 'intermediate',
    timeLimit: 120,
  ),
  const SpeakingTopic(
    id: 'st-4',
    title: 'Your dream job',
    description:
        'Describe your ideal career. What would you do? Why is it appealing to you?',
    difficulty: 'intermediate',
    timeLimit: 120,
  ),
  const SpeakingTopic(
    id: 'st-5',
    title: 'Technology in daily life',
    description:
        'How has technology changed the way you live? Give specific examples.',
    difficulty: 'advanced',
    timeLimit: 150,
  ),
];
