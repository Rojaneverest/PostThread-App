// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PostDetailsPage extends StatefulWidget {
  final String title;
  final String body;
  final int postId;
  final String username;

  const PostDetailsPage(
      {Key? key,
      required this.title,
      required this.body,
      required this.postId,
      required this.username})
      : super(key: key);

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final TextEditingController commentController = TextEditingController();
  Future<List<Map<String, dynamic>>?> fetchComments(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final localComments = prefs.getStringList('comments$postId') ?? [];

    try {
      final response = await http.get(Uri.parse(
          'https://jsonplaceholder.typicode.com/posts/$postId/comments'));

      if (response.statusCode == 200) {
        final List<dynamic> remoteCommentsData = json.decode(response.body);
        final remoteComments = remoteCommentsData
            .map((commentData) => {
                  'name': commentData['name'],
                  'email': commentData['email'],
                  'body': commentData['body'],
                })
            .toList();

        return [
          ...localComments.map((commentText) => {
                'name': 'Local User',
                'email': 'local@example.com',
                'body': commentText,
              }),
          ...remoteComments,
        ];
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> addComment(String commentText) async {
    if (commentText.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      List<String> comments =
          prefs.getStringList('comments${widget.postId}') ?? [];
      comments.add(commentText);
      prefs.setStringList('comments${widget.postId}', comments);

      final postCommentUrl =
          'https://jsonplaceholder.typicode.com/posts/${widget.postId}/comments';

      final response = await http.post(
        Uri.parse(postCommentUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'name': 'User Name',
          'email': 'user@example.com',
          'body': commentText,
        }),
      );

      if (response.statusCode == 201) {
        print('Comment posted successfully');
      } else {
        print('Failed to post comment: ${response.statusCode}');
      }

      setState(() {
        commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Comments"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16.0),
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                radius: 16,
                child: Icon(Icons.person),
              ),
              title: Text(
                widget.username,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.body,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(
            thickness: 2,
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>?>(
              future: fetchComments(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError || snapshot.data == null) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Error: Failed to load comments.'),
                  );
                } else {
                  final comments = snapshot.data;

                  if (comments != null && comments.isNotEmpty) {
                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final commentData = comments[index];

                        return Card(
                          elevation: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (index == 0)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    "Comments",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  radius: 16,
                                  child: Icon(Icons.person),
                                ),
                                title: Text(
                                  commentData["name"] ?? "Unknown User",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle:
                                    Text(commentData["email"] ?? "No Email"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  commentData["body"] ?? "No Comment",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              const Divider(
                                thickness: 3,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('No comments yet.'),
                    );
                  }
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: commentController,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: 'Add a comment',
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                )),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.black,
                  onPressed: () {
                    addComment(commentController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
