import '../models/audio_record.dart';

/// Mock audio records for listening practice from plan.md
final List<AudioRecord> mockAudioRecords = [
  const AudioRecord(
    id: 'a-1',
    title: 'Travel Dialogue 1',
    asset: 'assets/audio/travel_dialogue_1.mp3',
    duration: '02:10',
    difficulty: 'intermediate',
  ),
  const AudioRecord(
    id: 'a-2',
    title: 'Shopping Listening Exercise 2',
    asset: 'assets/audio/shopping_2.mp3',
    duration: '01:45',
    difficulty: 'beginner',
  ),
  const AudioRecord(
    id: 'a-3',
    title: 'Restaurant Conversation',
    asset: 'assets/audio/restaurant.mp3',
    duration: '02:30',
    difficulty: 'intermediate',
  ),
  const AudioRecord(
    id: 'a-4',
    title: 'Job Interview Practice',
    asset: 'assets/audio/job_interview.mp3',
    duration: '03:15',
    difficulty: 'advanced',
  ),
];
