import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/word_meaning.dart';
import '../utils/colors_and_theme.dart';
import '../utils/firebase.dart';
import 'add_word_widget.dart';
import 'word_expanded_display_widget.dart';

class WordDisplayWidget extends StatefulWidget {
  const WordDisplayWidget({required this.wordMeaning, super.key});

  final WordMeaning wordMeaning;

  @override
  State<StatefulWidget> createState() {
    return _WordDisplayWidgetState();
  }
}

class _WordDisplayWidgetState extends State<WordDisplayWidget> {
  get wordMeaning => widget.wordMeaning;

  void _editWordField() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return AddWordWidget(
          word: widget.wordMeaning.word,
          root: widget.wordMeaning.root,
          phonetic: widget.wordMeaning.phonetic,
          wordClass: widget.wordMeaning.wordClass,
          examples: widget.wordMeaning.examples,
          usages: widget.wordMeaning.usages,
          definition: widget.wordMeaning.definition,
          isEdit: true,
        );
      },
      isScrollControlled: true,
    );
  }

  void _openDisplayWordDialog() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (ctx) {
          return DisplayVocabListElement(wordMeaning: wordMeaning);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        // splashColor: Colors.white,
        // highlightColor: Colors.yellow,
        onTap: () {
          _openDisplayWordDialog();
        },
        child: Slidable(
          key: ValueKey(widget.wordMeaning.word),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                backgroundColor:
                    Theme.of(context).brightness == Brightness.dark ? kDarkPrimaryColor : Theme.of(context).colorScheme.secondaryContainer,
                onPressed: (context) {
                  _editWordField();
                },
                icon: Icons.edit,
                label: 'Edit',
              )
            ],
          ),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            dismissible: DismissiblePane(
              onDismissed: () {
                firestoreInstance
                    .collection('users')
                    .doc(firebaseAuthInstance.currentUser!.uid)
                    .collection('vocabList')
                    .doc(widget.wordMeaning.word)
                    .delete();
              },
            ),
            children: [
              SlidableAction(
                onPressed: (context) {
                  firestoreInstance
                      .collection('users')
                      .doc(firebaseAuthInstance.currentUser!.uid)
                      .collection('vocabList')
                      .doc(widget.wordMeaning.word)
                      .delete();
                },
                backgroundColor: Theme.of(context).brightness == Brightness.dark ? Color(0xFF660F09) : Theme.of(context).colorScheme.errorContainer,
                icon: Icons.delete,
                label: 'Delete',
              )
            ],
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            // Define how the card's content should be clipped
            title: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                widget.wordMeaning.word,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.openSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kLightWhiteShade1
                      : null,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ),
            subtitle: Text(
              widget.wordMeaning.definition.isNotEmpty
                  ? widget.wordMeaning.definition
                  : '\n',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w300,
                color: Theme.of(context).brightness == Brightness.dark
                    ? kDarkWhiteShade1
                    : null,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
