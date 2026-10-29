import 'package:firebase_auth/firebase_auth.dart';

class Autenticacao {
  static Future<void> entrar(String email, String senha) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: senha,
    );
  }

  static Future<void> cadastrar(String email, String senha) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );
  }

  static Future<void> recuperarSenha(String email) =>
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  static Future<void> sair() => FirebaseAuth.instance.signOut();
}
