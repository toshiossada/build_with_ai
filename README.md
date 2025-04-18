# Build With AI

![image](https://github-production-user-asset-6210df.s3.amazonaws.com/2637049/425592305-1518cd1d-51b1-43d9-aa73-2cb52d13f2b8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAVCODYLSA53PQK4ZA%2F20250418%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250418T234953Z&X-Amz-Expires=300&X-Amz-Signature=f671082ec0fab76c0cfb1bf954b1c6eac2785015ea29d7b2722a936ceb8aaf9d&X-Amz-SignedHeaders=host)

## 1 - Inicie o projeto

```dart
import 'package:build_with_ai/src/app_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AppWidget());
}
```

## 2 - Adicione o widget Principal

```dart
import 'package:flutter/material.dart';
import 'pages/home_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
    );
  }
}
```

## 3 - Crie a HomePage

```dart
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App'),
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
```

## 4 - Adicione as Variaveis de controle

```dart
class _HomePageState extends State<HomePage> {
  late final GenerativeModel gemini;
  late ChatSession chatSession;
  var initialized = false;
  var question = '';
  var answer = '';
  var isLoading = false;
  final txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    (...)
  }
}

```

## 5 - Registrando Gemini

```dart
class _HomePageState extends State<HomePage> {
  (...)
  @override
  void initState() {
    super.initState();
    gemini = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: 'API_KEY',
    );
    chatSession = gemini.startChat();
    initialized = true;
    setState((){});
  }
  @override
  Widget build(BuildContext context) {
   (...)
  }
}

```

## 6 - Criando Caixa de testo

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Chat App'),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: txtController,
            onFieldSubmitted: (text) async {
              setState(() {
                question = text;
                isLoading = true;
              });
              txtController.clear();
              final response = await chatSession.sendMessage(Content.text(question));
              setState(() {
                answer = response.text ?? '';
                isLoading = false;
              });
            },
          ),
        )
      ],
    ),
  );
}
```

## 7 - Exibindo Resposta

```dart
@override
import 'package:flutter/material.dart';

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Chat App'),
    ),
    body: Column(
      children: [
        if (!initialized)
         CircularProgressIndicator()
        else
         Expanded(
           child: SingleChildScrollView(
              child: Column(
               children: [
                 Text(question),
                 Visibility(
                  visible: isLoading,
                  child: const CircularProgressIndicator(),
                ),
                Visibility(
                  visible: !isLoading,
                  child:
                      Align(alignment: Alignment.topLeft, child: Text(answer)),
                ),
                Visibility(
                  visible: question.isEmpty && !isLoading,
                  child: const Center(
                    child: Text('Faça uma pergunta ao GEMINI!'),
                  ),
                )
              ],
            ),
          ),
        ),
(...)
      ],
    ),
  );
}

```

## Melhorando

[Melhorando](./melhorias.md)
