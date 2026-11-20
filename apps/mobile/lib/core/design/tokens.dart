import 'package:flutter/material.dart';
import 'package:smart_surveillance/core/design/palette.dart';
const sansFamily = 'Geist';

const monoFamily = 'GeistMono';

class Radii {
  static const small = 6.0;
  static const medium = 10.0;
  static const large = 14.0;
  static const sheet = 22.0;
}

class Gaps {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const page = 16.0;
}

TextStyle dataStyle(BuildContext context, {double size = 13, Color? color, FontWeight? weight}) =>
    TextStyle(
      fontFamily: monoFamily,
      fontSize: size,
      height: 1.3,
      color: color ?? context.palette.text,
      fontWeight: weight ?? FontWeight.w400,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
