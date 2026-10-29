import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferencias {
  static final _dados = SharedPreferencesAsync();
  static final temaEscuro = ValueNotifier(false);
  static String ultimoEmail = '';

  static Future<void> carregar() async {
    temaEscuro.value = await _dados.getBool('temaEscuro') ?? false;
    ultimoEmail = await _dados.getString('ultimoEmail') ?? '';
  }

  static Future<void> mudarTema() async {
    final novoTema = !temaEscuro.value;
    await _dados.setBool('temaEscuro', novoTema);
    temaEscuro.value = novoTema;
  }

  static Future<void> salvarEmail(String email) async {
    await _dados.setString('ultimoEmail', email);
    ultimoEmail = email;
  }
}
