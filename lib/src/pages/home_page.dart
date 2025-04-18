import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../gemini_tools.dart';
import 'home_model.dart';
import 'widgets/color_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GenerativeModel gemini;

  final geminiTools = GeminiTools();
  HomeModel? model;
  late ChatSession chatSession;

  var initialized = false;
  var question = '';
  var answer = '';
  var isLoading = false;
  final txtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final prompt = await rootBundle.loadString('assets/system_prompt.md');
    gemini = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: 'AIzaSyAnBqmyCGDvoOpUVyarIj5_qGFvOOC6nFs',
      systemInstruction: Content.system(prompt),
      tools: geminiTools.tools,
    );
    chatSession = gemini.startChat();
    initialized = true;
    setState(() {});
  }

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
