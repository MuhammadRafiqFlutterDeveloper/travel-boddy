import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_buddy/constant/fonts.dart';

import 'chat.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final User currentUser = FirebaseAuth.instance.currentUser!;
  late Stream<QuerySnapshot> userStream;
  List<DocumentSnapshot> userList = [];

  @override
  void initState() {
    super.initState();
    userStream = FirebaseFirestore.instance.collection('users').snapshots();
  }

  void searchUser(String query, AsyncSnapshot<QuerySnapshot> snapshot) {
    setState(() {
      userList = snapshot.data?.docs
              .where((doc) =>
                  doc.id != currentUser.uid &&
                  (doc.data() as Map<String, dynamic>)['name'] != null &&
                  (doc.data() as Map<String, dynamic>)['name']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .toList() ??
          [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User List',
          style: appbar,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.black,
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: UserSearchDelegate(searchUser),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            userList = snapshot.data!.docs
                .where((doc) => doc.id != currentUser.uid)
                .toList();
            if (userList.isNotEmpty) {
              return ListView.builder(
                itemCount: userList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot userSnapshot = userList[index];
                  Map<String, dynamic> userData =
                      userSnapshot.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(userData['profile']),
                    ),
                    title: Text(
                      userData['name'],
                      style: postuser,
                    ),
                    subtitle: Text(
                      userData['email'],
                      style: title,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.green,),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ChatPage(
                                  name: userData['name'],
                                  image: userData['profile'],
                                  email: userData['email'],
                                  uid: userData['uid'],
                                )),
                      );
                    },
                  );
                },
              );
            } else {
              return Center(
                child: Text(
                  'User doesn\'t exist',
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ),
              );
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class UserSearchDelegate extends SearchDelegate<String> {
  final Function(String, AsyncSnapshot<QuerySnapshot>) searchCallback;

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
    final snapshot = ModalRoute.of(context)!.settings.arguments
        as AsyncSnapshot<QuerySnapshot>;
    searchCallback(query, snapshot);
  }
}

// class UserListScreen extends StatefulWidget {
//   @override
//   _UserListScreenState createState() => _UserListScreenState();
// }
//
// class _UserListScreenState extends State<UserListScreen> {
//   final User currentUser = FirebaseAuth.instance.currentUser!;
//   late Stream<QuerySnapshot> userStream;
//   List<DocumentSnapshot> userList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     userStream = FirebaseFirestore.instance.collection('users').snapshots();
//   }
//
//   void searchUser(String query, AsyncSnapshot<QuerySnapshot> snapshot) {
//     setState(() {
//       userList = snapshot.data!.docs
//           .where((doc) =>
//       doc.id != currentUser.uid &&
//           doc.data()['name'].toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('User List'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search),
//             onPressed: () {
//               showSearch(
//                 context: context,
//                 delegate: UserSearchDelegate(searchUser),
//               );
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: userStream,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             userList = snapshot.data!.docs.where((doc) => doc.id != currentUser.uid).toList();
//             if (userList.isNotEmpty) {
//               return ListView.builder(
//                 itemCount: userList.length,
//                 itemBuilder: (context, index) {
//                   DocumentSnapshot userSnapshot = userList[index];
//                   Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
//                   return ListTile(
//                     leading: CircleAvatar(
//                       backgroundImage: NetworkImage(userData['profile']),
//                     ),
//                     title: Text(userData['name']),
//                     subtitle: Text(userData['email']),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => ChatPage(
//                           name: userData['name'],
//                           image: userData['profile'],
//                           email: userData['email'],
//                           uid: userData['uid'],
//                         )),
//                       );
//                     },
//                   );
//                 },
//               );
//             } else {
//               return Center(child: Text('User doesn\'t exist'));
//             }
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }
//
// class UserSearchDelegate extends SearchDelegate<String> {
//   final Function(String, AsyncSnapshot<QuerySnapshot>) searchCallback;
//
//   UserSearchDelegate(this.searchCallback);
//
//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }
//
//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, '');
//       },
//     );
//   }
//
//   @override
//   Widget buildResults(BuildContext context) {
