# Project Prompt — Flutter (Web) Version

**Goal:** Reproduce the exact same feature set and behavior you described for the iOS SwiftUI app — but implemented as a **Flutter web application** (single codebase for web). Keep the UI/UX, screens, flows and mock-first architecture the same; only adapt platform-specific parts to Flutter and web-friendly libraries/services. Deliverable is a complete specification / prompt that a Flutter dev (or team) can implement.

---

# Required Tech / Libraries (suggested)

* Flutter SDK (stable) targeting web (and mobile-ready if desired).
* State management: Provider / Riverpod / flutter_bloc (choose one — spec will use `flutter_bloc` in examples).
* Routing: `go_router` or Navigator 2.0 with a Coordinator-like abstraction (spec uses `go_router` for simplicity with web deep links).
* HTTP: `dio` (with an abstraction layer for mocks).
* Audio:

  * Playback: `just_audio` (supports web via `audio_service` or `html` backend)
  * Recording (web): use `flutter_web_plugins` + JS interop or packages like `record_web` (abstract behind `AudioRecorder` service so mobile/native recording can be plugged later).
* Storage: local in-memory or `shared_preferences` (for mock session/account storage), and local file assets for audio.
* Lottie: `lottie` package.
* UI: Flutter widgets, responsive layout for web.
* Testing: unit tests and widget tests; mocks via `mocktail` / `mockito`.

All services must be injected (DI) so mock implementations can be swapped for real implementations later.

---

# Deliverables (what the prompt should produce)

Create a feature spec and acceptance-criteria document for developers that includes:

* New UI elements and screens (names, routes, behaviors).
* ViewModels/State classes and responsibilities.
* Services/managers (interfaces + mock behavior).
* Navigation routes (paths) for web deep links.
* Data models for flashcards, grammar tests, audio items, users.
* Mock data examples.
* Important UI/UX details (button positions, enabled/disabled state, statistics).
* File / widget name suggestions to keep implementation consistent.

---

# Full Feature Specification (Flutter Web)

## App-wide rules

* Keep MVVM-like separation: Widget (View) ↔ ViewModel (business logic, streams/state) ↔ Repositories / Managers (network, audio, auth, storage) ↔ Models.
* Use `go_router` (or Navigator 2.0) so each screen has a meaningful URL path. Example paths:

  * `/` → main screen
  * `/flashcards` → FlashCards main
  * `/flashcards/add-word` → Add new word
  * `/flashcards/add-group` → Add new group
  * `/flashcards/group/:groupId` → MemoriseWords
  * `/learn` → Learn screen
  * `/learn/grammar-topics` → Grammar topics
  * `/learn/test/:topicId` → Test screen
  * `/learn/listening` → ListeningPractice
  * `/auth/signin` → Sign In
  * `/auth/signup` → Sign Up
* All network calls are mocked through a `NetworkRepository` interface. Provide `MockNetworkRepository` that returns deterministic data; replaceable by `HttpNetworkRepository` later.
* All audio is loaded from local assets initially; use `AudioRepository` interface for future remote switching.

---

## Naming convention for widgets / files (suggested)

* Screens / Pages (widgets): `MainScreen`, `FlashCardsScreen`, `AddNewWordScreen`, `AddNewGroupScreen`, `MemoriseWordsScreen`, `LearnScreen`, `GrammarTopicsScreen`, `TestScreen`, `ListeningPracticeScreen`, `SignInScreen`, `SignUpScreen`, `ArticlesPreviewScreen`, `ArticleScreen`, `ArticleAnalysisScreen`, `SpeakingTopicsScreen`, `RecordingScreen`, `SpeakingAssessmentScreen`.
* ViewModels: `MainViewModel`, `FlashCardsViewModel`, `MemoriseViewModel`, `LearnViewModel`, `TestViewModel`, `ListeningViewModel`, `AuthViewModel`, `ArticlesViewModel`, `SpeechViewModel`.
* Repositories/Managers: `NetworkManager` (interface), `MockNetworkManager`, `AudioManager` (interface), `LocalAudioManager`, `RecorderManager` (interface), `WebRecorderManager`, `AuthManager` (interface), `MockAuthManager`.
* Models: `WordGroup`, `FlashCard`, `GrammarTopic`, `Question`, `AnswerOption`, `AudioRecord`, `User`.

---

# Task 1 — Flash Cards (exact same functionality adapted to Flutter web)

### Entry

* Add a **purple UI element** on the `MainScreen` (matching the design in `Screenshots/MainScreen.png`). Tapping opens route `/flashcards`.

