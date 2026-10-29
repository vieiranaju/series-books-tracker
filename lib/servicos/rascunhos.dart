import 'package:hive_flutter/hive_flutter.dart';

import '../modelos/review.dart';

class Rascunhos {
  static Box get caixa => Hive.box('rascunhos');
  static String _chave(String uid, String id) => '$uid/$id';
  static List<Review> listar(String uid) => caixa
      .toMap()
      .entries
      .where((item) => item.key.toString().startsWith('$uid/'))
      .map(
        (item) => Review.fromMap(
          item.key.toString().substring(uid.length + 1),
          Map<String, dynamic>.from(item.value as Map),
        ),
      )
      .toList();
  static Future<void> salvar(Review review) =>
      caixa.put(_chave(review.uid, review.id), review.toMap());
  static Future<void> excluir(String uid, String id) =>
      caixa.delete(_chave(uid, id));
}
