import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
  DateTime? _borrowPeriodStart;
  DateTime? _borrowPeriodEnd;

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
      });
  }

  Future<void> _borrowItem() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _borrowPeriodStart != null && _borrowPeriodEnd != null) {
      await FirebaseFirestore.instance.collection('items').doc(widget.item.id).update({
        'isBorrowed': true,
        'borrowedBy': user.uid,
        'borrowedByName': _nameController.text,
        'borrowedBySurname': _surnameController.text,
        'pickupOption': 'Personal pickup',
        'borrowPeriodStart': _borrowPeriodStart,
        'borrowPeriodEnd': _borrowPeriodEnd,
      });
      Navigator.pop(context);
    }
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
