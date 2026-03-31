import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Responsive Scaling ─────────────────────────────────────────────────────
// Design baseline: 375 logical pixels (iPhone SE / small phone).
// All sizes scale proportionally to the device width.

double get _screenWidth {
  try {
    final w = Get.width;
    return w > 0 ? w : 375.0;
  } catch (_) {
    return 375.0;
  }
}

/// General layout scale factor (padding, radii, widget sizes).
double get _scaleFactor => (_screenWidth / 375.0).clamp(0.75, 1.4);

/// Font scale — slightly less aggressive to keep text readable on all sizes.
double get _fontScale => (_screenWidth / 375.0).clamp(0.8, 1.25);

/// Scale any hardcoded value responsively (layout proportions).
double rs(double value) => value * _scaleFactor;

/// Scale specifically for font sizes.
double fs(double value) => value * _fontScale;

// ─── Accent Colors (shared by both themes) ───────────────────────────────────
// Bright, saturated, child-friendly palette.

/// Vibrant purple — primary brand & CTA
const Color kPrimaryColor  = Color(0xFF6C5CE7);

/// Bright mint / aqua — secondary accents & gradients
const Color kSecondaryColor = Color(0xFF00CEC9);

/// Warm coral — lives, danger states, Count Puzzle card
const Color kRedColor      = Color(0xFFFF6348);

/// Sunshine yellow — coins, shop, Word-Categories card
const Color kYellowColor   = Color(0xFFFFD32A);

/// Bubblegum pink — Word-Search card
const Color kPinkColor     = Color(0xFFFF4D94);

/// Emerald green — correct answers, success states
const Color kGreenColor    = Color(0xFF2ED573);

/// Bright orange — streaks, energy, highlights
const Color kOrangeColor   = Color(0xFFFFA502);

/// Error red
const Color kErrorColor    = Color(0xFFFF4757);

// ─── Dark Theme Surface Colors ("cosmic night") ───────────────────────────────

const Color kDarkBgColor   = Color(0xFF13103F); // deep cosmic indigo
const Color kDarkCardColor = Color(0xFF1F1C6B); // medium indigo

// ─── Light Theme Surface Colors ("sunny day") ────────────────────────────────

const Color kLightBgColor   = Color(0xFFFFF8E7); // warm cream
const Color kLightCardColor = Color(0xFFFFFFFF); // white

// ─── Reactive dark-mode flag ─────────────────────────────────────────────────
// Shared RxBool that colour getters read so that any Obx ancestor rebuilds
// when the theme toggles. GameController writes to this in setDarkMode().
final RxBool isDarkObs = true.obs;

bool get _dark => isDarkObs.value;

