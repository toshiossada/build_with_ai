import 'package:flutter/material.dart';

import 'pages/home_page copy.dart';
import 'pages/home_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage2(),
    );
  }
}
