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

### Secured Login

<img width="1119" height="2124" alt="Secured Login Screen" src="https://github.com/user-attachments/assets/c79089ec-eddb-4ed1-bf2c-dfebe8078d16" />


### Vocabulary List

<img width="1138" height="2106" alt="A5B7E76C-AC4E-4311-A6B5-A231C97F49D3_1_201_a" src="https://github.com/user-attachments/assets/6fa75a14-ec5a-4460-a056-626938d12bd9" />

<img width="1142" height="2129" alt="Vocabulary Display Screen 2" src="https://github.com/user-attachments/assets/f91a9107-1b80-44d9-b791-a43ee47162e0" />


![Vocab List Expanded](...)

<img width="1140" height="2106" alt="Expanded Word Display Screen" src="https://github.com/user-attachments/assets/a9a43328-c6e3-4e9e-9ca1-f0571503e5c6" />


### Word Detail (AI-Powered)

<img width="1156" height="2141" alt="AI-Powered word search Screen" src="https://github.com/user-attachments/assets/894eb92e-bd33-4e5d-bf91-0934d09a828e" />


### Dark Mode

<img width="1143" height="2151" alt="E7318BE6-72E5-4AD2-869E-B201B7A7EB06_1_201_a" src="https://github.com/user-attachments/assets/f7136fe7-cdaa-486f-88df-f73804754f10" />


### Quiz – Configure

<img width="1146" height="2123" alt="00BAEDDE-F409-4067-90DC-4143016172E5_1_201_a" src="https://github.com/user-attachments/assets/9b050a07-839b-45e6-8ab6-dea5ab31da88" />
<img width="1108" height="2109" alt="00EB8397-FF1A-4E05-9BA7-BC8ADEE93EFF_1_201_a" src="https://github.com/user-attachments/assets/5f159daf-3e4f-48ca-a538-44c22e14c6b6" />


### Quiz – Active

<img width="301" height="572" alt="1BBC05CC-3851-419B-884E-026ADC151085_4_5005_c" src="https://github.com/user-attachments/assets/d138e17d-d757-49c2-b565-d9751ddd3a33" />


### Quiz – Review & History

<img width="1146" height="2123" alt="00BAEDDE-F409-4067-90DC-4143016172E5_1_201_a" src="https://github.com/user-attachments/assets/9b050a07-839b-45e6-8ab6-dea5ab31da88" />
<img width="1127" height="2126" alt="AED30C68-F526-4804-820D-74BD78B9D1B4_1_201_a" src="https://github.com/user-attachments/assets/3bba7a19-9bb8-4c70-b8db-162b49ba9813" />

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
