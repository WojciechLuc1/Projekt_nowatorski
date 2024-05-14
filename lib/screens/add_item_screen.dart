import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddItemScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dodaj Sprzęt')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nazwa'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Opis'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('items').add({
                  'name': _nameController.text,
                  'description': _descriptionController.text,
                  'available': true,
                });
                Navigator.pop(context);
              },
              child: Text('Dodaj'),
            ),
          ],
        ),
      ),
    );
  }
}
