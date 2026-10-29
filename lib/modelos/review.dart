class Review {
  const Review({
    required this.id,
    required this.uid,
    required this.titulo,
    required this.tipo,
    required this.nota,
    required this.comentario,
  });

  final String id;
  final String uid;
  final String titulo;
  final String tipo;
  final int nota;
  final String comentario;

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'titulo': titulo,
    'tipo': tipo,
    'nota': nota,
    'comentario': comentario,
  };

  factory Review.fromMap(String id, Map<String, dynamic> dados) => Review(
    id: id,
    uid: dados['uid'] as String,
    titulo: dados['titulo'] as String,
    tipo: dados['tipo'] as String,
    nota: (dados['nota'] as num).toInt(),
    comentario: dados['comentario'] as String,
  );
}
