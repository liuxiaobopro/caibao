import 'package:flutter/material.dart';

/// Semantic palette mapped from web `globals.css` (caibao-nextjs).
@immutable
class CaibaoPalette {
  const CaibaoPalette({
    required this.brand,
    required this.brandDark,
    required this.brandOn,
    required this.brandContainer,
    required this.brandOnContainer,
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.danger,
    required this.ring,
    required this.sidebar,
    required this.sidebarForeground,
    required this.userBubble,
    required this.assistantBubble,
    required this.code,
    required this.codeHeader,
    required this.codeForeground,
    required this.codeMuted,
  });

  final Color brand;
  final Color brandDark;
  final Color brandOn;
  final Color brandContainer;
  final Color brandOnContainer;
  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color popover;
  final Color popoverForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color accent;
  final Color accentForeground;
  final Color danger;
  final Color ring;
  final Color sidebar;
  final Color sidebarForeground;
  final Color userBubble;
  final Color assistantBubble;
  final Color code;
  final Color codeHeader;
  final Color codeForeground;
  final Color codeMuted;

  Color get surface => card;
  Color get surfaceVariant => secondary;
  Color get outline => Colors.transparent;

  /// Fixed brand hex from web design tokens.
  static const Color brandHex = Color(0xFF1A9B7A);
  static const Color brandDarkHex = Color(0xFF147A5F);
  static const Color brandOnHex = Color(0xFFFFFFFF);

  static const CaibaoPalette light = CaibaoPalette(
    brand: brandHex,
    brandDark: brandDarkHex,
    brandOn: brandOnHex,
    brandContainer: Color(0xFFD0F1E1),
    brandOnContainer: brandDarkHex,
    background: Color(0xFFF3F5F9),
    foreground: Color(0xFF0F1216),
    card: Color(0xFFFBFCFD),
    cardForeground: Color(0xFF0F1216),
    popover: Color(0xFFFBFCFD),
    popoverForeground: Color(0xFF0F1216),
    secondary: Color(0xFFE5E8ED),
    secondaryForeground: Color(0xFF1F2227),
    muted: Color(0xFFE5E8ED),
    mutedForeground: Color(0xFF595E66),
    accent: Color(0xFFE2EAE6),
    accentForeground: Color(0xFF142F24),
    danger: Color(0xFFCC272E),
    ring: brandHex,
    sidebar: Color(0xFFF0F2F5),
    sidebarForeground: Color(0xFF0F1216),
    userBubble: brandHex,
    assistantBubble: Color(0xFFFBFCFD),
    code: Color(0xFFF0F2F5),
    codeHeader: Color(0xFFE5E8ED),
    codeForeground: Color(0xFF181B1F),
    codeMuted: Color(0xFF595E66),
  );

  static const CaibaoPalette dark = CaibaoPalette(
    brand: brandHex,
    brandDark: brandDarkHex,
    brandOn: brandOnHex,
    brandContainer: Color(0xFF052016),
    brandOnContainer: Color(0xFFB0D9C6),
    background: Color(0xFF06070A),
    foreground: Color(0xFFE4E8EF),
    card: Color(0xFF0D1014),
    cardForeground: Color(0xFFE4E8EF),
    popover: Color(0xFF111418),
    popoverForeground: Color(0xFFE4E8EF),
    secondary: Color(0xFF171B20),
    secondaryForeground: Color(0xFFDADEE5),
    muted: Color(0xFF171B20),
    mutedForeground: Color(0xFF9399A2),
    accent: Color(0xFF11241C),
    accentForeground: Color(0xFFC0E0D1),
    danger: Color(0xFFDB4241),
    ring: brandHex,
    sidebar: Color(0xFF090B0F),
    sidebarForeground: Color(0xFFE4E8EF),
    userBubble: brandDarkHex,
    assistantBubble: Color(0xFF171B20),
    code: Color(0xFF1E1F22),
    codeHeader: Color(0xFF2B2D31),
    codeForeground: Color(0xFFE8EAED),
    codeMuted: Color(0xFF9399A2),
  );

  ColorScheme toColorScheme(Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: brand,
      onPrimary: brandOn,
      primaryContainer: brandContainer,
      onPrimaryContainer: brandOnContainer,
      secondary: secondary,
      onSecondary: secondaryForeground,
      secondaryContainer: muted,
      onSecondaryContainer: secondaryForeground,
      tertiary: accent,
      onTertiary: accentForeground,
      error: danger,
      onError: brandOn,
      surface: card,
      onSurface: foreground,
      surfaceContainerHighest: secondary,
      onSurfaceVariant: mutedForeground,
      outline: outline,
      outlineVariant: muted,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: foreground,
      onInverseSurface: background,
      inversePrimary: brandDark,
    );
  }
}
