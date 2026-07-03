import 'package:LexiQ/providers/theme_provider.dart';
import 'package:LexiQ/screens/authentication/auth.dart';
import 'package:LexiQ/screens/authentication/email_verification.dart';
import 'package:LexiQ/utils/colors_and_theme.dart';
import 'package:LexiQ/utils/firebase.dart';
import 'package:LexiQ/widgets/loading.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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