import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_buddy/constant/fonts.dart';

class UserPostsScreen extends StatelessWidget {
  final String userId;
  final name;
  final image;
  final email;

  UserPostsScreen({required this.userId, this.name, this.image, this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Posts', style: appbar,),
      ),
      body: Padding(
        padding: EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(image),
              ),
              title: Text(name, style: postuser,),
              subtitle: Text(email, style: title,),
            ),
            UserPostCounter(userId: userId),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .where('userId', isEqualTo: userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final posts = snapshot.data!.docs;
                  final postCount = posts.length;

                  if (postCount == 0) {
                    return Center(child: Text('No posts available.'));
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index].data() as Map<String, dynamic>;
                      final imageUrl = post['imageUrl'] as String;

                      return Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserPostCounter extends StatelessWidget {
  final String userId;

  UserPostCounter({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red),);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        final posts = snapshot.data!.docs;
        final postCount = posts.length;

        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Total Posts: $postCount',
            style: appbar,
          ),
        );
      },
    );
  }
}

// class UserPostsScreen extends StatelessWidget {
//   String? userId;
//   String? name;
//   String? image;
//   String? email;
//
//   UserPostsScreen({this.userId, this.name, this.image, this.email});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('User Posts'),
//       ),
//       body: Column(
//         children: [
//           ListTile(
//             leading: CircleAvatar(
//               backgroundImage: NetworkImage(image!),
//             ),
//             title: Text(name!),
//             subtitle: Text(email!),
//             trailing: Icon(Icons.forward),
//           ),
//           StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('posts')
//                 .where('userId', isEqualTo: userId)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               }
//
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: CircularProgressIndicator());
//               }
//
//               final posts = snapshot.data!.docs;
//
//               if (posts.isEmpty) {
//                 return Center(child: Text('No posts available.'));
//               }
//
//               return ListView.builder(
//                 itemCount: posts.length,
//                 itemBuilder: (context, index) {
//                   final post = posts[index].data() as Map<String, dynamic>;
//                   final title = post['title'] as String;
//                   final body = post['body'] as String;
//
//                   return ListTile(
//                     title: Text(title),
//                     subtitle: Text(body),
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
