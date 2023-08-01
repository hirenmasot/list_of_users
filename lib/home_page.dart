import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<dynamic> users = [];
  int currentPage = 1;
  int totalPages = 5;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchUsersData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (currentPage < totalPages) {
        currentPage++;
        fetchUsersData();
      }
    }
  }

  Future<void> fetchUsersData() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('http://api.anviya.in/getUsers.php?page=$currentPage'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          totalPages = data['data']['totalPage'];
          users.addAll(data['data']['users']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: users.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == users.length) {
            if (currentPage < totalPages) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text('End of the List'));
            }
          } else {
            return ListTile(
              title: Text(users[index]['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(users[index]['email']),
                  Text(users[index]['phone']),
                ],
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(users[index]['profileImage']),
              ),
            );
          }
        },
      ),
    );
  }
}
