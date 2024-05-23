import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final TextEditingController _orderIdController = TextEditingController();
  DocumentSnapshot? _orderDetails;

  Future<void> _fetchOrderDetails(String orderId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('orderId', isEqualTo: orderId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _orderDetails = querySnapshot.docs.first;
      });
    } else {
      setState(() {
        _orderDetails = null;
      });
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('orderId', isEqualTo: orderId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot document = querySnapshot.docs.first;
      await FirebaseFirestore.instance.collection('items').doc(document.id).update({
        'status': status,
      });
      setState(() {
        _orderDetails = document;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zamówienia'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _orderIdController,
              decoration: InputDecoration(labelText: 'Podaj identyfikator zamówienia'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _fetchOrderDetails(_orderIdController.text);
              },
              child: Text('Szukaj'),
            ),
            SizedBox(height: 20),
            if (_orderDetails != null)
              OrderDetailsWidget(
                orderDetails: _orderDetails!,
                onUpdateStatus: (status) {
                  _updateOrderStatus(_orderIdController.text, status);
                },
              )
            else
              Text('Brak zamówienia o podanym identyfikatorze'),
          ],
        ),
      ),
    );
  }
}

class OrderDetailsWidget extends StatefulWidget {
  final DocumentSnapshot orderDetails;
  final Function(String) onUpdateStatus;

  OrderDetailsWidget({required this.orderDetails, required this.onUpdateStatus});

  @override
  _OrderDetailsWidgetState createState() => _OrderDetailsWidgetState();
}

class _OrderDetailsWidgetState extends State<OrderDetailsWidget> {
  late String status;

  @override
  void initState() {
    super.initState();
    status = (widget.orderDetails.data() as Map<String, dynamic>?)?['status'] ?? 'N/A';
  }

  void _updateStatus(String newStatus) {
    if (mounted) {
      setState(() {
        status = newStatus;
      });
    }
    widget.onUpdateStatus(newStatus);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.orderDetails.data() as Map<String, dynamic>?;
    final itemName = data != null && data.containsKey('name') ? widget.orderDetails['name'] : 'N/A';
    final borrowedByName = data != null && data.containsKey('borrowedByName') ? widget.orderDetails['borrowedByName'] : 'None';
    final borrowedBySurname = data != null && data.containsKey('borrowedBySurname') ? widget.orderDetails['borrowedBySurname'] : 'None';
    final borrowPeriodStart = data != null && data.containsKey('borrowPeriodStart') && widget.orderDetails['borrowPeriodStart'] != null 
        ? (widget.orderDetails['borrowPeriodStart'] as Timestamp).toDate() 
        : null;
    final borrowPeriodEnd = data != null && data.containsKey('borrowPeriodEnd') && widget.orderDetails['borrowPeriodEnd'] != null 
        ? (widget.orderDetails['borrowPeriodEnd'] as Timestamp).toDate() 
        : null;
    final orderId = data != null && data.containsKey('orderId') ? widget.orderDetails['orderId'] : 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nazwa przedmiotu: $itemName', style: TextStyle(fontSize: 16)),
        Text('Imię: $borrowedByName', style: TextStyle(fontSize: 16)),
        Text('Nazwisko: $borrowedBySurname', style: TextStyle(fontSize: 16)),
        Text(
          'Okres wypożyczenia: ${borrowPeriodStart != null ? DateFormat('yyyy-MM-dd').format(borrowPeriodStart) : ''} - ${borrowPeriodEnd != null ? DateFormat('yyyy-MM-dd').format(borrowPeriodEnd) : ''}',
          style: TextStyle(fontSize: 16),
        ),
        Text('Identyfikator zamówienia: $orderId', style: TextStyle(fontSize: 16)),
        Text('Status: $status', style: TextStyle(fontSize: 16)),
        SizedBox(height: 20),
        if (status != 'oczekuje na zatwierdzenie odbioru')
          ElevatedButton(
            onPressed: () {
              _updateStatus('oczekuje na zatwierdzenie odbioru');
            },
            child: Text('Wydaj zamówienie'),
          ),
      ],
    );
  }
}
