import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff9c0e1f),
      surfaceTint: Color(0xffb5242e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffbf2c34),
      onPrimaryContainer: Color(0xffffdcda),
      secondary: Color(0xff984443),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffff9692),
      onSecondaryContainer: Color(0xff782c2c),
      tertiary: Color(0xff724200),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff945700),
      onTertiaryContainer: Color(0xffffdec1),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff8f7),
      onSurface: Color(0xff261817),
      onSurfaceVariant: Color(0xff5a403f),
      outline: Color(0xff8e706e),
      outlineVariant: Color(0xffe2bebc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff3d2c2b),
      inversePrimary: Color(0xffffb3af),
      primaryFixed: Color(0xffffdad8),
      onPrimaryFixed: Color(0xff410006),
      primaryFixedDim: Color(0xffffb3af),
      onPrimaryFixedVariant: Color(0xff920219),
      secondaryFixed: Color(0xffffdad8),
      onSecondaryFixed: Color(0xff3f0207),
      secondaryFixedDim: Color(0xffffb3af),
      onSecondaryFixedVariant: Color(0xff7a2d2d),
      tertiaryFixed: Color(0xffffdcbd),
      onTertiaryFixed: Color(0xff2c1600),
      tertiaryFixedDim: Color(0xffffb86e),
      onTertiaryFixedVariant: Color(0xff693c00),
      surfaceDim: Color(0xffefd4d2),
      surfaceBright: Color(0xfffff8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0ef),
      surfaceContainer: Color(0xffffe9e7),
      surfaceContainerHigh: Color(0xfffde2e0),
      surfaceContainerHighest: Color(0xfff7dcda),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff730011),
      surfaceTint: Color(0xffb5242e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffbf2c34),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff641d1e),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffab5250),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff522e00),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff945700),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f7),
      onSurface: Color(0xff1b0e0d),
      onSurfaceVariant: Color(0xff48302f),
      outline: Color(0xff674c4a),
      outlineVariant: Color(0xff836664),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff3d2c2b),
      inversePrimary: Color(0xffffb3af),
      primaryFixed: Color(0xffca343b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xffa71825),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xffab5250),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff8c3b3a),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff9d5e0a),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff7c4800),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffdac1bf),
      surfaceBright: Color(0xfffff8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0ef),
      surfaceContainer: Color(0xfffde2e0),
      surfaceContainerHigh: Color(0xfff2d7d5),
      surfaceContainerHighest: Color(0xffe6ccca),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff60000d),
      surfaceTint: Color(0xffb5242e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff96061b),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff571315),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff7d302f),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff432500),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff6c3e00),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f7),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff3d2625),
      outlineVariant: Color(0xff5c4341),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff3d2c2b),
      inversePrimary: Color(0xffffb3af),
      primaryFixed: Color(0xff96061b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff6c0010),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff7d302f),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff60191b),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff6c3e00),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff4d2b00),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffccb3b1),
      surfaceBright: Color(0xfffff8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffffedeb),
      surfaceContainer: Color(0xfff7dcda),
      surfaceContainerHigh: Color(0xffe9cecd),
      surfaceContainerHighest: Color(0xffdac1bf),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb3af),
      surfaceTint: Color(0xffffb3af),
      onPrimary: Color(0xff68000f),
      primaryContainer: Color(0xffbf2c34),
      onPrimaryContainer: Color(0xffffdcda),
      secondary: Color(0xffffb3af),
      onSecondary: Color(0xff5d1719),
      secondaryContainer: Color(0xff7d2f2f),
      onSecondaryContainer: Color(0xffff9e9a),
      tertiary: Color(0xffffb86e),
      onTertiary: Color(0xff492900),
      tertiaryContainer: Color(0xff945700),
      onTertiaryContainer: Color(0xffffdec1),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff1d100f),
      onSurface: Color(0xfff7dcda),
      onSurfaceVariant: Color(0xffe2bebc),
      outline: Color(0xffa98987),
      outlineVariant: Color(0xff5a403f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff7dcda),
      inversePrimary: Color(0xffb5242e),
      primaryFixed: Color(0xffffdad8),
      onPrimaryFixed: Color(0xff410006),
      primaryFixedDim: Color(0xffffb3af),
      onPrimaryFixedVariant: Color(0xff920219),
      secondaryFixed: Color(0xffffdad8),
      onSecondaryFixed: Color(0xff3f0207),
      secondaryFixedDim: Color(0xffffb3af),
      onSecondaryFixedVariant: Color(0xff7a2d2d),
      tertiaryFixed: Color(0xffffdcbd),
      onTertiaryFixed: Color(0xff2c1600),
      tertiaryFixedDim: Color(0xffffb86e),
      onTertiaryFixedVariant: Color(0xff693c00),
      surfaceDim: Color(0xff1d100f),
      surfaceBright: Color(0xff463534),
      surfaceContainerLowest: Color(0xff170b0a),
      surfaceContainerLow: Color(0xff261817),
      surfaceContainer: Color(0xff2b1c1b),
      surfaceContainerHigh: Color(0xff362625),
      surfaceContainerHighest: Color(0xff413130),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffd2cf),
      surfaceTint: Color(0xffffb3af),
      onPrimary: Color(0xff54000a),
      primaryContainer: Color(0xfffb585a),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffd2cf),
      onSecondary: Color(0xff4e0c0f),
      secondaryContainer: Color(0xffd67572),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffd5ad),
      onTertiary: Color(0xff3a1f00),
      tertiaryContainer: Color(0xffc78130),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff1d100f),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xfff9d4d1),
      outline: Color(0xffccaaa8),
      outlineVariant: Color(0xffa98987),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff7dcda),
      inversePrimary: Color(0xff94041a),
      primaryFixed: Color(0xffffdad8),
      onPrimaryFixed: Color(0xff2d0003),
      primaryFixedDim: Color(0xffffb3af),
      onPrimaryFixedVariant: Color(0xff730011),
      secondaryFixed: Color(0xffffdad8),
      onSecondaryFixed: Color(0xff2d0003),
      secondaryFixedDim: Color(0xffffb3af),
      onSecondaryFixedVariant: Color(0xff641d1e),
      tertiaryFixed: Color(0xffffdcbd),
      onTertiaryFixed: Color(0xff1e0d00),
      tertiaryFixedDim: Color(0xffffb86e),
      onTertiaryFixedVariant: Color(0xff522e00),
      surfaceDim: Color(0xff1d100f),
      surfaceBright: Color(0xff52403f),
      surfaceContainerLowest: Color(0xff0f0505),
      surfaceContainerLow: Color(0xff281a19),
      surfaceContainer: Color(0xff342423),
      surfaceContainerHigh: Color(0xff3f2e2e),
      surfaceContainerHighest: Color(0xff4b3938),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffecea),
      surfaceTint: Color(0xffffb3af),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffadaa),
      onPrimaryContainer: Color(0xff220002),
      secondary: Color(0xffffecea),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffffadaa),
      onSecondaryContainer: Color(0xff220002),
      tertiary: Color(0xffffedde),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffffb361),
      onTertiaryContainer: Color(0xff150800),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff1d100f),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffffecea),
      outlineVariant: Color(0xffdebab8),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff7dcda),
      inversePrimary: Color(0xff94041a),
      primaryFixed: Color(0xffffdad8),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffb3af),
      onPrimaryFixedVariant: Color(0xff2d0003),
      secondaryFixed: Color(0xffffdad8),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffffb3af),
      onSecondaryFixedVariant: Color(0xff2d0003),
      tertiaryFixed: Color(0xffffdcbd),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffffb86e),
      onTertiaryFixedVariant: Color(0xff1e0d00),
      surfaceDim: Color(0xff1d100f),
      surfaceBright: Color(0xff5e4c4a),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff2b1c1b),
      surfaceContainer: Color(0xff3d2c2b),
      surfaceContainerHigh: Color(0xff493736),
      surfaceContainerHighest: Color(0xff554241),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
