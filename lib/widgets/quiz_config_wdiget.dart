import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/quiz_models.dart';
import '../utils/colors_and_theme.dart';

class QuizConfigWidget extends StatefulWidget {
  final int vocabCount;
  final void Function(QuizConfig) onSubmit;

  const QuizConfigWidget({
    super.key,
    required this.vocabCount,
    required this.onSubmit,
  });

  @override
  State<QuizConfigWidget> createState() => _QuizConfigWidgetState();
}

class _QuizConfigWidgetState extends State<QuizConfigWidget> {
  int _wordCount = 10;
  int? _secondsPerWord = 30;
  QuizSource _source = QuizSource.vocabList;
  int _difficulty = 3;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: isDark ? kDarkWhiteShade2 : null,
    );

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Configure Quiz', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Number of Words', style: labelStyle),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _wordCount,
                dropdownColor: Theme.of(context).colorScheme.surface,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: [5, 10, 15, 20]
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n words')))
                    .toList(),
                onChanged: (v) => setState(() => _wordCount = v!),
              ),
              const SizedBox(height: 20),
              Text('Time per Word', style: labelStyle),
              const SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                value: _secondsPerWord,
                dropdownColor: Theme.of(context).colorScheme.surface,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('No limit')),
                  DropdownMenuItem(value: 15, child: Text('15 seconds')),
                  DropdownMenuItem(value: 30, child: Text('30 seconds')),
                  DropdownMenuItem(value: 60, child: Text('60 seconds')),
                ],
                onChanged: (v) => setState(() => _secondsPerWord = v),
              ),
              const SizedBox(height: 20),
              Text('Word Source', style: labelStyle),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SourceTile(
                      label: 'My Vocab List',
                      icon: Icons.list_alt_rounded,
                      subtitle: '${widget.vocabCount} words',
                      selected: _source == QuizSource.vocabList,
                      onTap: () => setState(() => _source = QuizSource.vocabList),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SourceTile(
                      label: 'Generate with AI',
                      icon: Icons.auto_awesome_rounded,
                      subtitle: 'Grog · Llama',
                      selected: _source == QuizSource.ai,
                      onTap: () => setState(() => _source = QuizSource.ai),
                    ),
                  ),
                ],
              ),
              if (_source == QuizSource.ai) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Difficulty', style: labelStyle),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _difficultyLabel(_difficulty),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                Builder(builder: (ctx) {
                  const thumbRadius = 10.0;
                  final labelColor = Theme.of(ctx).colorScheme.onSurface.withOpacity(0.5);
                  final labelStyle = GoogleFonts.poppins(fontSize: 11, color: labelColor);
                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(ctx).copyWith(
                          trackShape: const RectangularSliderTrackShape(),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: thumbRadius),
                        ),
                        child: Slider(
                          value: _difficulty.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: '$_difficulty',
                          onChanged: (v) => setState(() => _difficulty = v.round()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: thumbRadius),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Basic', style: labelStyle),
                            Text('Advanced', style: labelStyle),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onSubmit(QuizConfig(
                      wordCount: _wordCount,
                      secondsPerWord: _secondsPerWord,
                      source: _source,
                      difficulty: _difficulty,
                    ));
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Start Quiz',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _difficultyLabel(int d) {
    const labels = {1: 'Basic', 2: 'Easy', 3: 'Medium', 4: 'Hard', 5: 'Advanced'};
    return labels[d] ?? '$d/5';
  }
}

class _SourceTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SourceTile({
    required this.label,
    required this.icon,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? cs.primary : cs.outline,
            width: selected ? 2 : 1,
          ),
          color: selected ? cs.primaryContainer.withOpacity(0.35) : Colors.transparent,
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: selected ? cs.primary : cs.onSurface.withOpacity(0.55)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? cs.primary : cs.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 11, color: cs.onSurface.withOpacity(0.4)),
            ),
          ],
        ),
      ),
    );
  }
}
