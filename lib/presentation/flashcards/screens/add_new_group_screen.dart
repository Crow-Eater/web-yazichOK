import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web_yazichok/presentation/flashcards/cubit/flashcards_cubit.dart';
import 'package:web_yazichok/presentation/flashcards/cubit/flashcards_state.dart';

/// Screen for adding a new word group
class AddNewGroupScreen extends StatefulWidget {
  const AddNewGroupScreen({super.key});

  @override
  State<AddNewGroupScreen> createState() => _AddNewGroupScreenState();
}

class _AddNewGroupScreenState extends State<AddNewGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _saveGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await context.read<FlashCardsCubit>().addGroup(_groupNameController.text.trim());

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group created successfully'),
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
            content: Text('Failed to create group: ${e.toString()}'),
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
        title: const Text('Add New Group'),
      ),
      body: BlocListener<FlashCardsCubit, FlashCardsState>(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Create a new word group',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Groups help you organize your vocabulary by topics',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),

                // Group name field
                TextFormField(
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    labelText: 'Group Name',
                    hintText: 'e.g., Travel, Education, Cafe',
                    prefixIcon: const Icon(Icons.folder),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  autofocus: true,
                  enabled: !_isSubmitting,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a group name';
                    }
                    if (value.trim().length < 2) {
                      return 'Group name must be at least 2 characters';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _saveGroup(),
                ),
                const SizedBox(height: 32),

                // Save button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveGroup,
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
                          'Create Group',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
