# Melhorando

## Criar assets/system_prompt.md

```md
# Instrução de Sistema do Colorist

Você é um assistente especialista em cores integrado a um aplicativo de desktop chamado Colorist. Seu trabalho é interpretar descrições de cores em linguagem natural e definir os valores de cor apropriados usando uma ferramenta especializada.

## Suas Capacidades

Você tem conhecimento sobre cores, teoria das cores e como traduzir descrições em linguagem natural em valores RGB específicos. Você tem acesso à seguinte ferramenta:

`set_color` - Define os valores RGB para a exibição de cores com base em uma descrição

## Como Responder às Entradas do Usuário

Quando os usuários descreverem uma cor:

1. Primeiro, reconheça a descrição da cor deles com uma resposta breve e amigável.
2. Interprete quais valores RGB representariam melhor essa descrição de cor.
3. Use a ferramenta `set_color` para definir esses valores (todos os valores devem estar entre 0.0 e 1.0).
4. Após definir a cor, forneça uma breve explicação da sua interpretação.

Exemplo:
Usuário: "Quero um laranja pôr do sol"
Você: "Laranja pôr do sol é uma cor quente e vibrante que captura os tons vermelho-dourados do sol se pondo. Combina um forte componente vermelho com tons laranja moderados."

[Então você chamaria a ferramenta set_color com aproximadamente: vermelho=1.0, verde=0.5, azul=0.25]

Após a chamada da ferramenta: "Defini um laranja quente com componentes fortes de vermelho, moderados de verde e mínimos de azul, que lembra o sol baixo no horizonte."

## Quando as Descrições Forem Pouco Claras

Se uma descrição de cor for ambígua ou pouco clara, por favor, faça perguntas de esclarecimento ao usuário, uma de cada vez.

## Quando os Usuários Selecionam Cores do Histórico

Às vezes, o usuário selecionará manualmente uma cor do painel de histórico. Quando isso acontecer, você receberá uma notificação sobre essa seleção que inclui detalhes sobre a cor. Reconheça essa seleção com uma resposta breve que identifique o que ele fez e comente sobre a cor selecionada.

Exemplo de notificação:
Usuário: "Usuário selecionou cor do histórico: {vermelho: 0.2, verde: 0.5, azul: 0.8, codigoHex: #3380CC}"
Você: "Vejo que você selecionou um azul oceano do seu histórico. Este azul tranquilo com intensidade moderada tem uma qualidade calmante e profissional. Gostaria de explorar tons semelhantes ou criar uma cor contrastante?"

## Diretrizes Importantes

- Sempre mantenha os valores RGB entre 0.0 e 1.0.
- Forneça respostas ponderadas e informadas sobre cores.
- Quando possível, inclua psicologia das cores, associações ou fatos interessantes sobre cores.
- Seja conversacional e envolvente em suas respostas.
- Concentre-se em ser útil e preciso com suas interpretações de cores.
```

## Modificar pubspec

```yaml
name: build_with_ai
description: 'A new Flutter project.'

(...)
flutter:
  uses-material-design: true
  assets:
    - assets/
```

## Criar Home Model

```dart
import 'dart:ui';

class HomeModel {
  final num red;
  final num green;
  final num blue;
  final bool success;
  final String reason;
  String get hexCode =>
      '#${(red * 255).round().toRadixString(16).padLeft(2, '0')}'
      '${(green * 255).round().toRadixString(16).padLeft(2, '0')}'
      '${(blue * 255).round().toRadixString(16).padLeft(2, '0')}';

  HomeModel({
    required this.red,
    required this.green,
    required this.blue,
    required this.success,
    required this.reason,
  });
  HomeModel.success({
    this.red = 0,
    this.green = 0,
    this.blue = 0,
    this.success = false,
    this.reason = '',
  });
  HomeModel.fail({
    this.red = 0,
    this.green = 0,
    this.blue = 0,
    this.success = false,
    required this.reason,
  });

  toColor() => Color.fromRGBO(
        (red * 255).round(),
        (green * 255).round(),
        (blue * 255).round(),
        1.0,
      );
}
```

## Criar Gemini_tools

```dart
import 'package:google_generative_ai/google_generative_ai.dart';

import 'pages/home_model.dart';

class GeminiTools {
  FunctionDeclaration get setColorFuncDecl => FunctionDeclaration(
        'set_color',
        'Set the color of the display square based on red, green, and blue values.',
        Schema.object(
          properties: {
            'red':
                Schema.number(description: 'Red component value (0.0 - 1.0)'),
            'green': Schema.number(
              description: 'Green component value (0.0 - 1.0)',
            ),
            'blue':
                Schema.number(description: 'Blue component value (0.0 - 1.0)'),
          },
        ),
      );

  List<Tool> get tools => [
        Tool(functionDeclarations: [setColorFuncDecl]),
      ];

  HomeModel handleFunctionCall(
    String functionName,
    Map<String, Object?> arguments,
  ) {
    return switch (functionName) {
      'set_color' => handleSetColor(arguments),
      _ => handleUnknownFunction(functionName),
    };
  }

  HomeModel handleSetColor(Map<String, Object?> arguments) {
    final red = (arguments['red'] as num).toDouble();
    final green = (arguments['green'] as num).toDouble();
    final blue = (arguments['blue'] as num).toDouble();
    final functionResults = HomeModel.success(
      success: true,
      red: red,
      green: green,
      blue: blue,
    );

    return functionResults;
  }

  HomeModel handleUnknownFunction(String functionName) {
    return HomeModel.fail(
      success: false,
      reason: 'Unsupported function call $functionName',
    );
  }
}

```

## Adicionar variaveis

```dart

class _HomePageState extends State<HomePage> {
  (...)
  final geminiTools = GeminiTools();
  HomeModel? model;

  @override
  Widget build(BuildContext context) {
    (...)
  }
}
```

## Modificar init()

```dart
class _HomePageState extends State<HomePage> {
  (...)
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final prompt = await rootBundle.loadString('assets/system_prompt.md');
    gemini = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: 'API_KEY',
      systemInstruction: Content.system(prompt),
      tools: geminiTools.tools,
    );
    chatSession = gemini.startChat();
    initialized = true;
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
   (...)
  }
}
```

## Criar lib\src\pages\widgets\color_widget.dart
```dart
import 'package:build_with_ai/src/pages/home_model.dart';
import 'package:flutter/material.dart';

class ColorWidget extends StatelessWidget {
  final HomeModel? model;
  const ColorWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    if (model == null || !model!.success) return SizedBox.shrink();

    return Column(
      children: [
        Container(width: 100, height: 100, color: model!.toColor()),
        Text(model!.hexCode)
      ],
    );
  }
}

```

## Finalizar

```dart
class _HomePageState extends State<HomePage> {
  (...)

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GEMINI PRO'),
        ),
        body: Column(
          children: [
            const Text('TEXT AI'),
            if (initialized)
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
                        child: Align(
                            alignment: Alignment.topLeft, child: Text(answer)),
                      ),
                      ColorWidget(model: model),
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
            if (!initialized)
              CircularProgressIndicator()
            else
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: txtController,
                  onFieldSubmitted: (text) async {
                    setState(() {
                      question = text;
                      isLoading = true;
                      model = null;
                    });
                    txtController.clear();

                    final response =
                        await chatSession.sendMessage(Content.text(question));

                    setState(() {
                      answer = response.text ?? '';
                      for (var function in response.functionCalls) {
                        final result = GeminiTools()
                            .handleFunctionCall(function.name, function.args);

                        if (!result.success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro: ${result.reason}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          model = result;
                        }
                      }
                      isLoading = false;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

```
