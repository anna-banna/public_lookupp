import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:public_lookupp/pages/login.dart';

class AccountPage extends StatelessWidget {
  AccountPage({super.key});

  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              const Text('My Account', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          automaticallyImplyLeading: false),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            _firestore.collection('users').doc(currentUser?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  radius: 50,
                  child: const Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 20),
                InfoCard(
                  icon: Icons.person,
                  title: 'Name',
                  value: data?['name'] ?? 'Not set',
                ),
                InfoCard(
                  icon: Icons.email,
                  title: 'Email',
                  value: data?['email'] ?? 'Not set',
                ),
                InfoCard(
                  icon: Icons.work,
                  title: 'Role',
                  value: data?['role'] ?? 'Not set',
                ),
                InfoCard(
                  icon: Icons.star,
                  title: 'Total Points',
                  value: (data?['totalPoints'] ?? 0).toString(),
                ),
                GestureDetector(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Card(
                    color: Colors.red[50],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: const ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    String displayValue = value;
    if (title == 'Total Points') {
      displayValue = value.replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(displayValue),
      ),
    );
  }
}
