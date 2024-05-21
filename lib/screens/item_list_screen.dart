import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'item_info_screen.dart'; // Dodaj ten import
import 'borrow_item_screen.dart';

class ItemListScreen extends StatelessWidget {
  final bool isEmployee;

  ItemListScreen({this.isEmployee = false});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Items List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs.where((item) {
            // Filtrowanie przedmiotów wypożyczonych przez zalogowanego użytkownika
            if (!isEmployee && item['borrowedBy'] == user?.uid) {
              return false;
            }
            return true;
          }).toList();

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isBorrowed = item['isBorrowed'] ?? false;
              final borrowedBy = item['borrowedBy'];
              final data = item.data() as Map<String, dynamic>?;
              final borrowPeriodEnd = data != null && data.containsKey('borrowPeriodEnd') && item['borrowPeriodEnd'] != null 
                  ? (item['borrowPeriodEnd'] as Timestamp).toDate()
                  : null;
              final availableFrom = borrowPeriodEnd != null
                  ? DateFormat('yyyy-MM-dd').format(borrowPeriodEnd.add(Duration(days: 1)))
                  : 'Unavailable';

              return ListTile(
                title: Text(item['name']),
                subtitle: Text(item['description']),
                trailing: isEmployee
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemInfoScreen(item: item, isEmployee: true),
                            ),
                          );
                        },
                        child: Text('Info'),
                      )
                    : isBorrowed
                        ? (borrowedBy == user?.uid
                            ? Container() // Nie wyświetlaj nic, jeśli przedmiot jest wypożyczony przez zalogowanego użytkownika
                            : Column(
                                children: [
                                  Text('Niedostępny'),
                                  Text('Dostępny od: $availableFrom'),
                                ],
                              ))
                        : ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BorrowItemScreen(item: item),
                                ),
                              );
                            },
                            child: Text('Borrow'),
                          ),
              );
            },
          );
        },
      ),
    );
  }
}
