import 'package:flutter/material.dart';

import '../modelos/review.dart';
import '../servicos/mensagens.dart';
import '../servicos/rascunhos.dart';
import '../servicos/reviews.dart';

class TelaFormulario extends StatefulWidget {
  const TelaFormulario({
    super.key,
    required this.uid,
    this.review,
    this.rascunho = false,
  });
  final String uid;
  final Review? review;
  final bool rascunho;

  @override
  State<TelaFormulario> createState() => _TelaFormularioState();
}

class _TelaFormularioState extends State<TelaFormulario> {
  final formulario = GlobalKey<FormState>();
  final titulo = TextEditingController();
  final comentario = TextEditingController();
  late String id;
  String tipo = 'Livro';
  int nota = 3;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    final review = widget.review;
    id = review?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    if (review != null) {
      titulo.text = review.titulo;
      comentario.text = review.comentario;
      tipo = review.tipo;
      nota = review.nota;
    }
  }

  Future<void> salvar({required bool local}) async {
    if (!formulario.currentState!.validate()) return;
    setState(() => salvando = true);
    final review = Review(
      id: id,
      uid: widget.uid,
      titulo: titulo.text.trim(),
      tipo: tipo,
      nota: nota,
      comentario: comentario.text.trim(),
    );
    try {
      if (local) {
        await Rascunhos.salvar(review);
      } else {
        // Preserva o texto antes de publicar, inclusive se a conexão cair.
        await Rascunhos.salvar(review);
        await Reviews().salvar(review).timeout(const Duration(seconds: 15));
        await Rascunhos.excluir(widget.uid, id);
      }
      if (mounted) {
        Navigator.pop(
          context,
          local
              ? 'Rascunho salvo neste dispositivo.'
              : 'Review salva na nuvem.',
        );
      }
    } catch (e) {
      if (mounted) {
        avisar(
          context,
          '${mensagemErro(e)} ${local ? '' : 'Sua cópia está nos rascunhos. Uma gravação pendente pode ser concluída quando a conexão voltar.'}',
        );
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  void dispose() {
    titulo.dispose();
    comentario.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !salvando,
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.review == null
              ? 'Nova review'
              : widget.rascunho
              ? 'Editar rascunho'
              : 'Editar review',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: formulario,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextFormField(
                  controller: titulo,
                  enabled: !salvando,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    labelText: 'Título da série ou livro',
                  ),
                  validator: (valor) =>
                      valor!.trim().isEmpty ? 'Informe o título.' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: tipo,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: ['Livro', 'Série']
                      .map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
                  onChanged: salvando
                      ? null
                      : (valor) => setState(() => tipo = valor!),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sua nota: $nota de 5',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      tooltip: '${i + 1} estrelas',
                      onPressed: salvando
                          ? null
                          : () => setState(() => nota = i + 1),
                      icon: Icon(
                        i < nota ? Icons.star : Icons.star_border,
                        color: const Color(0xFFAC7000),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: comentario,
                  enabled: !salvando,
                  minLines: 4,
                  maxLines: 7,
                  maxLength: 2000,
                  decoration: const InputDecoration(
                    labelText: 'O que você achou?',
                  ),
                  validator: (valor) =>
                      valor!.trim().isEmpty ? 'Escreva sua opinião.' : null,
                ),
                const SizedBox(height: 16),
                if (salvando) const Center(child: CircularProgressIndicator()),
                FilledButton.icon(
                  onPressed: salvando ? null : () => salvar(local: false),
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Salvar na nuvem'),
                ),
                OutlinedButton.icon(
                  onPressed: salvando ? null : () => salvar(local: true),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar rascunho no dispositivo'),
                ),
                const Text(
                  'Rascunhos podem ser criados e editados sem internet. Para publicar, use Salvar na nuvem.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
