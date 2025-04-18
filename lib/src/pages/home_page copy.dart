import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  late final GenerativeModel gemini;
  late ChatSession chatSession;
  var initialized = false;
  var question = '';
  var answer = '';
  var isLoading = false;
  final txtController = TextEditingController();
  @override
  void initState() {
    super.initState();
    gemini = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: 'AIzaSyAnBqmyCGDvoOpUVyarIj5_qGFvOOC6nFs',
    );
    chatSession = gemini.startChat();
    initialized = true;
    setState(() {});
  }

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
                      child: Align(
                          alignment: Alignment.topLeft, child: Text(answer)),
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
                final response =
                    await chatSession.sendMessage(Content.text(question));
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
}
