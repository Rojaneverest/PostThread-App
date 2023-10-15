import 'package:yipl_android_list_me/model/address.dart';
import 'package:yipl_android_list_me/model/company.dart';
import 'package:yipl_android_list_me/model/post.dart';

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
