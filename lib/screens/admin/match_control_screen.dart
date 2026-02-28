import 'package:flutter/material.dart';

class MatchControlScreen extends StatelessWidget {
  const MatchControlScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Match Control')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text('Match #${index + 1}'),
              subtitle: const Text('Team A vs Team B'),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text('Open'),
              ),
            ),
          );
        },
      ),
    );
  }
}
