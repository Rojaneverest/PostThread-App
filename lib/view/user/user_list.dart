import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yipl_android_list_me/model/user.dart';
import 'dart:convert';

import 'package:yipl_android_list_me/view/user/user_details.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers().then((fetchedUsers) {
      setState(() {
        users = fetchedUsers;
      });
    });
  }

  Future<List<User>> fetchUsers() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<User> fetchedUsers =
          data.map((json) => User.fromJson(json)).toList();
      return fetchedUsers;
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Users'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 1,
            child: ListTile(
              trailing: const Icon(Icons.arrow_forward),
              title: Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                user.username,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserDetailsPage(
                      user: user,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
