# Bug Fixes Implementation Plan

This document provides a prioritized, actionable plan to fix all identified bugs.

## Quick Reference

| Priority | Bug | File | Impact | Complexity |
|----------|-----|------|--------|------------|
| 🔴 P0 | SpeechCubit not disposed | `service_locator.dart` | Memory leak | Easy |
| 🔴 P0 | ListeningCubit disposes shared manager | `listening_cubit.dart` | Crashes | Easy |
| 🔴 P0 | Duplicate AuthCubit | `main_screen.dart` | State inconsistency | Easy |
| 🟠 P1 | Dangerous navigation loop | `speaking_assessment_screen.dart` | Navigation bugs | Easy |
| 🟠 P1 | Auth error state lost | `auth_cubit.dart` | Poor UX | Medium |
| 🟡 P2 | Debug print statements | 6 files | Performance, logs | Easy |
| 🟡 P2 | getWordsForGroup error handling | `flashcards_cubit.dart` | Data issues | Medium |
| 🟡 P2 | Build-time navigation | `recording_screen.dart` | Anti-pattern | Medium |
| 🟡 P2 | Missing error handling | Multiple cubits | Crashes | Easy |
| 🟢 P3 | Code quality issues | Multiple files | Maintenance | Easy |

---

## Phase 1: Critical Fixes (P0) - **Must Do First**

### Fix 1: Dispose SpeechCubit

**File**: `lib/core/di/service_locator.dart`

```dart
// BEFORE (lines 54-60)
void dispose() {
  if (authManager is MockAuthManager) {
    (authManager as MockAuthManager).dispose();
  }
  audioManager.dispose();
  recorderManager.dispose();
}

// AFTER
void dispose() {
  if (authManager is MockAuthManager) {
    (authManager as MockAuthManager).dispose();
  }
  audioManager.dispose();
  recorderManager.dispose();

  // Dispose singleton cubit
  if (_isInitialized) {
    _speechCubit.close();
  }
}
```

---

### Fix 2: Don't Dispose Shared AudioManager

**File**: `lib/presentation/learn/cubit/listening_cubit.dart`

```dart
// BEFORE (lines 166-172)
@override
Future<void> close() async {
  await _cancelSubscriptions();
  _audioManager.dispose(); // ❌ Wrong!
  return super.close();
}

// AFTER
@override
Future<void> close() async {
  await _cancelSubscriptions();
  // Stop playback but don't dispose shared manager
  try {
    await _audioManager.pause();
  } catch (e) {
    // Ignore errors during cleanup
  }
  return super.close();
}
```

---

### Fix 3: Remove Duplicate AuthCubit

**File**: `lib/presentation/main/screens/main_screen.dart`

```dart
// BEFORE (lines 10-20)
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(sl.authManager), // ❌ Duplicate!
      child: const _MainContent(),
    );
  }
}

// AFTER
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthCubit already provided by AppShell
    return const _MainContent();
  }
}
```

**Also update**: Remove the import of AuthCubit from line 6 since it's no longer used.

---

## Phase 2: High Priority Fixes (P1)

### Fix 4: Replace Navigation Loop

**File**: `lib/presentation/speaking/screens/speaking_assessment_screen.dart`

```dart
// BEFORE (lines 122-128)
Expanded(
  child: ElevatedButton.icon(
    onPressed: () {
      context.read<SpeechCubit>().backToTopics();
      // Pop until back to topics screen
      while (context.canPop()) { // ❌ Dangerous!
        context.pop();
      }
    },
    icon: const Icon(Icons.home),
    label: const Text('Back to Topics'),
  ),
),

// AFTER
Expanded(
  child: ElevatedButton.icon(
    onPressed: () {
      context.read<SpeechCubit>().backToTopics();
      // Navigate directly to topics
      context.go(Routes.speakingTopics);
    },
    icon: const Icon(Icons.home),
    label: const Text('Back to Topics'),
  ),
),
```

**Import needed**: `import '../../../core/routing/route_names.dart';`

---

### Fix 5: Keep Auth Error State

**File**: `lib/presentation/auth/cubit/auth_cubit.dart`

```dart
// BEFORE (lines 28-38)
Future<void> signIn(String email, String password) async {
  try {
    emit(const AuthLoading());
    final user = await _authManager.signIn(email, password);
    emit(AuthAuthenticated(user));
  } catch (e) {
    emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    emit(const AuthUnauthenticated()); // ❌ Immediately overwrites error!
  }
}

// AFTER
Future<void> signIn(String email, String password) async {
  try {
    emit(const AuthLoading());
    final user = await _authManager.signIn(email, password);
    emit(AuthAuthenticated(user));
  } catch (e) {
    // Keep error state - UI will handle transition
    emit(AuthError(e.toString().replaceAll('Exception: ', '')));
  }
}
```

**Apply same fix to**:
- `signUp()` method (lines 41-50)
- `signOut()` method (lines 53-60)

**Update UI**: Make sure sign-in screen shows error and has "Try Again" button that clears error.

---

## Phase 3: Medium Priority Fixes (P2)

### Fix 6: Remove Debug Print Statements

**Option A - Remove All** (Recommended for production):
1. `lib/core/routing/app_router.dart:206` - Remove entire line
2. `lib/presentation/main/screens/main_screen.dart:118` - Remove entire line
3. `lib/presentation/speaking/cubit/speech_cubit.dart` - Remove lines 24, 26, 28, 30, 32, 115, 120, 124, 127, 133, 136
4. `lib/presentation/speaking/screens/speaking_topics_screen.dart` - Remove lines 29, 32
5. `lib/presentation/speaking/screens/recording_screen.dart:35` - Remove entire line
6. `lib/presentation/speaking/screens/speaking_assessment_screen.dart:23` - Remove entire line

