import 'package:flutter/material.dart';

class EmployeeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Dashboard'),
      ),
      body: Center(
        child: Text('Welcome, Employee!'),
      ),
    );
  }
}
