import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:yipl_android_list_me/model/post.dart';
import 'package:http/http.dart' as http;
import 'package:yipl_android_list_me/view/home/post_card.dart';
import 'package:yipl_android_list_me/view/user/user_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Post> posts = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    fetchUserPosts().then((postsData) {
      setState(() {
        posts = postsData;
        currentIndex = 0;
      });
    });
  }

  Future<List<Post>> fetchUserPosts() async {
    try {
      final userResponse = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
      final postResponse = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

      if (userResponse.statusCode == 200 && postResponse.statusCode == 200) {
        final usersData = json.decode(userResponse.body);
        final postsData = json.decode(postResponse.body);

        List<Post> postList = [];

        for (var post in postsData) {
          final userId = post['userId'];
          final userData = usersData.firstWhere((user) => user['id'] == userId);

          final postItem = Post.fromJson(post);
          postItem.username = userData['username'];
          postList.add(postItem);
        }

        postList.shuffle();
        return postList;
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            SizedBox(
              width: 40,
              height: 35,
              child: Image.asset(
                "assets/images/app_icon.png",
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            const Text('PostThreads'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UserListPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(
            thickness: 0.2,
            color: Colors.black,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final userPost = posts[index];

                return Column(
                  children: [
                    PostCard(username: userPost.username ?? "", post: userPost),
                    const Divider(
                      thickness: 3,
                      height: 2,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
