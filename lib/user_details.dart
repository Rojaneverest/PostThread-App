import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yipl_android_list_me/main.dart';
import 'package:yipl_android_list_me/user_post.dart';

class Todo {
  final int id;
  final int userId;
  final String title;
  final bool completed;

  Todo({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      completed: json['completed'],
    );
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}

class Photo {
  final int albumId;
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  Photo({
    required this.albumId,
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      albumId: json['albumId'],
      id: json['id'],
      title: json['title'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}

class UserDetailsPage extends StatefulWidget {
  final User user;

  const UserDetailsPage({super.key, required this.user});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  List<Todo> todos = [];
  List<Album> albums = [];
  List<Photo> photos = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchTodos();
    fetchAlbums();
  }

  void fetchTodos() async {
    final response = await http.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/users/${widget.user.id}/todos'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      todos = data.map((item) => Todo.fromJson(item)).toList();
      setState(() {});
    }
  }

  void fetchAlbums() async {
    final response = await http.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/users/${widget.user.id}/albums'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      albums = data.map((item) => Album.fromJson(item)).toList();
      setState(() {});
    }
  }

  void fetchPhotos(int albumId) async {
    final response = await http.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/albums/$albumId/photos'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      photos = data.map((item) => Photo.fromJson(item)).toList();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(widget.user.name),
      ),
      body: _currentIndex == 0
          ? DefaultTabController(
              length: 2,
              child: Column(children: [
                Container(
                  color: Colors.grey[400],
                  child: const TabBar(
                    labelColor: Colors.black,
                    indicatorColor: Colors.black,
                    tabs: [
                      Tab(text: 'Details'), // First tab for user details
                      Tab(text: 'Posts'), // Second tab for user posts
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // First Tab (User Details)
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _buildDetailRow("Name", widget.user.name),
                            _buildDetailRow("Username", widget.user.username),
                            _buildDetailRow("Email", widget.user.email),
                            const Divider(
                              thickness: 2,
                            ),
                            _buildDetailRow("Address: ", ""),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _buildDetailRow(
                                    "Street", widget.user.address.street),
                                _buildDetailRow(
                                    "Suite", widget.user.address.suite),
                                _buildDetailRow(
                                    "City", widget.user.address.city),
                                _buildDetailRow(
                                    "Zipcode", widget.user.address.zipcode),
                              ],
                            ),
                            _buildDetailRow("Phone", widget.user.phone),
                            _buildDetailRow("Website", widget.user.website),
                            const Divider(
                              thickness: 2,
                            ),
                            _buildDetailRow("Company:", ""),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _buildDetailRow(
                                    "Name", widget.user.company.name),
                                _buildDetailRow("Catch Phrase",
                                    widget.user.company.catchPhrase),
                                _buildDetailRow("BS", widget.user.company.bs),
                              ],
                            ),
                          ],
                        ),
                      ),
                      UserPost(user: widget.user),
                    ],
                  ),
                  // Second Tab (User Posts)
                ),
              ]),
            )
          : _buildTabContent(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Todos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album),
            label: 'Albums',
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(int index) {
    if (index == 1) {
      return ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(todos[index].title),
            subtitle: Text(todos[index].completed ? 'Completed' : 'Pending'),
          );
        },
      );
    } else if (index == 2) {
      return _buildAlbumsList(); // Display Albums
    } else {
      return Container();
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildAlbumsList() {
    return ListView.builder(
      itemCount: albums.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(albums[index].title),
          trailing: const Icon(Icons.arrow_forward), // Trailing arrow icon
          onTap: () {
            // Fetch and display photos for the selected album
            fetchPhotos(albums[index].id);
          },
        );
      },
    );
  }
}
