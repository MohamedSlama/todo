import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const Color bluishClr = Color(0xFF4e5ae8);
const Color orangeClr = Color(0xCFFF8746);
const Color pinkClr = Color(0xFFff4667);
const Color white = Colors.white;
const primaryClr = bluishClr;
const Color darkGreyClr = Color(0xFF121212);
const Color darkHeaderClr = Color(0xFF424242);

class Themes {
  //? Light Mode
  static final light = ThemeData(
    primaryColor: primaryClr,
    backgroundColor: Colors.white,
    brightness: Brightness.light,
  );

  //? Dark Mode
  static final dark = ThemeData(
    primaryColor: darkGreyClr,
    backgroundColor: darkGreyClr,
    brightness: Brightness.dark,
  );
}

//? Headers text style
TextStyle get headingStyle => GoogleFonts.lato(
      textStyle: TextStyle(
          color: Get.isDarkMode ? Colors.white : Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold),
    );

//? Sub headers text style
TextStyle get subHeadingStyle => GoogleFonts.lato(
      textStyle: TextStyle(
          color: Get.isDarkMode ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold),
    );

//? Title text style
TextStyle get titleStyle => GoogleFonts.lato(
      textStyle: TextStyle(
          color: Get.isDarkMode ? Colors.white : Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold),
    );

//? Sub title text style
TextStyle get subTitleStyle => GoogleFonts.lato(
      textStyle: TextStyle(
          color: Get.isDarkMode ? Colors.white : Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w400),
    );

//? Body text style
TextStyle get bodyStyle => GoogleFonts.lato(
      textStyle: TextStyle(
          color: Get.isDarkMode ? Colors.white : Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w400),
    );

//? Body2 text style
TextStyle get body2Style => GoogleFonts.lato(
      textStyle: TextStyle(
          color: Get.isDarkMode ? Colors.grey[200] : Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w400),
    );
