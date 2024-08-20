import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yipl_android_list_me/model/album.dart';
import 'package:yipl_android_list_me/model/photos.dart';
import 'package:yipl_android_list_me/model/todo.dart';
import 'package:yipl_android_list_me/model/user.dart';
import 'package:yipl_android_list_me/view/user/photos_page.dart';
import 'package:yipl_android_list_me/view/user/user_post.dart';

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
      setState(() {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PhotosPage(photos: photos),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.user.name),
      ),
      body: DefaultTabController(
        length: 4,
        initialIndex: 0,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              tabs: [
                Tab(
                  text: 'Details',
                  icon: Icon(Icons.person),
                ),
                Tab(
                  text: 'Posts',
                  icon: Icon(Icons.chrome_reader_mode),
                ),
                Tab(
                  text: 'Todos',
                  icon: Icon(Icons.checklist),
                ),
                Tab(
                  text: 'Albums',
                  icon: Icon(Icons.photo_album),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
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
                            _buildDetailRow("Suite", widget.user.address.suite),
                            _buildDetailRow("City", widget.user.address.city),
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
                            _buildDetailRow("Name", widget.user.company.name),
                            _buildDetailRow("Catch Phrase",
                                widget.user.company.catchPhrase),
                            _buildDetailRow("BS", widget.user.company.bs),
                          ],
                        ),
                      ],
                    ),
                  ),
                  UserPost(user: widget.user),
                  _buildTabContent(),
                  _buildAlbumsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    {
      return ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(todos[index].title),
            subtitle: Text(todos[index].completed ? 'Completed' : 'Pending'),
          );
        },
      );
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
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            fetchPhotos(albums[index].id);
          },
        );
      },
    );
  }
}
