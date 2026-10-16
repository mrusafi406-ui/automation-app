import 'package:flutter/material.dart';

class SalesSubTab extends StatelessWidget {
  const SalesSubTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text('Sales Sub-tab', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Sales entry will be added in the next step.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
