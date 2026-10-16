import 'package:flutter/material.dart';
import 'package:automation_app/screens/tabs/order_sub_tab.dart';
import 'package:automation_app/screens/tabs/sales_sub_tab.dart';

class DataEntryTab extends StatelessWidget {
  const DataEntryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Data Entry'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Order', icon: Icon(Icons.shopping_cart)),
              Tab(text: 'Sales', icon: Icon(Icons.trending_up)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrderSubTab(),
            SalesSubTab(),
          ],
        ),
      ),
    );
  }
}
