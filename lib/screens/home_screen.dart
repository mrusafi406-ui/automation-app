import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:automation_app/providers/auth_provider.dart';
import 'package:automation_app/screens/tabs/data_entry_tab.dart';
import 'package:automation_app/screens/tabs/dashboard_tab.dart';
import 'package:automation_app/screens/tabs/inventory_tab.dart';
import 'package:automation_app/screens/tabs/performance_tab.dart';
import 'package:automation_app/screens/tabs/automation_tab.dart';
import 'package:automation_app/screens/tabs/credit_debit_tab.dart';
import 'package:automation_app/screens/tabs/setup_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _tabs;
  late List<String> _tabNames;

  @override
  void initState() {
    super.initState();
    final role = Provider.of<AuthProvider>(context, listen: false).role;
    
    if (role == 'Sales Officer') {
      _currentIndex = 0; 
      _tabs = [const DataEntryTab(), const DashboardTab(), const InventoryTab(), const PerformanceTab(), const AutomationTab(), const CreditDebitTab()];
      _tabNames = ['Data Entry', 'Dashboard', 'Inventory', 'Performance', 'Automation', 'Credit & Debit'];
    } else if (role == 'Admin') {
      _currentIndex = 1; 
      _tabs = [const DataEntryTab(), const DashboardTab(), const InventoryTab(), const PerformanceTab(), const AutomationTab(), const CreditDebitTab(), const SetupTab()];
      _tabNames = ['Data Entry', 'Dashboard', 'Inventory', 'Performance', 'Automation', 'Credit & Debit', 'Setup'];
    } else {
      _currentIndex = 0; 
      _tabs = [const DashboardTab(), const InventoryTab(), const PerformanceTab(), const AutomationTab(), const CreditDebitTab()];
      _tabNames = ['Dashboard', 'Inventory', 'Performance', 'Automation', 'Credit & Debit'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: List.generate(_tabs.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_getIconForTab(_tabNames[index])),
            label: _tabNames[index],
          );
        }),
      ),
    );
  }

  IconData _getIconForTab(String tabName) {
    switch (tabName) {
      case 'Data Entry': return Icons.edit_note;
      case 'Dashboard': return Icons.dashboard;
      case 'Inventory': return Icons.inventory;
      case 'Performance': return Icons.bar_chart;
      case 'Automation': return Icons.settings_suggest;
      case 'Credit & Debit': return Icons.account_balance_wallet;
      case 'Setup': return Icons.settings;
      default: return Icons.circle;
    }
  }
}
