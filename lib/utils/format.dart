// Formats ingredient quantity
String formatQty(double v) {
  if (v >= 20) {
    return v.round().toString();
  }

  int whole = v.floor();
  double frac = v - whole;

  String fraction = '';

  if ((frac - 0.25).abs() < 0.04) {
    fraction = '1/4';
  } else if ((frac - 0.33).abs() < 0.04) {
    fraction = '1/3';
  } else if ((frac - 0.50).abs() < 0.04) {
    fraction = '1/2';
  } else if ((frac - 0.67).abs() < 0.04) {
    fraction = '2/3';
  } else if ((frac - 0.75).abs() < 0.04) {
    fraction = '3/4';
  } else {
    return v.toStringAsFixed(1);
  }

  if (whole == 0) {
    return fraction;
  }

  return '$whole $fraction';
}

// Formats cooking time
String formatMinutes(int m) {
  if (m < 60) {
    return '$m min';
  }

  int h = m ~/ 60;
  int r = m % 60;

  if (r == 0) {
    return '$h h';
  } else {
    return '$h h $r min';
  }
}