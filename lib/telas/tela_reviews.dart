import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../modelos/review.dart';
import '../servicos/autenticacao.dart';
import '../servicos/mensagens.dart';
import '../servicos/preferencias.dart';
import '../servicos/rascunhos.dart';
import '../servicos/reviews.dart';
import 'tela_formulario.dart';

class TelaReviews extends StatefulWidget {
  const TelaReviews({super.key, required this.uid});
  final String uid;

  @override
  State<TelaReviews> createState() => _TelaReviewsState();
}

class _TelaReviewsState extends State<TelaReviews> {
  late final fluxo = Reviews().listar(widget.uid);
  bool local = false;
  bool ocupado = false;

  Future<void> abrir([Review? review]) async {
    final resultado = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TelaFormulario(uid: widget.uid, review: review, rascunho: local),
      ),
    );
    if (mounted && resultado != null) avisar(context, resultado);
  }

  Future<void> excluir(Review review) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir?'),
        content: Text(
          'Deseja excluir "${review.titulo}"${local ? ' dos rascunhos' : ' da nuvem'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    setState(() => ocupado = true);
    try {
      if (local) {
        await Rascunhos.excluir(widget.uid, review.id);
      } else {
        await Reviews().excluir(review.id).timeout(const Duration(seconds: 15));
      }
      if (mounted) avisar(context, 'Registro excluído.');
    } catch (e) {
      if (mounted) {
        avisar(
          context,
          '${mensagemErro(e)} ${local ? '' : 'Se ficou pendente, a exclusão pode terminar quando a conexão voltar.'}',
        );
      }
    } finally {
      if (mounted) setState(() => ocupado = false);
    }
  }

  Future<void> acao(Future<void> Function() executar) async {
    setState(() => ocupado = true);
    try {
      await executar();
    } catch (e) {
      if (mounted) avisar(context, mensagemErro(e));
    } finally {
      if (mounted) setState(() => ocupado = false);
    }
  }

  Widget lista(List<Review> reviews) {
    reviews.sort(
      (a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()),
    );
    if (reviews.isEmpty) {
      return Center(
        child: Text(
          local
              ? 'Nenhum rascunho neste dispositivo.\nToque em + para escrever.'
              : 'Você ainda não tem reviews.\nToque em + para começar.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF95BBEA),
              foregroundColor: const Color(0xFF382323),
              child: Icon(review.tipo == 'Livro' ? Icons.menu_book : Icons.tv),
            ),
            title: Text(review.titulo),
            subtitle: Text(
              '${review.tipo} • ${review.nota}/5 ★\n${review.comentario}',
            ),
            isThreeLine: true,
            onTap: ocupado ? null : () => abrir(review),
            trailing: IconButton(
              tooltip: 'Excluir ${review.titulo}',
              onPressed: ocupado ? null : () => excluir(review),
              icon: const Icon(Icons.delete_outline),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(local ? 'Meus rascunhos' : 'Minhas reviews'),
      actions: [
        IconButton(
          tooltip: 'Alternar tema',
          onPressed: ocupado ? null : () => acao(Preferencias.mudarTema),
          icon: const Icon(Icons.brightness_6),
        ),
        IconButton(
          tooltip: 'Sair',
          onPressed: ocupado ? null : () => acao(Autenticacao.sair),
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: Column(
      children: [
        if (ocupado) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            local
                ? 'Só neste dispositivo • toque para editar e publicar'
                : 'Seu diário de séries e livros • toque para editar',
          ),
        ),
        Expanded(
          child: local
              ? ValueListenableBuilder(
                  valueListenable: Rascunhos.caixa.listenable(),
                  builder: (_, _, _) => lista(Rascunhos.listar(widget.uid)),
                )
              : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: fluxo,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(mensagemErro(snapshot.error!)),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final dados = snapshot.data!;
                    return Column(
                      children: [
                        if (dados.metadata.isFromCache ||
                            dados.metadata.hasPendingWrites)
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'Dados em cache ou alterações pendentes. Conecte-se para confirmar com a nuvem.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Expanded(
                          child: lista(
                            dados.docs
                                .map(
                                  (doc) => Review.fromMap(doc.id, doc.data()),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: ocupado ? null : () => abrir(),
      tooltip: 'Nova review',
      child: const Icon(Icons.add),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: local ? 1 : 0,
      onDestinationSelected: ocupado
          ? null
          : (indice) => setState(() => local = indice == 1),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.cloud_outlined),
          label: 'Reviews',
        ),
        NavigationDestination(icon: Icon(Icons.edit_note), label: 'Rascunhos'),
      ],
    ),
  );
}
