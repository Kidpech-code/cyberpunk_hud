import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color Palette ─────────────────────────────────────────────────────────
const kPrimary = Color(0xFF00F3FF); // Cyan Neon
const kSecondary = Color(0xFFBC13FE); // Purple Neon
const kAlert = Color(0xFFFF2A2A); // Red Alert
const kBg = Color(0xFF020408); // Near Black
const kSuccess = Color(0xFF00FF00); // Terminal Green
const kWarning = Color(0xFFFFFF00); // Terminal Yellow
const kError = Color(0xFFFF0000); // Terminal Red

const kPrimaryGlass = Color(0x0800F3FF); // rgba(0,243,255,0.03)
const kPrimaryBorder = Color(0x4D00F3FF); // rgba(0,243,255,0.30)
const kPrimaryGlow = Color(0x1A00F3FF); // rgba(0,243,255,0.10)
const kCardBg = Color(0x990A141E); // rgba(10,20,30,0.60)

// ─── Text Styles ───────────────────────────────────────────────────────────
TextStyle orbitron(
  double size, {
  FontWeight weight = FontWeight.w900,
  Color color = kPrimary,
  double letterSpacing = 2,
}) => GoogleFonts.orbitron(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: letterSpacing,
  shadows: [Shadow(color: color.withValues(alpha: 0.8), blurRadius: 20)],
);

TextStyle shareTech(
  double size, {
  Color color = kPrimary,
  double letterSpacing = 1,
}) => GoogleFonts.shareTechMono(
  fontSize: size,
  color: color,
  letterSpacing: letterSpacing,
);

// ─── MaterialApp Theme ─────────────────────────────────────────────────────
ThemeData cyberTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: kBg,
    colorScheme: const ColorScheme.dark(
      primary: kPrimary,
      secondary: kSecondary,
      error: kAlert,
      surface: kBg,
    ),
    textTheme: GoogleFonts.shareTechMonoTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: kPrimary, displayColor: kPrimary),
  );
}
