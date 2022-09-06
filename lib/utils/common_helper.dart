import 'dart:math' as math;

import 'package:intl/intl.dart';

class CommonHelper {
  static Map<String, dynamic> calcArea({distance, latCenter, lngCenter}) {
    double cLat = (180 / math.pi) * (distance / 6378137);
    double batasKiri = lngCenter - cLat;
    double batasKanan = lngCenter + cLat;
    double batasAtas = latCenter + cLat;
    double batasBawah = latCenter - cLat;
    return {
      'batasKiri': batasKiri,
      'batasKanan': batasKanan,
      'batasAtas': batasAtas,
      'batasBawah': batasBawah,
    };
  }

  static String toShortDateText(context, DateTime date) {
    return DateFormat('dd/MM/yyyy H:m:s').format(date);
  }
}
