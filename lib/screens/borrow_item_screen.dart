import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class BorrowItemScreen extends StatefulWidget {
  final DocumentSnapshot item;

  BorrowItemScreen({required this.item});

  @override
  _BorrowItemScreenState createState() => _BorrowItemScreenState();
}

class _BorrowItemScreenState extends State<BorrowItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  DateTime? _borrowPeriodStart;
  DateTime? _borrowPeriodEnd;
  double? _totalPrice;
  String _pickupLocation = 'Punkt odbioru - Wrocław';

  Future<void> _pickStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _borrowPeriodStart ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _borrowPeriodStart)
      setState(() {
        _borrowPeriodStart = picked;
        _calculateTotalPrice();
      });
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _borrowPeriodEnd ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _borrowPeriodEnd)
      setState(() {
        _borrowPeriodEnd = picked;
        _calculateTotalPrice();
      });
  }

  void _calculateTotalPrice() {
    if (_borrowPeriodStart != null && _borrowPeriodEnd != null) {
      final int days = _borrowPeriodEnd!.difference(_borrowPeriodStart!).inDays + 1;
      final double dailyPrice = widget.item['dailyRentalPrice'];
      setState(() {
        _totalPrice = days * dailyPrice;
      });
    }
  }

  String _generateOrderId() {
    final Random random = Random();
    const int length = 6;
    final String orderId = String.fromCharCodes(
      List.generate(length, (index) => random.nextInt(10) + 48), // generates digits 0-9
    );
    return orderId;
  }

  Future<void> _borrowItem() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _borrowPeriodStart != null && _borrowPeriodEnd != null) {
      final String orderId = _generateOrderId();
      await FirebaseFirestore.instance.collection('items').doc(widget.item.id).update({
        'isBorrowed': true,
        'borrowedBy': user.uid,
        'borrowedByName': _nameController.text,
        'borrowedBySurname': _surnameController.text,
        'idNumber': _idNumberController.text,
        'pickupLocation': _pickupLocation,
        'borrowPeriodStart': _borrowPeriodStart,
        'borrowPeriodEnd': _borrowPeriodEnd,
        'orderId': orderId,
        'status': 'rezerwacja', // Dodanie statusu "rezerwacja"
      });
      _showSuccessMessage(widget.item['name'], _borrowPeriodStart!, _borrowPeriodEnd!, orderId);
    }
  }

  void _showSuccessMessage(String itemName, DateTime startDate, DateTime endDate, String orderId) {
    final String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gratulacje!'),
          content: Text(
              'Pomyślnie zarezerwowałeś przedmiot "$itemName" na okres od $formattedStartDate do $formattedEndDate. '
              'Twój sprzęt będzie do odebrania w wybranym przez Ciebie punkcie odbioru w dniu $formattedStartDate w godzinach 8:00 - 20:30, '
              'po podaniu identyfikatora zamówienia $orderId. Pamiętaj zabrać ze sobą dowód osobisty w celu weryfikacji Twojej tożsamości.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Borrow Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _surnameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _idNumberController,
                decoration: InputDecoration(labelText: 'ID Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your ID number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _pickupLocation,
                decoration: InputDecoration(labelText: 'Pickup Location'),
                items: ['Punkt odbioru - Wrocław']
                    .map((location) => DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _pickupLocation = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _pickStartDate(context),
                child: Text(_borrowPeriodStart == null
                    ? 'Select Start Date'
                    : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_borrowPeriodStart!)}'),
              ),
              ElevatedButton(
                onPressed: () => _pickEndDate(context),
                child: Text(_borrowPeriodEnd == null
                    ? 'Select End Date'
                    : 'End Date: ${DateFormat('yyyy-MM-dd').format(_borrowPeriodEnd!)}'),
              ),
              SizedBox(height: 20),
              if (_totalPrice != null)
                Text(
                  'Total Price: ${_totalPrice!.toStringAsFixed(2)} zł',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _borrowItem();
                  }
                },
                child: Text('Borrow Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
