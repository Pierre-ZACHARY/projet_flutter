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
  static const TextStyle defaultSecondary = TextStyle(color: Colors.black, fontSize: 16);
  static const TextStyle hintPrimary = TextStyle(color: ColorConstants.primary, fontSize: 10);
}


class InputDecorationBuilder{
  late InputDecoration _decoration;
  InputDecorationBuilder(){
    _decoration = const InputDecoration(
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorConstants.primaryHighlight, width: 2.0), borderRadius: BorderRadius.all(Radius.circular(0))),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorConstants.primary, width: 2.0), borderRadius: BorderRadius.all(Radius.circular(0))),
        disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorConstants.secondary, width: 2.0), borderRadius: BorderRadius.all(Radius.circular(0))),
        fillColor: ColorConstants.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(0)),
        ),
        labelStyle: TextConstants.defaultPrimary,
        counterStyle: TextConstants.hintPrimary
    );
  }

  InputDecorationBuilder _setField({String? label, Color? primaryColor, Color? primaryHighlight, BorderRadius? borderRadius, double? borderWidth}){
   _decoration = InputDecoration(
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryHighlight ?? _decoration.focusedBorder!.borderSide.color, width: borderWidth ?? _decoration.focusedBorder!.borderSide.width), borderRadius: borderRadius ?? (_decoration.focusedBorder! as OutlineInputBorder).borderRadius),
        disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: _decoration.enabledBorder!.borderSide.color, width: borderWidth ?? _decoration.focusedBorder!.borderSide.width), borderRadius: borderRadius ?? (_decoration.enabledBorder! as OutlineInputBorder).borderRadius),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor ?? _decoration.enabledBorder!.borderSide.color, width: borderWidth ?? _decoration.focusedBorder!.borderSide.width), borderRadius: borderRadius ?? (_decoration.disabledBorder! as OutlineInputBorder).borderRadius),
        border: OutlineInputBorder(
          borderRadius: borderRadius ?? (_decoration.border as OutlineInputBorder).borderRadius,
        ),
        fillColor: primaryColor ?? _decoration.fillColor,
        labelStyle: _decoration.labelStyle,
        counterStyle: _decoration.counterStyle,
        labelText: label ?? _decoration.labelText);


    return this;
  }

  InputDecorationBuilder addLabel(String label){
    return _setField(label: label);
  }

  InputDecorationBuilder setPrimaryColor(Color primary){
    return _setField(primaryColor: primary);
  }

  InputDecorationBuilder setPrimaryHighlightColor(Color primaryHighlight){
    return _setField(primaryHighlight: primaryHighlight);
  }

  InputDecorationBuilder setBorderRadius(BorderRadius borderRadius){
    return _setField(borderRadius: borderRadius);
  }

  InputDecorationBuilder setBorderWidth(double borderWidth){
    return _setField(borderWidth: borderWidth);
  }

  InputDecoration build(){
    return _decoration;
  }
}