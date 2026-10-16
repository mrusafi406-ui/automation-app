class OrderItem {
  final String productId;
  final String productName;
  final int cartons;
  final int pcs;
  final double dpRate;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.cartons,
    required this.pcs,
    required this.dpRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'cartons': cartons,
      'pcs': pcs,
      'dpRate': dpRate,
    };
  }

  double get totalValue => (cartons * pcsPerCarton * dpRate) + (pcs * dpRate);
  
  // এই ভেরিয়েবলটি পরে সেটআপ ট্যাব থেকে আসবে
  int get pcsPerCarton => 24; 
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
    };
  }
}
