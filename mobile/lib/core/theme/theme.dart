import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'palette.dart';

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

TextTheme buildTextTheme(Palette p) {
  TextStyle style(double size, FontWeight weight, Color color, {double height = 1.35, double tracking = 0}) =>
      TextStyle(
        fontFamily: sansFamily,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: tracking,
      );
  return TextTheme(
    displayLarge: style(44, FontWeight.w600, p.text, height: 1.08, tracking: -1.4),
    displayMedium: style(36, FontWeight.w600, p.text, height: 1.1, tracking: -1.1),
    displaySmall: style(30, FontWeight.w600, p.text, height: 1.12, tracking: -0.8),
    headlineLarge: style(28, FontWeight.w600, p.text, height: 1.15, tracking: -0.7),
    headlineMedium: style(24, FontWeight.w600, p.text, height: 1.2, tracking: -0.5),
    headlineSmall: style(20, FontWeight.w600, p.text, height: 1.25, tracking: -0.3),
    titleLarge: style(18, FontWeight.w600, p.text, height: 1.3, tracking: -0.2),
    titleMedium: style(16, FontWeight.w600, p.text, height: 1.35, tracking: -0.1),
    titleSmall: style(14, FontWeight.w600, p.text, height: 1.35),
    bodyLarge: style(16, FontWeight.w400, p.text, height: 1.45),
    bodyMedium: style(14, FontWeight.w400, p.text, height: 1.45),
    bodySmall: style(12.5, FontWeight.w400, p.text2, height: 1.4),
    labelLarge: style(15, FontWeight.w600, p.text, height: 1.2),
    labelMedium: style(13, FontWeight.w500, p.text2, height: 1.25),
    labelSmall: style(11.5, FontWeight.w500, p.text3, height: 1.25, tracking: 0.1),
  );
}

