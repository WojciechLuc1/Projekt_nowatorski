import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BorrowedItemInfoScreen extends StatelessWidget {
  final QueryDocumentSnapshot item;

  BorrowedItemInfoScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    final borrowedByName = item['borrowedByName'] ?? 'None';
    final borrowedBySurname = item['borrowedBySurname'] ?? 'None';
    final borrowPeriodStart = item['borrowPeriodStart'] != null 
        ? (item['borrowPeriodStart'] as Timestamp).toDate() 
        : null;
    final borrowPeriodEnd = item['borrowPeriodEnd'] != null 
        ? (item['borrowPeriodEnd'] as Timestamp).toDate() 
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Borrowed Item Information'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${item['name']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Description: ${item['description']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Borrowed by: $borrowedByName $borrowedBySurname',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Borrow Period: ${borrowPeriodStart != null ? DateFormat('yyyy-MM-dd').format(borrowPeriodStart) : 'N/A'} to ${borrowPeriodEnd != null ? DateFormat('yyyy-MM-dd').format(borrowPeriodEnd) : 'N/A'}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
