import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:convert';

import 'package:yipl_android_list_me/user_list.dart';

void main() => runApp(const MaterialApp(
      home: UserPostsPage(),
    ));

class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final List<Post> posts;
  final Address address;
  final Company company;

  User(
      {required this.id,
      required this.name,
      required this.username,
      required this.email,
      required this.phone,
      required this.website,
      required this.posts,
      required this.address,
      required this.company});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      address: Address.fromJson(json['address']),
      company: Company.fromJson(json['company']),
      posts: [],
    );
  }
}

class Company {
  final String name;
  final String catchPhrase;
  final String bs;

  Company({
    required this.name,
    required this.catchPhrase,
    required this.bs,
  });
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'],
      catchPhrase: json['catchPhrase'],
      bs: json['bs'],
    );
  }
}

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
}

class Address {
  final String street;
  final String suite;
  final String city;
  final String zipcode;

  Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
  });
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      suite: json['suite'],
      city: json['city'],
      zipcode: json['zipcode'],
    );
  }
}

class Comment {
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });
}

class UserPostsPage extends StatefulWidget {
  const UserPostsPage({super.key});

  @override
  State<UserPostsPage> createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();

    fetchUserData().then((userData) {
      setState(() {
        users = userData;
      });
    });
  }

  Future<List<User>> fetchUserData() async {
    final userResponse =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
    final postResponse =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

    if (userResponse.statusCode == 200 && postResponse.statusCode == 200) {
      final usersData = json.decode(userResponse.body);
      final postsData = json.decode(postResponse.body);

      List<User> userList = [];

      for (var userData in usersData) {
        final userId = userData['id'];
        final userPosts =
            postsData.where((post) => post['userId'] == userId).toList();
        List<Post> userPostList = [];

        for (var post in userPosts) {
          userPostList.add(Post(
            userId: post['userId'],
            id: post['id'],
            title: post['title'],
            body: post['body'],
          ));
        }

        userList.add(User(
          id: userData['id'],
          name: userData['name'],
          username: userData['username'],
          email: userData['email'],
          phone: userData['phone'],
          website: userData['website'],
          address: Address(
            // Create an Address object
            street: userData['address']['street'],
            suite: userData['address']['suite'],
            city: userData['address']['city'],
            zipcode: userData['address']['zipcode'],
          ),
          company: Company(
            // Create a Company object
            name: userData['company']['name'],
            catchPhrase: userData['company']['catchPhrase'],
            bs: userData['company']['bs'],
          ),
          posts: userPostList,
        ));
      }

      return userList;
    } else {
      throw Exception('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('User Posts'),
            backgroundColor: Colors.grey[800],
            actions: [
              IconButton(
                icon: const Icon(Icons.person), // Users icon
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const UserListPage(),
                    ),
                  );
                },
              ),
            ]),
        body: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final random = Random();
            final randomIndex = random.nextInt(users.length);
            final user = users[randomIndex];
            return UserPostCard(user: user);
          },
        ));
  }
}

class UserPostCard extends StatelessWidget {
  final User user;

  const UserPostCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: user.posts.length,
            itemBuilder: (context, index) {
              final post = user.posts[index];
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PostDetailsPage(
                              title: post.title,
                              body: post.body,
                              postId: post.id),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey[700],
                            foregroundColor: Colors.white,
                            child: const Icon(Icons.person),
                          ),
                          title: Text(user.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                              textAlign: TextAlign.start),
                        ),
                        ListTile(
                          title: Text(post.title,
                              maxLines: 8,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                        ),
                        ListTile(
                          title: Text(post.body,
                              maxLines: 8, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 3,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class PostDetailsPage extends StatefulWidget {
  final String title;
  final String body;
  final int postId;

  const PostDetailsPage(
      {super.key,
      required this.title,
      required this.body,
      required this.postId});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState(postId: postId);
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final TextEditingController commentController = TextEditingController();
  final int postId;

  _PostDetailsPageState({required this.postId});

  Future<List<Map<String, dynamic>>> fetchComments(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final localComments = prefs.getStringList('comments$postId') ?? [];

    final response = await http.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/posts/$postId/comments'));

    if (response.statusCode == 200) {
      final List<dynamic> remoteCommentsData = json.decode(response.body);
      final remoteComments = remoteCommentsData
          .map((commentData) => {
                'name': commentData['name'],
                'email': commentData['email'],
                'body': commentData['body']
              })
          .toList();

      return [
        ...localComments.map((commentText) => {
              'name': 'Local User', // Replace with your local user information
              'email': 'local@example.com',
              'body': commentText
            }),
        ...remoteComments
      ];
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> addComment(String commentText) async {
    if (commentText.isNotEmpty) {
      // Save the comment locally using shared preferences
      final prefs = await SharedPreferences.getInstance();
      List<String> comments = prefs.getStringList('comments$postId') ?? [];
      comments.add(commentText);
      prefs.setStringList('comments$postId', comments);

      setState(() {
        commentController.clear();
      });

      // Now, the comment is stored locally.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: const Text("Posts"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.body,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const Divider(
            thickness: 8,
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchComments(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final comments = snapshot.data;

                  if (comments != null && comments.isNotEmpty) {
                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final commentData = comments[index];

                        return Column(
                          children: [
                            Card(
                              elevation: 3,
                              margin: const EdgeInsetsDirectional.all(8),
                              child: ListTile(
                                title: Text(
                                  '${commentData["name"]} - ${commentData["email"]}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                subtitle: Text(
                                  commentData["body"],
                                ),
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    );
                  } else {
                    return const Text('No comments yet.');
                  }
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration:
                        const InputDecoration(labelText: 'Add a comment'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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
