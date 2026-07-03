# 🚀 LexiQ – AI-Powered Vocabulary Builder & Quiz App

> **Turn passive word-saving into active learning.** LexiQ helps students build a personal vocabulary database, get AI-generated word insights, and test themselves with adaptive quizzes — all in one cross-platform app.

> **Live Demo:** https://siddharth177.github.io/LexiQ/

---

# Why LexiQ?

Most students preparing for GRE, TOEFL, GMAT, or competitive exams encounter the same bottleneck: they passively highlight words but never revisit them.

LexiQ closes that loop by combining:

- **Intelligent word discovery**
- **Personal knowledge management**
- **AI-driven assessment**

into a single, beautifully designed mobile application.

This project was built entirely from scratch as a self-initiated product — from identifying the user problem, to designing the system architecture, to shipping a production-ready cross-platform application integrated with real AI inference APIs.

---

# Key Features

### 📚 Smart Vocabulary Management

- Add words to a cloud-synced personal dictionary
- AI-generated definitions, word types, etymological roots, usage examples, and tense variations powered by **Llama 3.3-70B via Groq API**
- Hear correct pronunciation with built-in **Text-to-Speech**
- Swipe to edit or delete — gesture-native UX

### 🧠 Adaptive AI Quiz Engine

- Generate MCQ quizzes from your **own saved vocabulary** or let AI create entirely new word sets
- 5-level difficulty dial (Basic → Advanced) for AI-generated quizzes
- Configurable timer per question — builds real exam conditions
- Post-quiz review with answer-by-answer breakdown

### 📊 Quiz History & Progress Tracking

- Every quiz result stored to the cloud with score, source, and per-question breakdown
- History cards with swipe-to-delete
- Tap any past result to revisit full review

### 🎨 Polished UX

- Full light / dark mode with adaptive theming
- Smooth Rive animations for loading states
- Responsive design — works on mobile, tablet, and web

---

# Screenshots

### Vocabulary List

![Vocab List Light](...)
![Vocab List](...)
![Vocab List Expanded](...)

### Word Detail (AI-Powered)

![Word Detail](https://github.com/user-attachments/assets/5b235081-e68b-4dd4-96e4-fddc7d68f303)

### Speak Aloud

![Speak Aloud](...)

### Dark Mode

![Dark Mode](...)
![Dark Mode 2](...)

### Quiz – Configure

```html
<!-- TODO: Add updated screenshot of Configure Quiz screen (dark mode, with slider) -->
<img width="492" height="670" alt="Configure Quiz" src="https://github.com/user-attachments/assets/bf1eb985-c40c-4623-9f0c-a266c79d8ba3" />
```

### Quiz – Active

```html
<!-- TODO: Add updated screenshot of active quiz screen -->
<img width="495" height="667" alt="Active Quiz" src="https://github.com/user-attachments/assets/174b5511-a1df-4671-8609-3f228d0edf4f" />
```

### Quiz – Review & History

```html
<!-- TODO: Add updated screenshot of quiz history -->
<img width="496" height="757" alt="Quiz History" src="https://github.com/user-attachments/assets/5e44bbe7-90e8-47a1-9214-04be342ec289" />

<!-- TODO: Add updated screenshot of quiz review -->
<img width="474" height="653" alt="Quiz Review" src="https://github.com/user-attachments/assets/3362c6d6-9269-4a9e-beab-f472571d6f58" />
```

---

# Technology Stack

| Layer | Technology / Role |
|------|--------------------|
| Frontend | Flutter (Dart) — Cross-platform UI (iOS, Android, Web) |
| State Management | Riverpod — Reactive, testable app state |
| Backend | Firebase Auth, Firestore, Authentication, Real-time cloud sync |
| AI Inference | Groq API (Llama 3.3-70B) — Word definitions, quiz generation |
| Animations | Rive — Lightweight vector animations |
| TTS | flutter_tts — Pronunciation playback |

---

# Architecture Highlights

- **Modular feature structure** — models, services, screens, widgets cleanly separated
- **Secure API key management** — Groq API key stored in Firestore (not in source code); gitignored secrets file for local development
- **Offline-resilient** — Firestore persistence layer handles intermittent connectivity
- **Provider pattern** — theme, auth state, and API keys managed via Riverpod (`FutureProvider` / `StateProvider`)

---

# Running Locally

```bash
# 1. Clone

git clone https://github.com/siddharth177/LexiQ.git

cd vocab-list

# 2. Install dependencies

flutter pub get

# 3. Add your secrets (gitignored)

Create lib/utils/secrets.dart:

const String kGroqApiKey = 'your_groq_api_key';

# 4. Run

flutter run
```

> Firebase is pre-configured via `google-services.json` / `GoogleService-Info.plist`.

> To connect your own project, replace these files and update `firebase_options.dart`.

---

# Contributing

Pull requests are welcome.

For significant changes, please open an issue first to discuss what you'd like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add your feature'`)
4. Push and open a Pull Request