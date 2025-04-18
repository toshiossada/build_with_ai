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
