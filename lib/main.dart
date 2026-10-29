import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'servicos/preferencias.dart';
import 'telas/tela_login.dart';
import 'telas/tela_reviews.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? erro;
  try {
    await Hive.initFlutter();
    await Hive.openBox('rascunhos');
    await Preferencias.carregar();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    erro =
        'Não foi possível iniciar o app. Confira a configuração do Firebase '
        'no README e o armazenamento do dispositivo. Depois, abra o app novamente.';
  }
  runApp(MeuApp(erro: erro));
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key, this.erro});
  final String? erro;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: Preferencias.temaEscuro,
    builder: (context, escuro, _) => MaterialApp(
      title: 'Entre páginas e episódios',
      debugShowCheckedModeBanner: false,
      themeMode: escuro ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF930500)),
        scaffoldBackgroundColor: const Color(0xFFFFF8E7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF930500),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF95BBEA),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: erro != null
          ? Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(erro!),
                ),
              ),
            )
          : StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return const Scaffold(
                    body: Center(
                      child: Text(
                        'Não foi possível verificar o login. Reabra o app.',
                      ),
                    ),
                  );
                }
                return snapshot.data == null
                    ? const TelaLogin()
                    : TelaReviews(uid: snapshot.data!.uid);
              },
            ),
    ),
  );
}
