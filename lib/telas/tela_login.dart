import 'package:flutter/material.dart';

import '../servicos/autenticacao.dart';
import '../servicos/mensagens.dart';
import '../servicos/preferencias.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key, this.cadastro = false});
  final bool cadastro;

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final formulario = GlobalKey<FormState>();
  final email = TextEditingController(text: Preferencias.ultimoEmail);
  final senha = TextEditingController();
  bool carregando = false;
  String? erro;

  Future<void> enviar({bool recuperar = false}) async {
    if (recuperar) {
      if (!email.text.trim().contains('@')) {
        setState(() => erro = 'Preencha seu e-mail para recuperar a senha.');
        return;
      }
    } else if (!formulario.currentState!.validate()) {
      return;
    }
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final endereco = email.text.trim();
      if (recuperar) {
        await Autenticacao.recuperarSenha(endereco);
        if (mounted) {
          avisar(
            context,
            'Se houver uma conta, você receberá um e-mail de recuperação.',
          );
        }
      } else {
        await Preferencias.salvarEmail(endereco);
        if (widget.cadastro) {
          await Autenticacao.cadastrar(endereco, senha.text);
          if (mounted) Navigator.pop(context);
        } else {
          await Autenticacao.entrar(endereco, senha.text);
        }
      }
    } catch (e) {
      if (mounted) setState(() => erro = mensagemErro(e));
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  void dispose() {
    email.dispose();
    senha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !carregando,
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cadastro ? 'Criar conta' : 'Entre páginas e episódios',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: formulario,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.auto_stories,
                    size: 64,
                    color: Color(0xFF930500),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.cadastro
                        ? 'Sua próxima história começa aqui'
                        : 'Suas histórias, suas opiniões',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: email,
                    enabled: !carregando,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (valor) =>
                        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                            .hasMatch(valor!.trim())
                        ? null
                        : 'Digite um e-mail válido.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: senha,
                    enabled: !carregando,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    validator: (valor) => valor!.length >= 6
                        ? null
                        : 'Use pelo menos 6 caracteres.',
                    onFieldSubmitted: (_) {
                      if (!carregando) enviar();
                    },
                  ),
                  const SizedBox(height: 16),
                  if (erro != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        erro!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  if (carregando)
                    const Center(child: CircularProgressIndicator()),
                  FilledButton(
                    onPressed: carregando ? null : () => enviar(),
                    child: Text(widget.cadastro ? 'Cadastrar' : 'Entrar'),
                  ),
                  if (!widget.cadastro) ...[
                    TextButton(
                      onPressed: carregando
                          ? null
                          : () => enviar(recuperar: true),
                      child: const Text('Esqueci minha senha'),
                    ),
                    TextButton(
                      onPressed: carregando
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const TelaLogin(cadastro: true),
                              ),
                            ),
                      child: const Text('Criar uma conta'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