### FlashCardsScreen (route `/flashcards`)

**UI**

* `AppBar` / top area: include a `ToolbarItem` on the `.topLeading` edge — implement as an `IconButton` (plus icon) placed in the leading area.

  * Tapping the plus button opens `/flashcards/add-word` (`AddNewWordScreen`).
* Add an overlay floating button aligned `.bottomRight`:

  * Small circular `FloatingActionButton` with a folder icon.
  * Tapping opens `/flashcards/add-group` (`AddNewGroupScreen`).
* Main content: a list of **word groups** (e.g., Travel, Education, Cafe). Each group shows group name and number of words.
* Tapping a group navigates to `/flashcards/group/:groupId` (`MemoriseWordsScreen`) and passes the selected group id.

**Data**

* `FlashCardsViewModel` provides `List<WordGroup>` via stream or state notifier.
* Groups and words are stored in-memory for the mock with the ability to persist (e.g., local `shared_preferences`) later.

### AddNewWordScreen (`/flashcards/add-word`)

**Design (match `Screenshots/AddNewWord.png`)**

* Fields:

  * **Word** (required)
  * **Transcription** (optional)
  * **Translation** (required — into user’s chosen language)
  * **Group selector** (dropdown/select). Shows existing groups and option to "Create new group" which navigates to AddNewGroup.
* Save button:

  * Validates required fields.
  * Adds the word to the selected group via `FlashCardsViewModel.addWord`.
  * On success, return to `/flashcards` or the group screen.

### AddNewGroupScreen (`/flashcards/add-group`)

**UI**

* Single text field to input group name.
* Save button: validates non-empty name, calls `FlashCardsViewModel.addGroup`, then navigates back to `/flashcards` and updates UI.

### MemoriseWordsScreen (`/flashcards/group/:groupId`)

**Design reference:** `Screenshots/MemoriseWords.png`
**Functionality**

* Show **one flash card at a time** with:

  * Word
  * Transcription
  * A **reveal translation** button (tapping reveals translation on the card)
* Below the card: `HStack` equivalent — a `Row` containing two buttons:

  * **Don't Know**
  * **Know**
* Pressing either advances to the **next word** in the group.
* The screen must only show words that belong to the selected group.
* When all words are shown:

  * Replace the card area with **statistics**:

    * Count of words user **knew**
    * Count of words user **did not know**
  * Optionally a button to **Restart** or return to group list.

**State management**

* `MemoriseViewModel` handles:

  * the current word index
  * counts of known/unknown
  * reveal state
  * next word flow

**Edge cases**

* If group has no words — show empty state with CTA to add words.

---

# Task 2 — Grammar Tests (via new “Learn” tab bar item)

### Tab Bar

* Add a new tab (or navigation item) to the app shell:

  * Title: **Learn**
  * Icon: appropriate education icon (use material icon `menu_book` or similar)
  * Clicking opens `/learn` (`LearnScreen`) — for web this is a route.

### LearnScreen (`/learn`)

**Design:** match `Screenshots/Learn.png`

* Contains list with **two rows**:

  * **Listening Practice**

    * Navigates to `/learn/listening` (`ListeningPracticeScreen`) — Task 3.
  * **Tests**

    * Navigates to `/learn/grammar-topics` (`GrammarTopicsScreen`). For Task 2 implement the Tests row behavior only.

### GrammarTopicsScreen (`/learn/grammar-topics`)

* Shows list of grammar topics (mock sample: Articles, Tenses, Prepositions).
* `GrammarTopicsViewModel` supplies a mock list of `GrammarTopic` objects (id, title, description, sample question count).
* Tapping any topic navigates to `/learn/test/:topicId`.

### TestScreen (`/learn/test/:topicId`)

**Design reference:** `Screenshots/Test.png`
**UI Structure**

* **Test Card** (top)

  * Displays the question text
  * Displays the answer options (radio list — single choice)
  * `Check` button — disabled until user selects an answer
* **Result Card** (appears after Check)

  * Shows Correct / Incorrect
  * If incorrect, show the correct answer (and optionally a short explanation)
  * Contains a `Continue` button

**Behavior / Logic**

* `TestViewModel` loads mock `List<Question>` for the topic (questions contain text, options, correct option index, optional explanation).
* Flow:

  1. User reads question and selects an option.
  2. User taps **Check**.
  3. Result card appears below the question card showing Correct/Incorrect and correct answer if needed.
  4. User taps **Continue**:

     * If more questions: show next question; reset UI state (no selected answer shown until user picks one again and Check is enabled after selection).
     * If all questions done: show **Summary card**.
