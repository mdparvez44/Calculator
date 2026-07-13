class Production {
  int? id;

  String machine;

  String plant;

  String productCode;

  int good;

  int reject;

  int qa;

  int sample;

  int tested;

  Production({
    this.id,
    required this.machine,
    required this.plant,
    required this.productCode,
    required this.good,
    required this.reject,
    required this.qa,
    required this.sample,
    required this.tested,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'machine': machine,
      'plant': plant,
      'productCode': productCode,
      'good': good,
      'reject': reject,
      'qa': qa,
      'sample': sample,
      'tested': tested,
    };
  }

  factory Production.fromMap(Map<String, dynamic> map) {
    return Production(
      id: map['id'],
      machine: map['machine'],
      plant: map['plant'],
      productCode: map['productCode'],
      good: map['good'],
      reject: map['reject'],
      qa: map['qa'],
      sample: map['sample'],
      tested: map['tested'],
    );
  }
}
