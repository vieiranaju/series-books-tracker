import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

String mensagemErro(Object erro) {
  if (erro is TimeoutException) {
    return 'A operação demorou. Verifique sua internet e tente novamente.';
  }
  if (erro is FirebaseException) {
    return switch (erro.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'E-mail ou senha incorretos.',
      'email-already-in-use' => 'Este e-mail já está cadastrado.',
      'weak-password' => 'Use uma senha com pelo menos 6 caracteres.',
      'invalid-email' => 'Digite um e-mail válido.',
      'network-request-failed' ||
      'unavailable' => 'Sem conexão. Verifique sua internet.',
      'too-many-requests' => 'Muitas tentativas. Aguarde e tente novamente.',
      'user-disabled' => 'Esta conta está desativada.',
      'permission-denied' =>
        'Acesso negado. Confira o login e as regras do Firestore.',
      'configuration-not-found' || 'operation-not-allowed' =>
        'Ative o login por e-mail e senha no Firebase.',
      _ => 'Não foi possível concluir. Tente novamente.',
    };
  }
  return 'Não foi possível concluir. Verifique o armazenamento e tente novamente.';
}

void avisar(BuildContext context, String texto) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
}
