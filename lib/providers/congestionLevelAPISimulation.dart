import 'dart:math';

Future<List<double>> fetchCongestionLevels() async {
  List<int> numbers = [];
  List<String> classifications = [];
  List<double> coefficients = [];
  List<double> congestionLevels = [];

  var random = Random();

  for (int i = 0; i < 10; i++) {
    int randomNumber = random.nextInt(1001);
    numbers.add(randomNumber);

    String? classification;
    if (randomNumber >= 0 && randomNumber < 400) {
      classification = "low";
    } else if (randomNumber >= 400 && randomNumber < 700) {
      classification = "mid";
    } else if (randomNumber >= 700 && randomNumber < 900) {
      classification = "upper-mid";
    } else if (randomNumber >= 900 && randomNumber <= 1000) {
      classification = "high";
    }

    classifications.add(classification!);

    double coefficient;
    switch (classification) {
      case "low":
        coefficient = 0.002;
        break;
      case "mid":
        coefficient = 0.004;
        break;
      case "upper-mid":
        coefficient = 0.008;
        break;
      case "high":
        coefficient = 0.01;
        break;
      default:
        coefficient = 0;
        break;
    }
    coefficients.add(coefficient);
  }

  for (int i = 0; i < numbers.length; i++) {
    double congestionLevel = numbers[i] * coefficients[i];
    congestionLevels.add(congestionLevel);
  }

  return Future.delayed(Duration(seconds: 1), () => congestionLevels);
}