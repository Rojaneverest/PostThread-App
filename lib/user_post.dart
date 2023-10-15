import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yipl_android_list_me/main.dart';
import 'package:http/http.dart' as http;

class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

class UserPost extends StatefulWidget {
  final User user;

  const UserPost({super.key, required this.user});

  @override
  State<UserPost> createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> {
  List<Post> userPosts = [];
  @override
  void initState() {
    super.initState();

    fetchUserPosts().then((posts) {
      setState(() {
        userPosts = posts;
      });
    });
  }

  Future<List<Post>> fetchUserPosts() async {
    final postResponse = await http.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/users/${widget.user.id}/posts'));

    if (postResponse.statusCode == 200) {
      final List<dynamic> data = json.decode(postResponse.body);
      final List<Post> posts = data.map((json) => Post.fromJson(json)).toList();
      return posts;
    } else {
      throw Exception('Failed to load user posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: userPosts.length,
        itemBuilder: (context, index) {
          final post = userPosts[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListTile(
                  title: Text(post.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(post.body),
                ),
                const Divider(), // Add a divider between posts
              ],
            ),
          );
        },
      ),
    );
  }
}