* **Summary card**:

  * How many correct
  * How many incorrect
  * Option to retake or return to topics

**State**

* `TestViewModel` tracks:

  * currentQuestionIndex
  * selectedOptionIndex
  * answersRecord (list of booleans or a structured result)
  * UI flags to show result card

---

# Task 3 — Listening Practice (web audio player + list)

### ListeningPracticeScreen (`/learn/listening`)

**Design reference:** `Screenshots/ListeningPractice.png`
**Layout**

* **Audio Player Card** at top:

  * Shows selected audio title
  * Play / Pause button
  * Seek backward 10s
  * Seek forward 10s
  * Current time and total duration
  * Progress bar (scrubber) optional but recommended
* **List of Audio Records** below:

  * Scrollable list of audio items with title and duration/difficulty icon
  * Tapping selects the audio and updates the player card

**Audio Management**

* Use `AudioManager` abstraction:

  * `LocalAudioManager` loads files from `assets/audio/…` for web
  * Expose methods: `load(AudioRecord)`, `play()`, `pause()`, `seek(Duration)`, `seekForward(10s)`, `seekBackward(10s)`, `positionStream`, `durationStream`, `playbackStateStream`.
* Use `just_audio` or Web Audio API via package that supports web. All player interactions must be handled inside the `AudioManager` so switching to remote URLs (via `NetworkManager`) is straightforward.
* When screen opens show first audio or last selected (persist last selection in `SharedPreferences` or in-memory for mock).

**Behavior**

* Selecting an item updates the audio player card.
* Playback controls operate entirely within the audio card.
* Playback state updates in real time (position, duration).
* Seeking accuracy is required (seek by exact seconds).
* Architecture must make it easy to swap `LocalAudioManager` with `RemoteAudioManager`.

---

# Task 4 — Sign In Screen

### SignInScreen (`/auth/signin`)

**Design reference:** `Screenshots/SignIn.png`
**UI**

* Email TextField

  * Placeholder: `Email`
  * Validation: basic email format (regex / simple `@` check)
* Password TextField

  * Placeholder: `Password`
  * Secure entry
  * Optional show/hide toggle
* Sign In Button

  * Disabled until both fields valid
  * On tap, call `AuthViewModel.signIn(email, password)` using `MockAuthManager`
* Navigation text:

  * `Don't have an account? Sign up` — `Sign up` tappable → `/auth/signup`

**Behavior**

* Validate inputs locally
* Mock authentication via `MockAuthManager.signIn(email, password)`:

  * On success: mark session state in `AuthManager` and navigate into main app (home route `/`)
  * On failure: show error message `Invalid credentials`
* `AuthManager` must be replaceable by a real backend integration later.

---

# Task 5 — Sign Up Screen

### SignUpScreen (`/auth/signup`)

**Design reference:** `Screenshots/SignUp.png`
**UI**

* Email field (placeholder: `Email`) — basic format validation
* Password field (placeholder: `Password`) — secure entry, optional toggle
* Repeat password field (placeholder: `Repeat password`) — secure entry; must match password
* Sign Up button — **disabled** until:

  * email valid,
  * password not empty,
  * password equals repeat password
* Navigation text: `Already have an account? Sign in` → navigates back to `/auth/signin`

**Behavior**

* `AuthViewModel.signUp(email, password)` calls `MockAuthManager.signUp`
* `MockAuthManager`:

  * Stores users in-memory (or in `shared_preferences` for mock persistence)
  * If email already exists: return error `Email already registered`
  * On success: log in user and navigate into main app
* Ensure minimal refactor path for integrating real auth providers (Firebase, OAuth, JWT).

---

# Speech Assessment & Articles (existing functionality)

* Keep existing Speech Assessment and Articles modules, mapping SwiftUI screens to Flutter widgets with the same names and behavior:

  * `SpeakingTopicsScreen`, `RecordingScreen`, `SpeakingAssessmentScreen`
  * `ArticlesPreviewScreen`, `ArticleScreen`, `ArticleAnalysisScreen`
* Recording for speech assessment must work in browser (use `WebRecorderManager`) and be abstracted behind `RecorderManager` interface for future mobile support.

---

# Mock Data Examples (must be included with the prompt)

Provide initial mock datasets:

**Flashcards**

