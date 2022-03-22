import 'package:flutter/material.dart';

const kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

const kLabelStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);

final kBoxDecorationStyle = BoxDecoration(
  color: const Color(0xFF6CA8F1),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: const [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);



class ColorConstants{
  static const Color primary = Color.fromARGB(255, 212, 212, 215);
  static const Color secondary = Color.fromARGB(255, 101, 175, 255);
  static const Color background = Color.fromARGB(255, 27, 31, 47);
  static const Color primaryHighlight = Color.fromARGB(255, 248, 139, 139);
  static const Color secondaryHighlight = Color.fromARGB(255, 142, 227, 239);
  static const Color backgroundHighlight = Color.fromARGB(255, 195, 60, 84);
}

class TextConstants{
  static const TextStyle titlePrimary = TextStyle(color: ColorConstants.primary, fontSize: 24);
  static const TextStyle defaultPrimary = TextStyle(color: ColorConstants.primary, fontSize: 16);
}