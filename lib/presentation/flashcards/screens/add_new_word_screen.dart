import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web_yazichok/core/routing/route_names.dart';
import 'package:web_yazichok/data/models/flash_card.dart';
import 'package:web_yazichok/data/models/word_group.dart';
import 'package:web_yazichok/presentation/flashcards/cubit/flashcards_cubit.dart';
import 'package:web_yazichok/presentation/flashcards/cubit/flashcards_state.dart';

/// Screen for adding a new word to a group
class AddNewWordScreen extends StatefulWidget {
  const AddNewWordScreen({super.key});

  @override
  State<AddNewWordScreen> createState() => _AddNewWordScreenState();
}

class _AddNewWordScreenState extends State<AddNewWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _transcriptionController = TextEditingController();
  final _translationController = TextEditingController();

  String? _selectedGroupId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _wordController.dispose();
    _transcriptionController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  Future<void> _saveWord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a group'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final word = FlashCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        word: _wordController.text.trim(),
        transcription: _transcriptionController.text.trim().isNotEmpty
            ? _transcriptionController.text.trim()
            : null,
        translation: _translationController.text.trim(),
      );

      await context.read<FlashCardsCubit>().addWord(_selectedGroupId!, word);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Word added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add word: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Word'),
      ),
      body: BlocConsumer<FlashCardsCubit, FlashCardsState>(
        listener: (context, state) {
          if (state is FlashCardsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          List<WordGroup> groups = [];
          if (state is FlashCardsLoaded) {
            groups = state.groups;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'Add a new word',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add new vocabulary to your learning collection',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Word field (required)
                  TextFormField(
                    controller: _wordController,
                    decoration: InputDecoration(
                      labelText: 'Word *',
                      hintText: 'Enter the word in English',
                      prefixIcon: const Icon(Icons.abc),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    autofocus: true,
                    enabled: !_isSubmitting,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a word';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Transcription field (optional)
                  TextFormField(
                    controller: _transcriptionController,
                    decoration: InputDecoration(
                      labelText: 'Transcription',
                      hintText: 'e.g., /həˈloʊ/',
                      prefixIcon: const Icon(Icons.record_voice_over),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // Translation field (required)
                  TextFormField(
                    controller: _translationController,
                    decoration: InputDecoration(
                      labelText: 'Translation *',
                      hintText: 'Translation in your language',
                      prefixIcon: const Icon(Icons.translate),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    enabled: !_isSubmitting,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a translation';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Group selector dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedGroupId,
                    decoration: InputDecoration(
                      labelText: 'Group *',
                      prefixIcon: const Icon(Icons.folder),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    hint: const Text('Select a group'),
                    items: [
                      // Create new group option
                      const DropdownMenuItem<String>(
                        value: 'create_new',
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 20),
                            SizedBox(width: 8),
                            Text('Create new group'),
                          ],
                        ),
                      ),
                      // Divider
                      if (groups.isNotEmpty)
                        const DropdownMenuItem<String>(
                          enabled: false,
                          value: 'divider',
                          child: Divider(),
                        ),
                      // Existing groups
                      ...groups.map((group) {
                        return DropdownMenuItem<String>(
                          value: group.id,
                          child: Text(group.title),
                        );
                      }),
                    ],
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            if (value == 'create_new') {
                              // Navigate to create group screen
                              context.push(RouteNames.flashcardsAddGroup).then((_) {
                                // Reload groups after returning
                                context.read<FlashCardsCubit>().loadGroups();
                              });
                            } else if (value != 'divider') {
                              setState(() {
                                _selectedGroupId = value;
                              });
                            }
                          },
                    validator: (value) {
                      if (value == null || value == 'create_new' || value == 'divider') {
                        return 'Please select a group';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '* Required fields',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _saveWord,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save Word',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
