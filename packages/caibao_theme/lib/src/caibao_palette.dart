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
    required this.info,
    required this.violet,
    required this.success,
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
  final Color info;
  final Color violet;
  final Color success;
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
  Color get onUserBubble => brandOn;
  Color get onAccentIcon => brandOn;

  static const Color brandHex = Color(0xFF1A9B7A);
  static const Color brandDarkHex = Color(0xFF147A5F);
  static const Color brandOnHex = Color(0xFFFFFFFF);
  static const Color infoHex = Color(0xFF3B82F6);
  static const Color violetHex = Color(0xFF8B5CF6);
  static const Color successHex = Color(0xFF10B981);
  static const Color userBubbleHex = Color(0xFF1A9B7A);

  static const CaibaoPalette light = CaibaoPalette(
    brand: brandHex,
    brandDark: brandDarkHex,
    brandOn: brandOnHex,
    brandContainer: Color(0xFFD0F1E1),
    brandOnContainer: brandDarkHex,
    background: Color(0xFFF5F6F8),
    foreground: Color(0xFF1A1A1A),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF1A1A1A),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF1A1A1A),
    secondary: Color(0xFFF2F3F5),
    secondaryForeground: Color(0xFF1A1A1A),
    muted: Color(0xFFE8E8E8),
    mutedForeground: Color(0xFF8E8E93),
    accent: Color(0xFFF2F3F5),
    accentForeground: Color(0xFF1A1A1A),
    danger: Color(0xFFCC272E),
    info: infoHex,
    violet: violetHex,
    success: successHex,
    ring: brandHex,
    sidebar: Color(0xFFFFFFFF),
    sidebarForeground: Color(0xFF1A1A1A),
    userBubble: userBubbleHex,
    assistantBubble: Color(0xFFFFFFFF),
    code: Color(0xFFF0F2F5),
    codeHeader: Color(0xFFE5E8ED),
    codeForeground: Color(0xFF181B1F),
    codeMuted: Color(0xFF8E8E93),
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
    info: infoHex,
    violet: violetHex,
    success: successHex,
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
