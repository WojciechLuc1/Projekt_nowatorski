import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wypozyczalnia_sprzetu/screens/my_borrowed_items_screen.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'item_list_screen.dart';
import 'contact_screen.dart';
import 'ask_question_screen.dart';

class CustomerWelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Welcome, Customer'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Kontakt'),
              Tab(text: 'Zadaj pytanie'),
              Tab(text: 'Sprzęty do wypożyczenia'),
              Tab(text: 'Moje wypożyczone'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                await authService.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            ContactScreen(),
            AskQuestionScreen(),
            ItemListScreen(isEmployee: false),
            MyBorrowedItemsScreen(),
          ],
        ),
      ),
    );
  }
}
