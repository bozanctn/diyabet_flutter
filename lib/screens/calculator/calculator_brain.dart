import 'dart:math';

class CalculatorBrain {
  CalculatorBrain({required this.height, required this.weight});

  final int height;
  final int weight;

  late double _bmi;

  String calculateBMI() {
    _bmi = weight / pow(height / 100, 2);
    return _bmi.toStringAsFixed(1);
  }

  String getResult() {
    if (_bmi >= 25) {
      return 'Kilolu';
    } else if (_bmi > 18.5) {
      return 'Normal';
    } else {
      return 'Zayıf';
    }
  }

  String getInterpretation() {
    if (_bmi >= 25) {
      return 'Normalden fazla kilonuz var. Daha fazla egzersiz yapmayı deneyin.';
    } else if (_bmi >= 18.5) {
      return 'Normal kilonuz var. Tebrikler!';
    } else {
      return 'Normalden daha az kilonuz var. Biraz daha yiyebilirsiniz.';
    }
  }
}
