# Entre páginas e episódios

Aplicativo Flutter para avaliar séries e livros, disponível para Android e Web.

## Funcionalidades

- Cadastro, login e recuperação de senha.
- Criação, edição e exclusão de reviews com nota e comentário.
- Rascunhos salvos no dispositivo.
- Tema claro e escuro.

## Tecnologias

Flutter, Firebase Authentication, Cloud Firestore, Hive e SharedPreferences.

## Como executar

Com o Flutter instalado, copie `firebase.example.json` para `firebase.local.json` e preencha com as configurações dos seus aplicativos no Firebase. Esse arquivo é local e não deve ser enviado ao GitHub.

Execute na pasta do projeto:

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=firebase.local.json
```

Para Android, conecte um celular ou inicie um emulador e execute:

```bash
flutter run --dart-define-from-file=firebase.local.json
```
