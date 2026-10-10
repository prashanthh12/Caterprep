import '../constants/app_units.dart';

class QuantityUtils {
  static String formatQuantity(double qty) {
    if (qty == qty.roundToDouble()) {
      return qty.toInt().toString();
    }
    // Remove trailing zeros if any
    final str = qty.toStringAsFixed(2);
    if (str.endsWith('.00')) {
      return qty.toInt().toString();
    }
    if (str.endsWith('0')) {
      return str.substring(0, str.length - 1);
    }
    return str;
  }

  static String formatWithUnit(double qty, String unit, {bool includeKannada = false}) {
    final qtyStr = formatQuantity(qty);
    if (includeKannada) {
      final unitDef = AppUnits.getUnit(unit);
      return '$qtyStr ${unitDef.display} (${unitDef.displayKannada})';
    }
    return '$qtyStr $unit';
  }

  static double getStepForUnit(String unit) {
    final unitDef = AppUnits.getUnit(unit);
    return unitDef.defaultStep;
  }

  static double increment(double current, String unit) {
    final step = getStepForUnit(unit);
    final next = (current + step);
    return double.parse(next.toStringAsFixed(2));
  }

  static double decrement(double current, String unit) {
    final step = getStepForUnit(unit);
    final next = (current - step);
    if (next < step) {
      return step; // minimum 1 step
    }
    return double.parse(next.toStringAsFixed(2));
  }
}