/// Safe dark-mode check for use in build() methods outside Obx.
/// Falls back to isDarkObs when no context is available.
bool isDarkCtx(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

// ─── Dynamic Surface Colors (evaluated at call-site) ─────────────────────────

/// Background — adapts to dark / light mode.
Color get kBgColor   => _dark ? kDarkBgColor   : kLightBgColor;

/// Card / container — adapts to dark / light mode.
Color get kCardColor => _dark ? kDarkCardColor : kLightCardColor;

// ─── Dynamic Text & Border Colors ────────────────────────────────────────────

/// Primary text
Color get kTextPrimary   => _dark ? Colors.white               : const Color(0xFF13103F);

/// Secondary text
Color get kTextSecondary => _dark ? Colors.white70             : const Color(0xFF4A3F8A);

/// Hint / caption text
Color get kTextHint      => _dark ? Colors.white54             : const Color(0xFF7A72B0);

/// Disabled / decorative text
Color get kTextDisabled  => _dark ? Colors.white38             : const Color(0xFFB0AACC);

/// Subtle border / divider
Color get kBorderColor   => _dark ? Colors.white24             : const Color(0xFFD4CEF5);

// ─── Gradient ─────────────────────────────────────────────────────────────────

/// Brand gradient — purple → bubblegum pink (playful for children)
const LinearGradient kBrandGradient = LinearGradient(
  colors: [kPrimaryColor, kPinkColor],
);

// ─── Splash / Onboarding gradient start ──────────────────────────────────────
// Used in SplashScreen and LanguageScreen as the top colour of the bg gradient.
Color get kGradientTop => _dark
    ? const Color(0xFF0A0828)   // deeper indigo for dark
    : const Color(0xFFEDE7FF);  // lavender tint for light

// ─── Font Sizes (child-optimised, now responsive) ──────────────────────────
// Sizes scale based on screen width for consistent look across devices.

/// Hero / splash title
double get kFontSizeDisplay => fs(46.0);

/// Screen & section titles
double get kFontSizeH1      => fs(38.0);

/// Card / dialog headings
double get kFontSizeH2      => fs(30.0);

/// Sub-headings, option labels
double get kFontSizeH3      => fs(24.0);

/// Emphasised labels, button text
double get kFontSizeH4      => fs(20.0);

/// Primary body / large list text
double get kFontSizeBodyLarge => fs(17.0);

/// Standard body text
double get kFontSizeBody     => fs(15.0);

/// Hints, captions, secondary info
double get kFontSizeCaption  => fs(13.0);

/// Badges, chips, grid cell labels
double get kFontSizeTiny     => fs(12.0);

// ─── Spacing (responsive) ───────────────────────────────────────────────────

double get kPaddingS => rs(8.0);
double get kPaddingM => rs(16.0);
double get kPaddingL => rs(20.0);

// ─── Border Radii (responsive) ──────────────────────────────────────────────

double get kRadiusS    => rs(14.0);
double get kRadiusM    => rs(16.0);
double get kRadiusL    => rs(20.0);
double get kRadiusPill => rs(24.0);

// ─── Fonts ───────────────────────────────────────────────────────────────────

TextTheme _arabicTextTheme(ThemeData base) =>
    GoogleFonts.cairoTextTheme(base.textTheme);

TextTheme _englishTextTheme(ThemeData base) =>
    GoogleFonts.nunitoTextTheme(base.textTheme);

// Legacy getters kept for any direct call-sites.
TextTheme get kArabicTextTheme  => _arabicTextTheme(ThemeData.dark());
TextTheme get kEnglishTextTheme => _englishTextTheme(ThemeData.dark());

/// Returns the correct [TextStyle] for the given language.
TextStyle kTextStyle({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.normal,
  Color? color,
  bool isAr = false,
}) {
  final c = color ?? kTextPrimary;
  if (isAr) {
    return GoogleFonts.cairo(fontSize: fs(fontSize), fontWeight: fontWeight, color: c);
  }
  return GoogleFonts.nunito(fontSize: fs(fontSize), fontWeight: fontWeight, color: c);
}

// ─── Theme Builder ────────────────────────────────────────────────────────────

/// Builds the full [ThemeData] for a given language and brightness.
ThemeData buildAppTheme(String lang, bool isDark) {
  final base      = isDark ? ThemeData.dark() : ThemeData.light();
  final textTheme = lang == 'ar' ? _arabicTextTheme(base) : _englishTextTheme(base);

  return ThemeData(
    brightness: isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: isDark ? kDarkBgColor : kLightBgColor,
    cardColor: isDark ? kDarkCardColor : kLightCardColor,
    colorScheme: isDark
        ? const ColorScheme.dark(
            primary:   kPrimaryColor,
            secondary: kSecondaryColor,
            surface:   kDarkCardColor,
            error:     kErrorColor,
          )
        : const ColorScheme.light(
            primary:   kPrimaryColor,
            secondary: kSecondaryColor,
            surface:   kLightCardColor,
            error:     kErrorColor,
          ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: isDark ? Colors.white : const Color(0xFF13103F),
    ),
    textTheme: textTheme,
    useMaterial3: true,
  );
}

// ─── App Info ─────────────────────────────────────────────────────────────────

const String kAppNameEn       = 'Brain Play';
const String kAppNameAr       = 'فكر .. العب .. اكسب';
const String kAppTaglineEn    = 'Games Box';
const String kAppTaglineAr    = 'صندوق الألعاب';
