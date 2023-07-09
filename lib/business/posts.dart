import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/business/add_posts.dart';
import 'package:travel_buddy/constant/fonts.dart';
import 'package:travel_buddy/main.dart';

import '../constant/colors.dart';
import '../resources/firestore_methods.dart';
import 'comments.dart';
import 'likes.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
     appBar: AppBar(
       title: Text("Posts", style: appbar,),
              // backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.messenger_outline,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length??0,
            itemBuilder: (ctx, index) => Container(
              margin: EdgeInsets.symmetric(
                horizontal: width > webScreenSize ? width * 0.3 : 0,
                vertical: width > webScreenSize ? 15 : 0,
              ),
              child: PostCard(
                snap: snapshot.data?.docs[index].data(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_){
            return AddPostPage();
          }));

        },
        child: Icon(Icons.add, color: Colors.green,),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({
    required this.snap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;
  String? currentUserImage;
  String? currentUserName;
String? uid;
  @override
  void initState() {
    super.initState();
    fetchCommentLen();
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


  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      displayMessage(err.toString());
    }
    setState(() {});
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
    } catch (err) {
      displayMessage(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // final model.User user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;

    return Container(
      // boundary needed for web
      decoration: BoxDecoration(
        border: Border.all(
          // color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
        ),
        // color: mobileBackgroundColor,
      ),
      padding:  EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        children: [
          // HEADER SECTION OF THE POST
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                widget.snap['userImage'].toString(),
              ),
            ),
            title: Text(
              widget.snap['userName'].toString(),
              style:  TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              widget.snap['title'].toString(),
              style:  TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // IMAGE SECTION OF THE POST
          GestureDetector(
            onDoubleTap: () {
              FireStoreMethods().likePost(
                widget.snap['postId'].toString(),
                uid??"",
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: Image.network(
                    widget.snap['imageUrl'].toString(),
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: Duration(
                      milliseconds: 400,
                    ),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child:  Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // LIKE, COMMENT SECTION OF THE POST
          Row(
            children: <Widget>[
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(uid),
                smallLike: true,
                child: IconButton(
                  icon: widget.snap['likes'].contains(uid)
                      ? Icon(
                    Icons.favorite,
                    color: Colors.red,
                  )
                      : Icon(
                    Icons.favorite_border,
                  ),
                  onPressed: () => FireStoreMethods().likePost(
                    widget.snap['postId'].toString(),
                    uid ?? "",
                    widget.snap['likes'],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.comment_outlined,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommentsScreen(
                      postId: widget.snap['postId'].toString(),
                    ),
                  ),
                ),
              ),
              IconButton(
                  icon: Icon(
                    Icons.send,
                  ),
                  onPressed: () {}),
              Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                        icon: Icon(Icons.bookmark_border), onPressed: () {}),
                  ))
            ],
          ),
          //DESCRIPTION AND NUMBER OF COMMENTS
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.w800),
                    child: Text(
                      '${widget.snap['likes'].length} likes',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: 8,
                  ),
                  child: Text(
                     ' ${widget.snap['description']}',
                  ),
                ),
                InkWell(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'View all $commentLen comments',
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        postId: widget.snap['postId'].toString(),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.snap['datePublish'].toDate()),
                    style: TextStyle(
                      color: secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}





var webScreenSize = 600;



// class AllPostsPage extends StatefulWidget {
//   @override
//   _AllPostsPageState createState() => _AllPostsPageState();
// }
//
// class _AllPostsPageState extends State<AllPostsPage> {
//   var _searchController = TextEditingController();
//   late Query _query;
//
//   @override
//   void initState() {
//     super.initState();
//     _query = FirebaseFirestore.instance.collection('posts');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: TextField(
//           controller: _searchController,
//           decoration: InputDecoration(
//             hintText: 'Search',
//             hintStyle: textFireld,
//             suffixIcon: IconButton(
//               icon: Icon(Icons.clear),
//               onPressed: () {
//                 _searchController.clear();
//                 _query = FirebaseFirestore.instance.collection('posts');
//                 setState(() {});
//               },
//             ),
//           ),
//           onChanged: (value) {
//             setState(() {
//               _query = FirebaseFirestore.instance
//                   .collection('posts')
//                   .where('title', isGreaterThanOrEqualTo: value);
//             });
//           },
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _query.snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           final posts = snapshot.data!.docs;
//
//           if (posts.isEmpty) {
//             return Center(child: Text('No posts available.'));
//           }
//
//           return Padding(
//             padding: EdgeInsets.all(8.0),
//             child: GridView.builder(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 1,
//                 crossAxisSpacing: 4.0,
//                 mainAxisSpacing: 4.0,
//               ),
//               itemCount: posts.length,
//               itemBuilder: (context, index) {
//                 final postSnapshot = posts[index];
//
//                 return Column(
//                   children: [
//                     ListTile(
//                       leading: CircleAvatar(
//                         radius: 30,
//                         backgroundImage:
//                         NetworkImage(postSnapshot['userImage']),
//                       ),
//                       title: Text(
//                         postSnapshot['userName'],
//                         style: postuser,
//                       ),
//                       subtitle: Text(
//                         postSnapshot['title'],
//                         style: title,
//                       ),
//                     ),
//                     Expanded(
//                       child: GridTile(
//                         child: Image.network(
//                           postSnapshot['imageUrl'],
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         postSnapshot['description'],
//                         style: desc,
//                       ),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         Row(
//                           children: [
//                             IconButton(
//                               icon: Icon(Icons.favorite),
//                               color: postSnapshot['isLiked'] ? Colors.red : Colors.grey,
//                               onPressed: () {
//                                 final bool isLiked = postSnapshot['isLiked'];
//                                 final int likesCount = postSnapshot['likes'] ?? 0;
//
//                                 final likesRef = FirebaseFirestore.instance.collection('likes').doc(postSnapshot.id);
//                                 final likeData = {
//                                   'isLiked': !isLiked,
//                                   'likesCount': isLiked ? likesCount - 1 : likesCount + 1,
//                                 };
//
//                                 likesRef.get().then((snapshot) {
//                                   if (snapshot.exists) {
//                                     likesRef.update(likeData);
//                                   } else {
//                                     likesRef.set(likeData);
//                                   }
//                                 });
//                               },
//                             ),
//                             StreamBuilder<DocumentSnapshot>(
//                               stream: FirebaseFirestore.instance
//                                   .collection('likes')
//                                   .doc(postSnapshot.id)
//                                   .snapshots(),
//                               builder: (context, snapshot) {
//                                 final data = snapshot.data?.data();
//                                 if (snapshot.hasError || !snapshot.hasData || data == null) {
//                                   return Text(
//                                     '0 Likes',
//                                     style: postuser,
//                                   );
//                                 }
//
//                                 final likesCount = data['likesCount'] ?? 0;
//
//                                 return Text(
//                                   '$likesCount Likes',
//                                   style: postuser,
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             IconButton(
//                               icon: Icon(Icons.comment),
//                               onPressed: () {
//                                 // Navigate to the comments page or show a dialog to add comments
//                               },
//                             ),
//                             StreamBuilder<DocumentSnapshot>(
//                               stream: FirebaseFirestore.instance
//                                   .collection('comments')
//                                   .doc(postSnapshot.id)
//                                   .snapshots(),
//                               builder: (context, snapshot) {
//                                 final data = snapshot.data?.data();
//                                 if (snapshot.hasError || !snapshot.hasData || data == null) {
//                                   return Text(
//                                     '0 Comments',
//                                     style: postuser,
//                                   );
//                                 }
//
//                                 final commentsCount = data['commentsCount'] ?? 0;
//
//                                 return Text(
//                                   '$commentsCount Comments',
//                                   style: postuser,
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     Divider(
//                       thickness: 1,
//                       height: 1,
//                       endIndent: 0,
//                       indent: 0,
//                     ),
//                   ],
//                 );
//               },
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => AddPostPage()),
//           );
//         },
//         child: Icon(
//           Icons.add,
//           color: Colors.green,
//         ),
//       ),
//     );
//   }
// }

// Navigator.push(
// context,
// MaterialPageRoute(
// builder: (_) => CommentsScreen(
// postId: postSnapshot['postId'],
// ),
// ),
// );
