import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestFirebaseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Firebase')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await FirebaseFirestore.instance.collection('test').add({'test': 'data'});
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Firebase is configured correctly')));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          },
          child: Text('Test Firebase Connection'),
        ),
      ),
    );
  }
}
