import 'package:cloud_firestore/cloud_firestore.dart';

import '../modelos/review.dart';

class Reviews {
  final _colecao = FirebaseFirestore.instance.collection('reviews');
  Stream<QuerySnapshot<Map<String, dynamic>>> listar(String uid) => _colecao
      .where('uid', isEqualTo: uid)
      .snapshots(includeMetadataChanges: true);
  Future<void> salvar(Review review) =>
      _colecao.doc(review.id).set(review.toMap());
  Future<void> excluir(String id) => _colecao.doc(id).delete();
}
