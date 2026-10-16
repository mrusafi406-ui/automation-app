class OrderItem {
  final String productId;
  final String productName;
  final int cartons;
  final int pcs;
  final double dpRate;
  final int pcsPerCarton;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.cartons,
    required this.pcs,
    required this.dpRate,
    this.pcsPerCarton = 24,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'cartons': cartons,
      'pcs': pcs,
      'dpRate': dpRate,
      'pcsPerCarton': pcsPerCarton,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      cartons: map['cartons'] ?? 0,
      pcs: map['pcs'] ?? 0,
      dpRate: (map['dpRate'] ?? 0).toDouble(),
      pcsPerCarton: map['pcsPerCarton'] ?? 24,
    );
  }

  double get totalValue => (cartons * pcsPerCarton * dpRate) + (pcs * dpRate);
}

class Order {
  final String id;
  final String date;
  final String day;
  final String route;
  final String soName;
  final String shopName;
  final String shopId;
  final List<OrderItem> items;
  final double totalValue;

  Order({
    required this.id,
    required this.date,
    required this.day,
    required this.route,
    required this.soName,
    required this.shopName,
    required this.shopId,
    required this.items,
    required this.totalValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'day': day,
      'route': route,
      'soName': soName,
      'shopName': shopName,
      'shopId': shopId,
      'items': items.map((i) => i.toMap()).toList(),
      'totalValue': totalValue,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  factory Order.fromMap(String id, Map<String, dynamic> map) {
    return Order(
      id: id,
      date: map['date'] ?? '',
      day: map['day'] ?? '',
      route: map['route'] ?? '',
      soName: map['soName'] ?? '',
      shopName: map['shopName'] ?? '',
      shopId: map['shopId'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      totalValue: (map['totalValue'] ?? 0).toDouble(),
    );
  }
}
