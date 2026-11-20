import 'package:flutter/material.dart';
import 'package:smart_surveillance/core/design/palette.dart';

/// The font family used for text.
const sansFamily = 'Geist';

/// The font family used for numbers, codes and other data.
const monoFamily = 'GeistMono';

/// The corner radii shared by cards, fields and sheets.
class Radii {
  /// The radius of small elements such as chips.
  static const small = 6.0;

  /// The radius of buttons and fields.
  static const medium = 10.0;

  /// The radius of cards.
  static const large = 14.0;

  /// The radius of the top corners of bottom sheets.
  static const sheet = 22.0;
}

/// The spacing steps used for padding and gaps.
class Gaps {
  /// The smallest gap.
  static const xs = 4.0;

  /// A small gap.
  static const sm = 8.0;

  /// A medium gap.
  static const md = 12.0;

  /// A large gap.
  static const lg = 16.0;

  /// An extra large gap.
  static const xl = 24.0;

  /// The largest gap.
  static const xxl = 32.0;

  /// The horizontal padding of a screen.
  static const page = 16.0;
}

/// Returns a monospace text style with tabular figures for data such as times and counts.
TextStyle dataStyle(BuildContext context, {double size = 13, Color? color, FontWeight? weight}) =>
    TextStyle(
      fontFamily: monoFamily,
      fontSize: size,
      height: 1.3,
      color: color ?? context.palette.text,
      fontWeight: weight ?? FontWeight.w400,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
