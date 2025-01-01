import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const sPrimaryColor = Color(0xff000418);
const sSecondaryColor = Color(0xff00093d);
const sThirdColor = Color(0xff011080);
const sTextColor = Color(0xffD48F0A);

const sFillColor = Color(0xBEFFFFFF);
const sGreenColor = Color(0xBE01A20E);

const iCpuImage = 'assets/images/cpu.png';
const iGpuImage = 'assets/images/graphic-card.png';
const iMoboImage = 'assets/images/motherboard.png';
const iRamImage = 'assets/images/ram.png';
const iStorageImage = 'assets/images/ssd.png';
const iPSUImage = 'assets/images/power-supply.png';

double bigFont = 20.0;
double smallFont = 13.0;
double tinyFont = 10.0;

TextStyle stdTextStyle(scolor, fontsz) => GoogleFonts.inter(
    fontWeight: FontWeight.bold, color: scolor, fontSize: fontsz);

