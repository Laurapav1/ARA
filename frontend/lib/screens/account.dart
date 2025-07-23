import 'package:flutter/material.dart';
import '../widgets/offline_banner.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account')),
      body: Column(
        children: [
          OfflineBanner(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text('Request an Account',
                      style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 16),
                  TextField(decoration: InputDecoration(labelText: 'Name')),
                  TextField(
                      decoration: InputDecoration(
                          labelText: 'End of stay (YYYY-MM-DD)')),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Request submitted!')),
                      );
                    },
                    child: Text('Submit Request'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
