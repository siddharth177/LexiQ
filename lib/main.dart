import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocab_list/models/word_meaning.dart';
import 'package:vocab_list/providers/theme_provider.dart';
import 'package:vocab_list/screens/authentication/auth.dart';
import 'package:vocab_list/screens/authentication/email_verification.dart';
import 'package:vocab_list/utils/colors_and_theme.dart';
import 'package:vocab_list/utils/firebase.dart';
import 'package:vocab_list/widgets/add_word_widget.dart';
import 'package:vocab_list/widgets/loading.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'LexiQ',
      theme: kLightThemeData,
      darkTheme: kDarkThemeData,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: firebaseAuthInstance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            return const EmailVerificationScreen();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          return const AuthScreen();
        },
      ),
    );
  }
}