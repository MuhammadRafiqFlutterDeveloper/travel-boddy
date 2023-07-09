import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_buddy/constant/fonts.dart';

import 'details.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  List<DocumentSnapshot> userList = [];
  late Stream<QuerySnapshot> userStream;

  @override
  void initState() {
    super.initState();
    userStream = usersCollection.snapshots();
  }

  void searchUsers(String query) async {
    userList.clear();
    final snapshot = await usersCollection.get();
    setState(() {
      userList = snapshot.docs
          .where((doc) =>
              (doc.data() as Map<String, dynamic>)['name'] != null &&
              (doc.data() as Map<String, dynamic>)['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users', style: appbar,),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context, delegate: UserSearchDelegate(searchUsers));
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red,),));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (userList.isEmpty) {
            userList = snapshot.data!.docs;
          }

          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final user = userList[index];
              final uid = user['uid'];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user['profile']),
                ),
                title: Text(user["name"], style: postuser,),
                subtitle: Text(user["email"], style: title,),
                trailing: Icon(Icons.forward, color: Colors.green,),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserPostsScreen(
                        userId: uid,
                        name: user["name"],
                        email: user["email"],
                        image: user['profile'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class UserSearchDelegate extends SearchDelegate<String> {
  final Function(String) searchCallback;

  UserSearchDelegate(this.searchCallback);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(); // You can modify this to show the search results if needed.
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // You can modify this to show search suggestions if needed.
  }

  @override
  void showResults(BuildContext context) {
    searchCallback(query);
  }
}
