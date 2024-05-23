import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Dodaj ten import

class ItemInfoScreen extends StatelessWidget {
  final QueryDocumentSnapshot item;
  final bool isEmployee;

  ItemInfoScreen({required this.item, this.isEmployee = false});

  Future<void> _deleteItem(BuildContext context) async {
    await FirebaseFirestore.instance.collection('items').doc(item.id).delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isBorrowed = item['isBorrowed'] ?? false;
    final data = item.data() as Map<String, dynamic>?;
    final borrowedByName = data != null && data.containsKey('borrowedByName') ? item['borrowedByName'] : 'None';
    final borrowedBySurname = data != null && data.containsKey('borrowedBySurname') ? item['borrowedBySurname'] : 'None';
    final borrowPeriodStart = data != null && data.containsKey('borrowPeriodStart') && item['borrowPeriodStart'] != null 
        ? (item['borrowPeriodStart'] as Timestamp).toDate() 
        : null;
    final borrowPeriodEnd = data != null && data.containsKey('borrowPeriodEnd') && item['borrowPeriodEnd'] != null 
        ? (item['borrowPeriodEnd'] as Timestamp).toDate() 
        : null;
    final dailyRentalPrice = item['dailyRentalPrice'] != null
        ? item['dailyRentalPrice'].toString()
        : 'N/A';
    final orderId = data != null && data.containsKey('orderId') ? item['orderId'] : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Text('Item Information'),
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
              'Daily Rental Price: ${dailyRentalPrice} zł',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Status: ${isBorrowed ? 'Borrowed' : 'Available'}',
              style: TextStyle(fontSize: 16),
            ),
            if (isBorrowed) ...[
              SizedBox(height: 10),
              Text(
                'Borrowed by: $borrowedByName $borrowedBySurname',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Borrow Period: ${borrowPeriodStart != null ? DateFormat('yyyy-MM-dd').format(borrowPeriodStart) : ''} to ${borrowPeriodEnd != null ? DateFormat('yyyy-MM-dd').format(borrowPeriodEnd) : ''}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'Order ID: $orderId',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
            Spacer(),
            if (isEmployee)
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    bool? confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Confirm Deletion'),
                        content: Text('Are you sure you want to delete this item?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmDelete == true) {
                      await _deleteItem(context);
                    }
                  },
                  child: Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
