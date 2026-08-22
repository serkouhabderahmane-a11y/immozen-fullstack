import 'dart:ui';

extension ColorExt on Color {
  Color brighten(int value) {
    final color0 = this;

    final red = color0.red + value;
    final green = color0.green + value;
    final blue = color0.blue + value;

    return Color.fromARGB(
      color0.alpha,
      red.clamp(0, 255),
      green.clamp(0, 255),
      blue.clamp(0, 255),
    );
  }

  Color darken(int value) {
    final color0 = this;

    final red = color0.red - value;
    final green = color0.green - value;
    final blue = color0.blue - value;

    return Color.fromARGB(
      color0.alpha,
      red.clamp(0, 255),
      green.clamp(0, 255),
      blue.clamp(0, 255),
    );
  }
}
