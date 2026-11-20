import 'package:flutter/material.dart';
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.background,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.border,
    required this.borderInput,
    required this.borderStrong,
    required this.text,
    required this.text2,
    required this.text3,
    required this.focus,
    required this.selection,
    required this.chip,
    required this.ok,
    required this.error,
    required this.warning,
    required this.off,
    required this.danger,
    required this.dangerText,
    required this.person,
    required this.vehicle,
    required this.animal,
    required this.frame,
  });

  final Color background;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color border;
  final Color borderInput;
  final Color borderStrong;
  final Color text;
  final Color text2;
  final Color text3;
  final Color focus;
  final Color selection;
  final Color chip;
  final Color ok;
  final Color error;
  final Color warning;
  final Color off;
  final Color danger;
  final Color dangerText;
  final Color person;
  final Color vehicle;
  final Color animal;
  final Color frame;

  static const dark = Palette(
    background: Color(0xFF000000),
    surface: Color(0xFF0A0A0A),
    surface2: Color(0xFF161616),
    surface3: Color(0xFF262626),
    border: Color(0xFF1F1F1F),
    borderInput: Color(0xFF2E2E2E),
    borderStrong: Color(0xFF4A4A4A),
    text: Color(0xFFEDEDED),
    text2: Color(0xFFA1A1A1),
    text3: Color(0xFF7C7C7C),
    focus: Color(0xFF0090FF),
    selection: Color(0x24FFFFFF),
    chip: Color(0x12FFFFFF),
    ok: Color(0xFF45C25F),
    error: Color(0xFFF2555A),
    warning: Color(0xFFF0A92E),
    off: Color(0xFF5C5C5C),
    danger: Color(0xFFE5484D),
    dangerText: Color(0xFFFF8589),
    person: Color(0xFFF0A92E),
    vehicle: Color(0xFF0090FF),
    animal: Color(0xFF45C25F),
    frame: Color(0xFF050505),
  );

  static const light = Palette(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFAFAFA),
    surface2: Color(0xFFF2F2F2),
    surface3: Color(0xFFE8E8E8),
    border: Color(0xFFEBEBEB),
    borderInput: Color(0xFFDCDCDC),
    borderStrong: Color(0xFFB5B5B5),
    text: Color(0xFF171717),
    text2: Color(0xFF4D4D4D),
    text3: Color(0xFF6B6B6B),
    focus: Color(0xFF0072F5),
    selection: Color(0x1A000000),
    chip: Color(0x0D000000),
    ok: Color(0xFF1F9A3B),
    error: Color(0xFFD93036),
    warning: Color(0xFFB26A00),
    off: Color(0xFFB0B0B0),
    danger: Color(0xFFD93036),
    dangerText: Color(0xFFC4262C),
    person: Color(0xFFF0A92E),
    vehicle: Color(0xFF0090FF),
    animal: Color(0xFF45C25F),
    frame: Color(0xFF0A0A0A),
  );

  Color labelColor(String label) {
    if (label == 'person') return person;
    if (vehicleLabels.contains(label)) return vehicle;
    if (animalLabels.contains(label)) return animal;
    return const Color(0xFFFFFFFF);
  }

  static const vehicleLabels = {'car', 'truck', 'bus', 'motorcycle', 'bicycle', 'vehicle'};
  static const animalLabels = {'dog', 'cat', 'bird', 'animal'};

  @override
  Palette copyWith({Color? background, Color? surface, Color? text}) => Palette(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surface2: surface2,
    surface3: surface3,
    border: border,
    borderInput: borderInput,
    borderStrong: borderStrong,
    text: text ?? this.text,
    text2: text2,
    text3: text3,
    focus: focus,
    selection: selection,
    chip: chip,
    ok: ok,
    error: error,
    warning: warning,
    off: off,
    danger: danger,
    dangerText: dangerText,
    person: person,
    vehicle: vehicle,
    animal: animal,
    frame: frame,
  );

  @override
  Palette lerp(ThemeExtension<Palette>? other, double t) {
    if (other is! Palette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return Palette(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surface2: mix(surface2, other.surface2),
      surface3: mix(surface3, other.surface3),
      border: mix(border, other.border),
      borderInput: mix(borderInput, other.borderInput),
      borderStrong: mix(borderStrong, other.borderStrong),
      text: mix(text, other.text),
      text2: mix(text2, other.text2),
      text3: mix(text3, other.text3),
      focus: mix(focus, other.focus),
      selection: mix(selection, other.selection),
      chip: mix(chip, other.chip),
      ok: mix(ok, other.ok),
      error: mix(error, other.error),
      warning: mix(warning, other.warning),
      off: mix(off, other.off),
      danger: mix(danger, other.danger),
      dangerText: mix(dangerText, other.dangerText),
      person: mix(person, other.person),
      vehicle: mix(vehicle, other.vehicle),
      animal: mix(animal, other.animal),
      frame: mix(frame, other.frame),
    );
  }
}

extension PaletteContext on BuildContext {
  Palette get palette => Theme.of(this).extension<Palette>()!;

  TextTheme get text => Theme.of(this).textTheme;
}
