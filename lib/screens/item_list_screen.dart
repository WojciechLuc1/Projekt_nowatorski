import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('items').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs;

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return ListTile(
              title: Text(item['name']),
              subtitle: Text(item['description']),
              trailing: item['available']
                  ? ElevatedButton(
                      onPressed: () {
                        // Logika wypożyczania
                      },
                      child: Text('Wypożycz'),
                    )
                  : Text('Niedostępny'),
            );
          },
        );
      },
    );
  }
}
