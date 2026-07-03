import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/quiz_models.dart';
import '../utils/colors_and_theme.dart';
import '../utils/firebase.dart';

class QuizActiveScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final QuizConfig config;

  const QuizActiveScreen({
    super.key,
    required this.questions,
    required this.config,
  });

  @override
  State<QuizActiveScreen> createState() => _QuizActiveScreenState();
}

class _QuizActiveScreenState extends State<QuizActiveScreen> {
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _answered = false;
  Timer? _timer;
  int _timeLeft = 0;

  QuizQuestion get _current => widget.questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    final secs = widget.config.secondsPerWord;
    if (secs == null) return;
    _timeLeft = secs;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        t.cancel();
        _current.userAnswer = null;
        setState(() => _answered = true);
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) _advance();
        });
      }
    });
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    _timer?.cancel();
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      _current.userAnswer = answer;
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _advance();
    });
  }

  void _advance() {
    if (_currentIndex >= widget.questions.length - 1) {
      _saveAndShowSummary();
    } else {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
      _startTimer();
    }
  }

  Future<void> _saveAndShowSummary() async {
    final correct = widget.questions.where((q) => q.isCorrect).length;
    final result = QuizResult(
      date: DateTime.now(),
      totalQuestions: widget.questions.length,
      correctAnswers: correct,
      questions: widget.questions,
      source: widget.config.source,
      difficulty: widget.config.difficulty,
    );

    final uid = firebaseAuthInstance.currentUser?.uid;
    if (uid != null) {
      await firestoreInstance
          .collection('users')
          .doc(uid)
          .collection('quizResults')
          .add(result.toFirestore());
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _QuizSummaryDialog(result: result),
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmExit() async {
    _timer?.cancel();
    final exit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Exit Quiz?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: const Text('Your progress will not be saved.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    if (exit == true && mounted) {
      Navigator.of(context).pop();
    } else if (!_answered) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.questions.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: _confirmExit),
        title: Text(
          'Question ${_currentIndex + 1} of $total',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: (_currentIndex + 1) / total),
            duration: const Duration(milliseconds: 400),
            builder: (_, v, __) => LinearProgressIndicator(
              value: v,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.config.secondsPerWord != null) ...[
              _TimerRow(timeLeft: _timeLeft, total: widget.config.secondsPerWord!),
              const SizedBox(height: 20),
            ],
            Text(
              _capitalize(_current.word),
              style: GoogleFonts.lato(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: isDark ? kDarkWhiteShade1 : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose the correct definition',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: cs.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView(
                children: _current.options
                    .map((opt) => _OptionTile(
                          option: opt,
                          answered: _answered,
                          isCorrect: opt == _current.correctAnswer,
                          isSelected: opt == _selectedAnswer,
                          onTap: () => _selectAnswer(opt),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _TimerRow extends StatelessWidget {
  final int timeLeft;
  final int total;

  const _TimerRow({required this.timeLeft, required this.total});

  @override
  Widget build(BuildContext context) {
    final urgent = timeLeft <= 5;
    final color = urgent ? Colors.red : Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: timeLeft / total,
              minHeight: 6,
              color: color,
              backgroundColor: color.withOpacity(0.15),
            ),
          ),
        ),
        const SizedBox(width: 10),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: urgent ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
          child: Text('${timeLeft}s'),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String option;
  final bool answered;
  final bool isCorrect;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.answered,
    required this.isCorrect,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color borderColor = cs.outline.withOpacity(0.5);
    Color? bgColor;
    Color textColor = cs.onSurface;
    IconData? trailingIcon;

    if (answered) {
      if (isCorrect) {
        borderColor = Colors.green;
        bgColor = Colors.green.withOpacity(0.12);
        textColor = Colors.green.shade700;
        trailingIcon = Icons.check_circle_outline;
      } else if (isSelected) {
        borderColor = Colors.red;
        bgColor = Colors.red.withOpacity(0.10);
        textColor = Colors.red.shade700;
        trailingIcon = Icons.cancel_outlined;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: answered ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: answered && (isCorrect || isSelected) ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: GoogleFonts.poppins(fontSize: 15, color: textColor),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, color: textColor, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizSummaryDialog extends StatelessWidget {
  final QuizResult result;

  const _QuizSummaryDialog({required this.result});

  @override
  Widget build(BuildContext context) {
    final pct = (result.score * 100).round();
    final scoreColor = pct >= 70
        ? Colors.green
        : pct >= 40
            ? Colors.orange
            : Colors.red;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Quiz Complete!',
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withOpacity(0.12),
              ),
              child: Center(
                child: Text(
                  '$pct%',
                  style: GoogleFonts.poppins(
                      fontSize: 28, fontWeight: FontWeight.w800, color: scoreColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${result.correctAnswers} / ${result.totalQuestions} correct',
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey),
            ),
            const Divider(height: 28),
            ...result.questions.map((q) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          q.isCorrect ? Icons.check_circle : Icons.cancel,
                          color: q.isCorrect ? Colors.green : Colors.red,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(q.word,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            if (!q.isCorrect) ...[
                              if (q.userAnswer != null)
                                Text(
                                  'Your answer: ${q.userAnswer}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                              Text(
                                'Correct: ${q.correctAnswer}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Done', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
