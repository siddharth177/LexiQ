import 'package:flutter/material.dart';
import 'package:vocab_list/screens/quiz_screen.dart';
import 'package:vocab_list/widgets/theme_popup_menu_widget.dart';

import '../utils/colors_and_theme.dart';
import '../utils/firebase.dart';

class PopMenuWidget extends StatefulWidget {
const PopMenuWidget({super.key, this.isOnQuizScreen = false});

final bool isOnQuizScreen;

  @override
  State<StatefulWidget> createState() {
    return _PopupMenuWidgetState();
  }
}

class _PopupMenuWidgetState extends State<PopMenuWidget> {
  IconData menuIcon = Icons.menu;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
        onOpened: () {
          setState(() {
            menuIcon = Icons.menu_open;
          });
        },
        onCanceled: () {
          setState(() {
            menuIcon = Icons.menu;
          });
        },
        icon: Icon(menuIcon),
        onSelected: (value) {
          if (value == 'logout') {
            firebaseAuthInstance.signOut();
          } else if (value == 'quiz') {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuizScreen()));
          } else if (value == 'vocabList') {
            Navigator.of(context).pop();
            }
        },
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<String>(
              value: widget.isOnQuizScreen ? 'vocabList' : 'quiz',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(widget.isOnQuizScreen ? Icons.list_alt_rounded : Icons.quiz_outlined),
                    const SizedBox(width: 8,),
                    Text(widget.isOnQuizScreen ? 'Vocab List' : 'Quiz',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? kDarkWhiteShade1 : null,
                    ),),

                  ],
                )),
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? kDarkWhiteShade1
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'theme',
              child: ThemeSubMenu(
              ),
            ),
          ];
        });
  }
}