ThemeData buildTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? Palette.dark : Palette.light;
  final text = buildTextTheme(p);
  final scheme = ColorScheme(
    brightness: brightness,
    primary: p.text,
    onPrimary: p.background,
    primaryContainer: p.surface3,
    onPrimaryContainer: p.text,
    secondary: p.focus,
    onSecondary: const Color(0xFFFFFFFF),
    secondaryContainer: p.surface3,
    onSecondaryContainer: p.text,
    tertiary: p.warning,
    onTertiary: const Color(0xFF000000),
    error: p.error,
    onError: const Color(0xFFFFFFFF),
    errorContainer: p.danger.withValues(alpha: 0.16),
    onErrorContainer: p.dangerText,
    surface: p.background,
    onSurface: p.text,
    onSurfaceVariant: p.text2,
    surfaceContainerLowest: p.background,
    surfaceContainerLow: p.surface,
    surfaceContainer: p.surface,
    surfaceContainerHigh: p.surface2,
    surfaceContainerHighest: p.surface3,
    outline: p.borderInput,
    outlineVariant: p.border,
    inverseSurface: p.text,
    onInverseSurface: p.background,
    inversePrimary: p.background,
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    surfaceTint: const Color(0x00000000),
  );
  final dark = brightness == Brightness.dark;
  final overlay = dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
  final roundedMedium = RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.medium));
  OutlineInputBorder inputBorder(Color color, [double width = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(Radii.medium),
    borderSide: BorderSide(color: color, width: width),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: sansFamily,
    textTheme: text,
    scaffoldBackgroundColor: p.background,
    canvasColor: p.background,
    dividerColor: p.border,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    extensions: [p],
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.text,
      surfaceTintColor: const Color(0x00000000),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: Gaps.page,
      systemOverlayStyle: overlay.copyWith(
        statusBarColor: const Color(0x00000000),
        systemNavigationBarColor: p.surface,
        systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      ),
      titleTextStyle: text.titleLarge,
      iconTheme: IconThemeData(color: p.text, size: 22),
      actionsIconTheme: IconThemeData(color: p.text2, size: 22),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      backgroundColor: p.surface,
      surfaceTintColor: const Color(0x00000000),
      indicatorColor: p.surface3,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.medium)),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 23,
          color: states.contains(WidgetState.selected) ? p.text : p.text3,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: sansFamily,
          fontSize: 12,
          height: 1.2,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? p.text : p.text3,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      surfaceTintColor: const Color(0x00000000),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.large),
        side: BorderSide(color: p.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.text,
        foregroundColor: p.background,
        disabledBackgroundColor: p.surface3,
        disabledForegroundColor: p.text3,
        minimumSize: const Size(64, 50),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: roundedMedium,
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.text,
        side: BorderSide(color: p.borderInput),
        minimumSize: const Size(64, 50),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        shape: roundedMedium,
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.text,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: roundedMedium,
        textStyle: text.labelLarge?.copyWith(fontSize: 14),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: p.text,
        shape: roundedMedium,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 44)),
        visualDensity: VisualDensity.standard,
        shape: WidgetStatePropertyAll(roundedMedium),
        side: WidgetStatePropertyAll(BorderSide(color: p.borderInput)),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? p.surface3 : const Color(0x00000000),
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? p.text : p.text2,
        ),
        textStyle: WidgetStatePropertyAll(text.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: inputBorder(p.borderInput),
      enabledBorder: inputBorder(p.borderInput),
      focusedBorder: inputBorder(p.focus, 1.6),
      errorBorder: inputBorder(p.error),
      focusedErrorBorder: inputBorder(p.error, 1.6),
      disabledBorder: inputBorder(p.border),
      labelStyle: text.bodyMedium?.copyWith(color: p.text2),
      floatingLabelStyle: text.bodyMedium?.copyWith(color: p.text2),
      hintStyle: text.bodyMedium?.copyWith(color: p.text3),
      helperStyle: text.bodySmall?.copyWith(color: p.text3),
      errorStyle: text.bodySmall?.copyWith(color: p.dangerText),
      prefixIconColor: p.text3,
      suffixIconColor: p.text3,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.chip,
      selectedColor: p.surface3,
      disabledColor: p.chip,
      side: BorderSide(color: p.border),
      checkmarkColor: p.text,
      labelStyle: text.labelMedium?.copyWith(color: p.text),
      secondaryLabelStyle: text.labelMedium?.copyWith(color: p.text),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.small + 2)),
      showCheckmark: false,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: p.text2,
      textColor: p.text,
      minTileHeight: 56,
      contentPadding: const EdgeInsets.symmetric(horizontal: Gaps.page),
      titleTextStyle: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      subtitleTextStyle: text.bodySmall,
      leadingAndTrailingTextStyle: text.labelMedium,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? p.background : p.text3,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? p.text : p.surface3,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? p.text : p.borderInput,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? p.text : const Color(0x00000000),
      ),
      checkColor: WidgetStatePropertyAll(p.background),
      side: BorderSide(color: p.borderStrong, width: 1.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? p.text : p.borderStrong,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: p.text,
      inactiveTrackColor: p.surface3,
      thumbColor: p.text,
      overlayColor: p.selection,
      trackHeight: 4,
      valueIndicatorColor: p.surface3,
      valueIndicatorTextStyle: text.labelMedium?.copyWith(color: p.text),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: p.text,
      linearTrackColor: p.surface3,
      circularTrackColor: const Color(0x00000000),
    ),
    dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: const Color(0x00000000),
      modalBackgroundColor: p.surface,
      showDragHandle: true,
      dragHandleColor: p.borderStrong,
      dragHandleSize: const Size(36, 4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: const Color(0x00000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.sheet - 4),
        side: BorderSide(color: p.border),
      ),
      titleTextStyle: text.titleLarge,
      contentTextStyle: text.bodyMedium?.copyWith(color: p.text2),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.surface3,
      contentTextStyle: text.bodyMedium?.copyWith(color: p.text),
      actionTextColor: p.text,
      elevation: 0,
      insetPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.medium),
        side: BorderSide(color: p.borderInput),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: p.surface3,
        borderRadius: BorderRadius.circular(Radii.small),
        border: Border.all(color: p.borderInput),
      ),
      textStyle: text.labelMedium?.copyWith(color: p.text),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: p.text,
      unselectedLabelColor: p.text3,
      indicatorColor: p.text,
      dividerColor: p.border,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: text.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: p.text),
      unselectedLabelStyle: text.labelMedium,
      overlayColor: WidgetStatePropertyAll(p.selection),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.text,
      foregroundColor: p.background,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.large)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: p.surface2,
      surfaceTintColor: const Color(0x00000000),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.medium),
        side: BorderSide(color: p.borderInput),
      ),
      textStyle: text.bodyMedium,
    ),
    badgeTheme: BadgeThemeData(
      backgroundColor: p.error,
      textColor: const Color(0xFFFFFFFF),
      textStyle: const TextStyle(fontFamily: monoFamily, fontSize: 10.5, fontWeight: FontWeight.w600),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: PredictiveBackPageTransitionsBuilder()},
    ),
  );
}
