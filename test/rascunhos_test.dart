import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:avaliacao2/modelos/review.dart';
import 'package:avaliacao2/servicos/rascunhos.dart';

void main() {
  test(
    'Hive cria, persiste, atualiza e exclui sem misturar usuários',
    () async {
      final pasta = await Directory.systemTemp.createTemp('reviews_test_');
      Hive.init(pasta.path);
      await Hive.openBox('rascunhos');
      try {
        const livro = Review(
          id: '1',
          uid: 'ana',
          titulo: 'Dom Casmurro',
          tipo: 'Livro',
          nota: 4,
          comentario: 'Uma narrativa envolvente.',
        );
        await Rascunhos.salvar(livro);
        await Rascunhos.salvar(
          const Review(
            id: '1',
            uid: 'giovana',
            titulo: 'Dark',
            tipo: 'Série',
            nota: 5,
            comentario: 'Muito boa.',
          ),
        );
        await Hive.close();
        await Hive.openBox('rascunhos');
        expect(Rascunhos.listar('ana').single.titulo, 'Dom Casmurro');
        expect(Rascunhos.listar('juliana'), isEmpty);
        await Rascunhos.salvar(
          const Review(
            id: '1',
            uid: 'ana',
            titulo: 'Dom Casmurro',
            tipo: 'Livro',
            nota: 5,
            comentario: 'Atualizei minha opinião.',
          ),
        );
        expect(Rascunhos.listar('ana').single.nota, 5);
        expect(Rascunhos.listar('ana'), hasLength(1));
        await Rascunhos.excluir('ana', '1');
        expect(Rascunhos.listar('ana'), isEmpty);
        expect(Rascunhos.listar('giovana').single.titulo, 'Dark');
      } finally {
        await Hive.close();
        await pasta.delete(recursive: true);
      }
    },
  );
}
