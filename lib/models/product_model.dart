class Product {
  final String id;
  final String name;
  final String code;
  final String category;
  final int pcsPerCarton;
  final double tpPerCarton;
  final double dpPerPcs;
  final String imageFileName;

  Product({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.pcsPerCarton,
    required this.tpPerCarton,
    required this.dpPerPcs,
    required this.imageFileName,
  });

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      category: map['category'] ?? '',
      pcsPerCarton: map['pcsPerCarton'] ?? 1,
      tpPerCarton: (map['tpPerCarton'] ?? 0).toDouble(),
      dpPerPcs: (map['dpPerPcs'] ?? 0).toDouble(),
      imageFileName: map['imageFileName'] ?? '',
    );
  }

  double get dpPerCarton => dpPerPcs * pcsPerCarton;
}
