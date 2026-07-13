class Formulas {
  static int tested(int good, int reject, int qa, int sample) {
    return good + reject + qa + sample;
  }

  static double gross(int tested) {
    return tested / 144;
  }
}
