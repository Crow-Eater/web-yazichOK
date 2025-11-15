import 'package:flutter/material.dart';
import 'package:web_yazichok/data/models/flash_card.dart';

/// Widget for displaying a flashcard with word, transcription, and translation
class FlashcardWidget extends StatelessWidget {
  final FlashCard flashCard;
  final bool isTranslationRevealed;
  final VoidCallback onRevealTranslation;

  const FlashcardWidget({
    super.key,
    required this.flashCard,
    required this.isTranslationRevealed,
    required this.onRevealTranslation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: 500,
        minHeight: size.height * 0.4,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Word
          Text(
            flashCard.word,
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          // Transcription
          if (flashCard.transcription != null) ...[
            const SizedBox(height: 16),
            Text(
              flashCard.transcription!,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 32),

          // Translation reveal section
          if (isTranslationRevealed) ...[
            // Divider
            Container(
              width: 100,
              height: 2,
              color: Colors.white.withOpacity(0.5),
              margin: const EdgeInsets.only(bottom: 24),
            ),
            // Translation
            Text(
              flashCard.translation,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            // Reveal button
            OutlinedButton.icon(
              onPressed: onRevealTranslation,
              icon: const Icon(Icons.visibility, color: Colors.white),
              label: const Text(
                'Reveal Translation',
                style: TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
