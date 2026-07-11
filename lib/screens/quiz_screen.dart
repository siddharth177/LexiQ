import 'package:LexiQ/widgets/add_word_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/quiz_models.dart';
import '../models/word_meaning.dart';
import '../services/quiz_service.dart';
import '../utils/colors_and_theme.dart';
import '../utils/firebase.dart';
import '../providers/secrets_provider.dart';
import '../utils/snackbar_messaging.dart';
import '../widgets/loading.dart';
import '../widgets/popup_menu_widget.dart';
import '../widgets/quiz_config_wdiget.dart';
import 'quiz_active_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  bool _isGenerating = false;

  void _openConfig() {
    final uid = firebaseAuthInstance.currentUser?.uid;
    if (uid == null) return;

    firestoreInstance
        .collection('users')
        .doc(uid)
        .collection('vocabList')
        .get()
        .then((snapshot) {
      if (!mounted) return;
      final vocabList = snapshot.docs
          .map((doc) => WordMeaning.fromFirestore(doc, null))
          .toList();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => QuizConfigWidget(
          vocabCount: vocabList.length,
          onSubmit: (config) => _startQuiz(config, vocabList),
        ),
      );
    });
  }

  Future<void> _startQuiz(
      QuizConfig config, List<WordMeaning> vocabList) async {
    setState(() => _isGenerating = true);
    try {
      final List<QuizQuestion> questions;
      if (config.source == QuizSource.vocabList) {
        questions = generateQuestionsFromVocab(vocabList, config.wordCount);
      } else {
        final uid = firebaseAuthInstance.currentUser?.uid;
        final excludeWords = <String>{};
        if (uid != null) {
          final past = await firestoreInstance
              .collection('users')
              .doc(uid)
              .collection('quizResults')
              .orderBy('date', descending: true)
              .limit(20)
              .get();

          for (final doc in past.docs) {
            final result = QuizResult.fromFirestore(doc, null);
            if (result.source == QuizSource.ai) {
              for (final q in result.questions) {
                if (q.isCorrect) excludeWords.add(q.word.toLowerCase());
              }
            }
          }
        }
        final apiKey = await ref.read(groqApiKeyProvider.future);
        questions = await generateQuestionsFromAI(
            config.wordCount, config.difficulty, apiKey,
            excludeWords: excludeWords.toList());
      }
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => QuizActiveScreen(questions: questions, config: config),
      ));
    } catch (e) {
      if (mounted)
        clearAndDisplaySnackbar(
            context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = firebaseAuthInstance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Quiz',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 30),
              ),
            ),
            PopMenuWidget(isOnQuizScreen: true),
          ],
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestoreInstance
                .collection('users')
                .doc(uid)
                .collection('quizResults')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget();
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz_outlined,
                          size: 72,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.25)),
                      const SizedBox(height: 16),
                      Text(
                        'No quizzes yet',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.45),
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap + to start your first quiz',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.35),
                            ),
                      ),
                    ],
                  ),
                );
              }

              final results = snapshot.data!.docs
                  .map((doc) => QuizResult.fromFirestore(doc, null))
                  .toList();

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                itemCount: results.length,
                itemBuilder: (_, i) => _QuizResultCard(result: results[i]),
              );
            },
          ),
          if (_isGenerating)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: const LoadingWidget(),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(4.0),
        child: FloatingActionButton(
          elevation: 10,
          onPressed: _isGenerating ? null : _openConfig,
          tooltip: 'New Quiz',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _QuizResultCard extends StatelessWidget {
  final QuizResult result;

  const _QuizResultCard({required this.result});

  void _delete(BuildContext context) {
    final id = result.id;
    if (id == null) return;
    firestoreInstance
        .collection('users')
        .doc(firebaseAuthInstance.currentUser!.uid)
        .collection('quizResults')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final pct = (result.score * 100).round();
    final scoreColor = pct >= 70
        ? Colors.green
        : pct >= 40
            ? Colors.orange
            : Colors.red;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final d = result.date;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    final deletePane = ActionPane(
      motion: const DrawerMotion(),
      dismissible: DismissiblePane(onDismissed: () => _delete(context)),
      children: [
        SlidableAction(
          onPressed: (_) => _delete(context),
          backgroundColor: isDark
              ? const Color(0xFF660F09)
              : Theme.of(context).colorScheme.errorContainer,
          icon: Icons.delete,
          label: 'Delete',
        ),
      ],
    );

    return Slidable(
      key: ValueKey(result.id ?? result.date.toIso8601String()),
      startActionPane: deletePane,
      endActionPane: deletePane,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showReview(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scoreColor.withOpacity(0.12),
                  ),
                  child: Center(
                    child: Text(
                      '$pct%',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: scoreColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${result.correctAnswers} / ${result.totalQuestions} correct',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isDark ? kDarkWhiteShade1 : null),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            result.source == QuizSource.ai
                                ? Icons.auto_awesome_rounded
                                : Icons.list_alt_rounded,
                            size: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.45),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            result.source == QuizSource.ai
                                ? 'AI · Level ${result.difficulty}/5'
                                : 'Vocab List',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.45)),
                          ),
                          const Spacer(),
                          Text(
                            dateStr,
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.45)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.35)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReview(BuildContext context) {
    final pct = (result.score * 100).round();
    final scoreColor = pct >= 70
        ? Colors.green
        : pct >= 40
            ? Colors.orange
            : Colors.red;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Review',
                      style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$pct%',
                style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: scoreColor),
              ),
              Text(
                '${result.correctAnswers} / ${result.totalQuestions} correct',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
              const Divider(height: 28),
              ...result.questions.map(
                (q) => Padding(
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
                      IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Theme.of(ctx).colorScheme.primary,
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Add to Vocab List',
                          onPressed: () => showModalBottomSheet(
                              context: ctx,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => AddWordWidget(
                                  word: q.word,
                                  root: '',
                                  phonetic: '',
                                  wordClass: WordClass.none,
                                  examples: [],
                                  usages: [],
                                  definition: q.correctAnswer,
                                  isEdit: false)),
                          icon: const Icon(Icons.add_circle_outline, size: 20)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Close',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
