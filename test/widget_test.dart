import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:avaliacao2/servicos/rascunhos.dart';
import 'package:avaliacao2/telas/tela_login.dart';
import 'package:avaliacao2/telas/tela_formulario.dart';

void main() {
  testWidgets('Formulário salva um rascunho sem acessar o Firebase', (
    tester,
  ) async {
    late Directory pasta;
    await tester.runAsync(() async {
      pasta = await Directory.systemTemp.createTemp('review_form_');
      Hive.init(pasta.path);
      await Hive.openBox('rascunhos');
    });
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TelaFormulario(uid: 'ana'),
                  ),
                ),
                child: const Text('Abrir formulário'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir formulário'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Dom Casmurro');
      await tester.enterText(
        find.byType(TextFormField).last,
        'Uma narrativa envolvente.',
      );
      await tester.ensureVisible(find.text('Salvar rascunho no dispositivo'));
      await tester.runAsync(() async {
        await tester.tap(find.text('Salvar rascunho no dispositivo'));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(Rascunhos.listar('ana').single.titulo, 'Dom Casmurro');
      expect(find.text('Abrir formulário'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      await tester.runAsync(() async {
        await Hive.close();
        await pasta.delete(recursive: true);
      });
    }
  });

  testWidgets('Login valida os campos e navega para cadastro', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TelaLogin()));
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Digite um e-mail válido.'), findsOneWidget);
    expect(find.text('Use pelo menos 6 caracteres.'), findsOneWidget);
    await tester.tap(find.text('Criar uma conta'));
    await tester.pumpAndSettle();
    expect(find.text('Cadastrar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Review vazia não pode ser salva', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: TelaFormulario(uid: 'ana')),
    );
    await tester.ensureVisible(find.text('Salvar na nuvem'));
    await tester.tap(find.text('Salvar na nuvem'));
    await tester.pumpAndSettle();
    expect(find.text('Informe o título.'), findsOneWidget);
    expect(find.text('Escreva sua opinião.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
