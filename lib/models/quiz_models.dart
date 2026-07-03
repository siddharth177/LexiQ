import 'package:cloud_firestore/cloud_firestore.dart';

enum QuizSource { vocabList, ai }

class QuizConfig {
  final int wordCount;
  final int? secondsPerWord;
  final QuizSource source;
  final int difficulty;

  const QuizConfig({
    required this.wordCount,
    this.secondsPerWord,
    required this.source,
    this.difficulty = 3,
  });
}

class QuizQuestion {
  final String word;
  final String correctAnswer;
  final List<String> options;
  String? userAnswer;

  QuizQuestion({
    required this.word,
    required this.correctAnswer,
    required this.options,
    this.userAnswer,
  });

  bool get isCorrect => userAnswer == correctAnswer;
  bool get isAnswered => userAnswer != null;
}

class QuizResult {
  final String? id;
  final DateTime date;
  final int totalQuestions;
  final int correctAnswers;
  final List<QuizQuestion> questions;
  final QuizSource source;
  final int difficulty;

  const QuizResult({
    this.id,
    required this.date,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.questions,
    required this.source,
    this.difficulty = 3,
  });

  double get score => totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;

  factory QuizResult.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data()!;
    return QuizResult(
      id: snapshot.id,
      date: (data['date'] as Timestamp).toDate(),
      totalQuestions: data['totalQuestions'] as int,
      correctAnswers: data['correctAnswers'] as int,
      source: data['source']  == 'ai' ? QuizSource.ai : QuizSource.vocabList,
      difficulty: (data['difficulty'] as int?) ?? 3,
      questions: (data['questions'] as List<dynamic>? ?? []).map((q) {
        final m = q as Map<String, dynamic>;
        return QuizQuestion(
          word: m['word'] as String,
          correctAnswer: m['correctAnswer'] as String,
          options: List<String>.from(m['options'] as List),
          userAnswer: m['userAnswer'] as String?,
        );
      }).toList(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'date': Timestamp.fromDate(date),
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'source': source == QuizSource.ai ? 'ai' : 'vocabList',
    'difficulty': difficulty,
    'questions': questions
        .map((q) => {
      'word': q.word,
      'correctAnswer': q.correctAnswer,
      'options': q.options,
      'userAnswer': q.userAnswer,
    })
        .toList(),
  };
}