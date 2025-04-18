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