```json
[
  {
    "id": "g-travel",
    "title": "Travel",
    "words": [
      { "id": "w-1", "word": "luggage", "transcription": "ˈlʌɡ.ɪdʒ", "translation": "багаж" },
      { "id": "w-2", "word": "departure", "transcription": "dɪˈpɑːr.tʃər", "translation": "відправлення" }
    ]
  },
  {
    "id": "g-cafe",
    "title": "Cafe",
    "words": [
      { "id": "w-10", "word": "barista", "transcription": "bəˈriː.stə", "translation": "бариста" }
    ]
  }
]
```

**Grammar Topics**

```json
[
  { "id": "t-articles", "title": "Articles", "questions": 10 },
  { "id": "t-tenses", "title": "Tenses", "questions": 12 },
  { "id": "t-prepositions", "title": "Prepositions", "questions": 8 }
]
```

**Sample Question**

```json
{
  "id": "q-1",
  "text": "Choose the correct article: ___ apple a day keeps the doctor away.",
  "options": ["A", "An", "The", "No article"],
  "correctIndex": 1,
  "explanation": "'apple' starts with a vowel sound — use 'An'."
}
```

**Listening audio list** (local asset names)

```json
[
  { "id": "a-1", "title": "Travel Dialogue 1", "asset": "assets/audio/travel_dialogue_1.mp3", "duration": "02:10" },
  { "id": "a-2", "title": "Shopping Listening Exercise 2", "asset": "assets/audio/shopping_2.mp3", "duration": "01:45" }
]
```

**Mock users for Auth**

```json
[
  { "email": "test@example.com", "password": "Password123" }
]
```

---

# ViewModel & Service Interfaces (brief)

**FlashCardsViewModel**

* `Stream<List<WordGroup>> groups`
* `addGroup(name)`, `addWord(groupId, FlashCard)`, `getWordsForGroup(groupId)`

**MemoriseViewModel**

* `currentWord`, `revealTranslation()`, `markKnown()`, `markUnknown()`, `reset()`, `statistics`

**TestViewModel**

* `loadTopic(topicId)`, `currentQuestion`, `selectOption(index)`, `checkAnswer()`, `continue()`, `summary`

**ListeningViewModel**

* `List<AudioRecord> records`, `selectRecord(id)`, `play()`, `pause()`, `seekBy(seconds)`, streams for position/duration

**AuthViewModel**

* `signIn(email, password) -> Result`
* `signUp(email, password) -> Result`
* `sessionStateStream`

**NetworkManager interface**

* `Future<List<GrammarTopic>> getGrammarTopics()`
* `Future<List<Question>> getQuestions(topicId)`
* `Future<List<WordGroup>> getFlashcardGroups()`
* Implement `MockNetworkManager` with the mock data above.

**AudioManager / RecorderManager**

* `AudioManager`: `load(AudioRecord)`, `play()`, `pause()`, `seek`, streams
* `RecorderManager` (for speech assessment): `startRecording()`, `stopRecording()` → returns audio blob / URL (web-friendly)

---

# UI / Accessibility / Responsiveness

* Make UI responsive for web widths (desktop and tablet widths). Components should center and scale, but visual layout should match mobile screenshots in proportions.
* Provide keyboard accessibility for web (tab navigation, Enter key for buttons).
* Use semantic widgets (a11y) where possible.

---

# Acceptance Criteria — per Task (short)

**Task 1 — Flashcards**

* Purple element opens `/flashcards`.
* Toolbar plus button opens Add New Word.
* Bottom-right folder button opens Add New Group.
* Group list displays and tapping opens memorisation screen that shows only words from that group.
* Add, create group, and memorise flows work with mock data and show final statistics.

**Task 2 — Grammar Tests**

* Learn tab exists in shell and opens `/learn`.
* Tapping Tests → `/learn/grammar-topics` with mock topics.
* Topic → `/learn/test/:topicId` flow implemented with Check button enabling, result card displayed, Continue navigates to next question and summary at end.

**Task 3 — Listening Practice**

* `/learn/listening` shows player + list.
* Selecting item loads it to player.
* Play/pause/seek forward/back work and UI updates in real-time.
* Implementation uses `AudioManager` abstraction with local assets.

**Task 4 — Sign In**

* `/auth/signin` with email/password validation.
* Sign-in button disabled until valid.
* Mock AuthManager authenticates or shows error.

**Task 5 — Sign Up**

* `/auth/signup` with email + password + repeat.
* Sign up button disabled until validation passes.
* Duplicate email error handled by mock.

---
