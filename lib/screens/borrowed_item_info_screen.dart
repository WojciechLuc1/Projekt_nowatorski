import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BorrowedItemInfoScreen extends StatefulWidget {
  final QueryDocumentSnapshot item;

  BorrowedItemInfoScreen({required this.item});

  @override
  _BorrowedItemInfoScreenState createState() => _BorrowedItemInfoScreenState();
}

class _BorrowedItemInfoScreenState extends State<BorrowedItemInfoScreen> {
  late String status;

  @override
  void initState() {
    super.initState();
    status = (widget.item.data() as Map<String, dynamic>?)?['status'] ?? 'N/A';
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('orderId', isEqualTo: orderId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot document = querySnapshot.docs.first;
      await FirebaseFirestore.instance.collection('items').doc(document.id).update({
        'status': newStatus,
      });
      if (mounted) {
        setState(() {
          status = newStatus;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.item.data() as Map<String, dynamic>?;
    final borrowedByName = data != null && data.containsKey('borrowedByName') ? widget.item['borrowedByName'] : 'None';
    final borrowedBySurname = data != null && data.containsKey('borrowedBySurname') ? widget.item['borrowedBySurname'] : 'None';
    final borrowPeriodStart = data != null && data.containsKey('borrowPeriodStart') && widget.item['borrowPeriodStart'] != null 
        ? (widget.item['borrowPeriodStart'] as Timestamp).toDate() 
        : null;
    final borrowPeriodEnd = data != null && data.containsKey('borrowPeriodEnd') && widget.item['borrowPeriodEnd'] != null 
        ? (widget.item['borrowPeriodEnd'] as Timestamp).toDate() 
        : null;
    final dailyRentalPrice = widget.item['dailyRentalPrice'] != null
        ? widget.item['dailyRentalPrice'].toString()
        : 'N/A';
    final orderId = data != null && data.containsKey('orderId') ? widget.item['orderId'] : 'N/A';

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
              'Name: ${widget.item['name']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Description: ${widget.item['description']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Daily Rental Price: ${dailyRentalPrice} zł',
              style: TextStyle(fontSize: 16),
            ),
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
            SizedBox(height: 10),
            Text(
              'Status: $status',
              style: TextStyle(fontSize: 16),
            ),
            if (status == 'oczekuje na zatwierdzenie odbioru') ...[
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _updateOrderStatus(orderId, 'wydane');
                  Navigator.of(context).pop(); // Zamknij ekran po potwierdzeniu
                },
                child: Text('Potwierdź odbiór zamówienia'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
