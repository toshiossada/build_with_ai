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
