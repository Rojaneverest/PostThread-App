import 'package:flutter/material.dart';
import 'package:yipl_android_list_me/model/post.dart';
import 'package:yipl_android_list_me/view/home/post_details.dart';

class PostCard extends StatefulWidget {
  final String username;
  final Post post;

  const PostCard({Key? key, required this.username, required this.post})
      : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    radius: 14,
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    widget.username,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                ],
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  widget.post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  widget.post.body,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  isLiked = !isLiked;
                });
              },
              icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                  size: 24,
                  color: isLiked ? Colors.pink : Colors.black),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PostDetailsPage(
                      username: widget.username,
                      title: widget.post.title,
                      body: widget.post.body,
                      postId: widget.post.id,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.mode_comment_outlined,
                size: 21,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
