import 'package:flutter/material.dart';

class AskQuestionScreen extends StatelessWidget {
  final TextEditingController _questionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zadaj pytanie',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: 'Twoje pytanie',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Logika wysyłania pytania
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pytanie zostało wysłane')),
                );
                _questionController.clear();
              },
              child: Text('Wyślij'),
            ),
          ],
        ),
      ),
    );
  }
}
