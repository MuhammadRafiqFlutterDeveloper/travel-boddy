import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/constant/fonts.dart';
import '../main.dart';
import '../resources/firestore_methods.dart';

class CommentsScreen extends StatefulWidget {
  final postId;
  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController commentEditingController =
      TextEditingController();

  String? currentUserImage;
  String? currentUserName;
  String? uid;
  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  void fetchCurrentUser() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null) {
            setState(() {
              currentUserName = data['name'] as String?;
              currentUserImage = data['profile'] as String?;
              uid = data['uid'] as String?;
            });
          } else {
            // Handle the case where snapshot.data() is null
            print('Data is null');
          }
        } else {
          // Handle the case where the document does not exist
          print('Document does not exist');
        }
      }).catchError((error) {
        print('Failed to fetch current user: $error');
      });
    }
  }

  void postComment(String uid, String name, String profilePic) async {
    try {
      String res = await FireStoreMethods().postComment(
        widget.postId,
        commentEditingController.text,
        uid,
        name,
        profilePic,
      );

      if (res != 'success') {
        if (context.mounted) displayMessage(res);
      }
      setState(() {
        commentEditingController.text = "";
      });
    } catch (err) {
      displayMessage(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Comments',
          style: appbar,
        ),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (ctx, index) => CommentCard(
              snap: snapshot.data?.docs[index],
            ),
          );
        },
      ),
      // text input
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(currentUserImage ?? ""),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: Container(
                    height: 40,
                    child: TextField(
                      controller: commentEditingController,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 10, left: 5),
                          hintText: 'Comment.....',
                          border: OutlineInputBorder()),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => postComment(
                  uid ?? "",
                  currentUserName ?? "",
                  currentUserImage ?? "",
                ),
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Icon(
                      Icons.send,
                      color: Colors.green,
                      size: 30,
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CommentCard extends StatelessWidget {
  final snap;
  const CommentCard({required this.snap, });

  @override
  Widget build(BuildContext context) {
    final title = snap.data()?['text'] ?? '';
    final datePublish = snap.data()?['datePublish']?.toDate() ?? DateTime.now();
    final username = snap.data()?['name'];
    final userimage = snap.data()?['profilePic'];
    final useruid = snap.data()?['uid'];
print(username,);
print(useruid);
print(title);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(userimage),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "$username:",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        TextSpan(
                          text: ' $title',
                          style: TextStyle(color: Colors.black)
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat.yMMMd().format(datePublish),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.favorite,
              size: 16,
            ),
          )
        ],
      ),
    );
  }
}

// class CommentsScreen extends StatefulWidget {
//   final String postId;
//
//   CommentsScreen({required this.postId});
//
//   @override
//   _CommentsScreenState createState() => _CommentsScreenState();
// }
//
//
// class _CommentsScreenState extends State<CommentsScreen> {
//   final TextEditingController _commentController = TextEditingController();
//   String? currentUserImage;
//   String? currentUserName;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchCurrentUser();
//   }
//
//   void fetchCurrentUser() {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .get()
//           .then((snapshot) {
//         if (snapshot.exists) {
//           final data = snapshot.data();
//           if (data != null) {
//             setState(() {
//               currentUserName = data['name'] as String?;
//               currentUserImage = data['profile'] as String?;
//             });
//           } else {
//             // Handle the case where snapshot.data() is null
//             print('Data is null');
//           }
//         } else {
//           // Handle the case where the document does not exist
//           print('Document does not exist');
//         }
//       }).catchError((error) {
//         print('Failed to fetch current user: $error');
//       });
//     }
//   }
//
//   void _submitComment() {
//     final String commentText = _commentController.text.trim();
//
//     if (commentText.isNotEmpty) {
//       final comment = {
//         'commenterName': currentUserName,
//         'commentText': commentText,
//         // Add any additional fields you want to store for the comment
//       };
//
//       FirebaseFirestore.instance
//           .collection('posts')
//           .doc(widget.postId)
//           .collection('comments')
//           .add(comment)
//           .then((value) {
//         // Comment added successfully
//         _commentController.clear();
//       }).catchError((error) {
//         // Error occurred while adding the comment
//         print('Failed to add comment: $error');
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Comments', style: appbar,),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('posts')
//                   .doc(widget.postId)
//                   .collection('comments')
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red),));
//                 }
//
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//
//                 final comments = snapshot.data!.docs;
//
//                 if (comments.isEmpty) {
//                   return Center(child: Text('No comments available.', style: postuser,));
//                 }
//
//                 return ListView.builder(
//                   itemCount: comments.length,
//                   itemBuilder: (context, index) {
//                     final comment =
//                     comments[index].data() as Map<String, dynamic>;
//                     final commenterName =
//                     comment['commenterName'] as String;
//                     final commentText = comment['commentText'] as String;
//
//                     return ListTile(
//                       leading: CircleAvatar(
//
//                         backgroundImage: NetworkImage(currentUserImage ?? ''),
//                       ),
//                       title: Text(commenterName, style: postuser,),
//                       subtitle: Text(commentText, style: title,),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     height: 50,
//                     child: TextField(
//                       controller: _commentController,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(),
//                         hintText: 'Add a comment...',hintStyle: textFireld,
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send, color: green,size: 40,),
//                   onPressed: _submitComment,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