**Option B - Make Conditional** (For debugging):
```dart
// Add to each file
import 'package:flutter/foundation.dart';

// Replace print() with:
if (kDebugMode) {
  debugPrint('Your debug message');
}
```

---

### Fix 7: Fix getWordsForGroup Error Handling

**File**: `lib/presentation/flashcards/cubit/flashcards_cubit.dart`

```dart
// BEFORE (lines 72-79)
Future<List<FlashCard>> getWordsForGroup(String groupId) async {
  try {
    return await _networkRepository.getWordsForGroup(groupId);
  } catch (e) {
    emit(FlashCardsError('Failed to load words: ${e.toString()}'));
    return []; // ⚠️ Silent failure
  }
}

// AFTER (Option 1 - Throw error)
Future<List<FlashCard>> getWordsForGroup(String groupId) async {
  try {
    return await _networkRepository.getWordsForGroup(groupId);
  } catch (e) {
    emit(FlashCardsError('Failed to load words: ${e.toString()}'));
    rethrow; // Let caller handle
  }
}

// AFTER (Option 2 - Use state pattern - Recommended)
// Remove this method entirely and update callers to use state
```

**If using Option 2**, update `MemoriseCubit.loadGroup()` to not call this method.

---

### Fix 8: Move Navigation Out of Build

**File**: `lib/presentation/speaking/screens/recording_screen.dart`

```dart
// BEFORE (lines 27-38)
body: BlocConsumer<SpeechCubit, SpeechState>(
  listenWhen: (previous, current) {
    return current is SpeechAssessmentProcessing && previous is! SpeechAssessmentProcessing;
  },
  listener: (context, state) {
    if (state is SpeechAssessmentProcessing) {
      print('DEBUG: Navigating to assessment screen');
      context.push(Routes.assessment);
    }
  },
  builder: (context, state) {
    // ... (lines 40-74)

    // ❌ Remove this block (lines 76-84)
    if (state is! SpeechRecordingIdle &&
        state is! SpeechRecording &&
        state is! SpeechRecordingStopped) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pop();
      });
      return const SizedBox.shrink();
    }

// AFTER - Add second listener
body: BlocConsumer<SpeechCubit, SpeechState>(
  listenWhen: (previous, current) {
    // Listen for navigation to assessment
    if (current is SpeechAssessmentProcessing && previous is! SpeechAssessmentProcessing) {
      return true;
    }
    // Listen for invalid states
    if (current is! SpeechRecordingIdle &&
        current is! SpeechRecording &&
        current is! SpeechRecordingStopped &&
        current is! SpeechError) {
      return true;
    }
    return false;
  },
  listener: (context, state) {
    if (state is SpeechAssessmentProcessing) {
      context.push(Routes.assessment);
    } else if (state is! SpeechRecordingIdle &&
               state is! SpeechRecording &&
               state is! SpeechRecordingStopped &&
               state is! SpeechError) {
      // Invalid state - go back
      context.pop();
    }
  },
  builder: (context, state) {
    // Remove the redirect block from builder
    if (state is SpeechError) {
      // Show error
    }

    // Continue with normal rendering
```

---

### Fix 9: Add Error Handling to Stream Cancellations

**File**: `lib/presentation/speaking/cubit/speech_cubit.dart`

```dart
// BEFORE (lines 74-76)
await _durationSubscription?.cancel();
_durationSubscription = null;

// AFTER
try {
  await _durationSubscription?.cancel();
} catch (e) {
  // Ignore errors during cleanup
}
_durationSubscription = null;
```

**Apply same pattern to**:
- `lib/presentation/learn/cubit/listening_cubit.dart:157-164`

---

## Phase 4: Low Priority / Code Quality (P3)

These can be addressed during normal development:

1. **TODO comments**: Create GitHub issues, remove TODOs from code
2. **Error messages**: Standardize format across all cubits
3. **Magic numbers**: Extract to constants
4. **Unused parameters**: Remove `fullName` param or use it
5. **Average calculation**: Use double division
6. **Bottom nav logic**: Clarify with comments or extract to method

---

## Testing Checklist

After implementing fixes, verify:

### Critical Fixes
- [ ] No memory leaks: Use Flutter DevTools Memory tab
- [ ] AudioManager works after closing ListeningCubit
- [ ] MainScreen shows correct auth state

### High Priority Fixes
- [ ] "Back to Topics" navigates correctly
- [ ] Auth errors are displayed to user
- [ ] User can retry after auth error

### Medium Priority Fixes
- [ ] No console output in release mode
- [ ] All navigation flows work correctly
- [ ] Error states display properly

### Integration Tests
- [ ] Complete speaking practice flow (topics → record → assessment → results)
- [ ] Sign in with wrong password shows error
- [ ] Navigate between all tabs
- [ ] FlashCards CRUD operations

---

## Estimated Time

| Phase | Tasks | Time Estimate |
|-------|-------|---------------|
| Phase 1 (P0) | 3 critical fixes | 30 minutes |
| Phase 2 (P1) | 2 high priority | 1 hour |
| Phase 3 (P2) | 4 medium priority | 2 hours |
| Phase 4 (P3) | Code quality | 1 hour |
| **Total** | **15 fixes** | **~4.5 hours** |

Plus testing: 1-2 hours

---

## Implementation Order

1. ✅ **Start with Phase 1** - These are critical and easy
2. ✅ **Test after each fix** - Don't accumulate fixes
3. ✅ **Commit after each phase** - Makes rollback easier
4. ✅ **Run full test suite** - Before moving to next phase
5. ✅ **Phase 4 can be gradual** - Include in regular development

---

**Good luck with the fixes! 🚀**
