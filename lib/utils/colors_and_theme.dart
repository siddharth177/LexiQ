import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


Color kLightPrimaryColor = const Color(0xFF8370CF);
Color kLightSecondaryColor = const Color(0xFFA4A5F5);
Color kLightTertiaryColor = const Color(0xFFB5C7EB);
Color kLightQuaternaryColor = const Color(0xFF9EF0FF);

Color kLightBlackShade1 = const Color(0xFF242424);
Color kLightGreyShade1 = const Color(0xFFf7f7f7);//#F8F7F8
Color kLightGreyShade2 = const Color(0xFFA7A7A7);
Color kLightGreyShade3 = const Color(0xFFCBCBCB);
Color kLightWhiteShade1 = const Color(0xFFFFFFFF);


Color kDarkPrimaryColor = const Color(0xFF292966);
Color kDarkSecondaryColor = const Color(0xFF5C5C99);
Color kDarkTertiaryColor = const Color(0xFFA3A3CC);
Color kDarkQuaternaryColor = const Color(0xFFCCCCFF);

Color kDarkBlackShade1 = const Color(0xFF292929);//#121212
Color kDarkBlackShade2 = const Color(0xFF111111);//1D1D1E
Color kDarkGreyShade1 = const Color(0xFF333333);//#232425
Color kDarkGreyShade2 = const Color(0xFF484848);//#E6E6E6
Color kDarkWhiteShade1 = const Color(0xFFDDDDDD);//#EFEFEF
Color kDarkWhiteShade2 = const Color(0xFFE0E0E0);//#FAFAFA


var kPrimaryFontTheme = GoogleFonts.poppinsTextTheme();
var kSecondaryFontTheme = GoogleFonts.openSansTextTheme();
var kTertiaryFontTheme = GoogleFonts.robotoMonoTextTheme();

var kLightColorScheme = ColorScheme.fromSeed(seedColor: kLightPrimaryColor);
var kDarkColorScheme = ColorScheme.fromSeed(seedColor: kDarkPrimaryColor, brightness: Brightness.dark);


var kLightThemeData = ThemeData().copyWith(
  floatingActionButtonTheme: const FloatingActionButtonThemeData().copyWith(
    backgroundColor: kLightGreyShade1
  ),
  cardTheme: const CardTheme().copyWith(
    elevation: 2
  ).data,
  snackBarTheme: const SnackBarThemeData().copyWith(
    backgroundColor: kDarkSecondaryColor,
  ),
  textTheme: kPrimaryFontTheme,
  colorScheme: kLightColorScheme,
  brightness: Brightness.light,
);

var kDartTextTheme = GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);

var kDarkThemeData = kLightThemeData.copyWith(
  colorScheme: kDarkColorScheme,
  scaffoldBackgroundColor: kDarkBlackShade2,
  brightness: Brightness.dark,
  searchBarTheme: const SearchBarThemeData().copyWith(
      backgroundColor: WidgetStateProperty.all<Color>(kDarkBlackShade2),
      textStyle: WidgetStateProperty.all(const TextStyle().copyWith(
          color: kDarkWhiteShade1
      )),
    hintStyle: WidgetStateProperty.all(TextStyle(color: kDarkWhiteShade1))
  ),
  appBarTheme: const AppBarTheme().copyWith(
      backgroundColor: kDarkGreyShade1,
      foregroundColor: kDarkWhiteShade1
  ),
  cardTheme: const CardTheme().copyWith(
    color: kDarkGreyShade2,
  ).data,
  textTheme: kDartTextTheme,
  floatingActionButtonTheme: const FloatingActionButtonThemeData().copyWith(
      backgroundColor: kDarkBlackShade1,
      foregroundColor: kDarkWhiteShade1,
    elevation: 20
  ),
  popupMenuTheme: const PopupMenuThemeData().copyWith(
    enableFeedback: true,
    color: kDarkBlackShade2,
  ),
  dropdownMenuTheme: const DropdownMenuThemeData().copyWith(
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(kDarkBlackShade2),
    ),
    textStyle: TextStyle(
      color: kDarkWhiteShade1
    ),
  ),
  snackBarTheme: const SnackBarThemeData().copyWith(
    backgroundColor: kDarkPrimaryColor,
    actionTextColor: kDarkBlackShade1,
    contentTextStyle: TextStyle(color: kDarkWhiteShade1)
  ),
);
