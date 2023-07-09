import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_buddy/constant/fonts.dart';
import 'package:uuid/uuid.dart';
import '../main.dart';

class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  File? _image;
  var postId = Uuid().v1();
  final picker = ImagePicker();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String _currentLocation = 'Unknown';
  bool _uploadingPost = false;

  Future<void> _selectImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadPost() async {
    setState(() {
      _uploadingPost = true;
    });

    try {
      // Get the current location
      _getCurrentLocation();

      // Upload image to Firebase Storage
      String imageName = DateTime.now().toString() + '.jpg';
      String imagePath = 'post_images/$imageName';
      TaskSnapshot snapshot =
          await FirebaseStorage.instance.ref(imagePath).putFile(_image!);

      // Get the download URL of the uploaded image
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Create a new post document in Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'imageUrl': imageUrl,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _currentLocation,
        'userId': uid,
        "postId": postId,
        "likes": [],
        "datePublish": Timestamp.now(),
        "userName": name,
        "userImage": image,
        "userEmail": email,
      });

      // Display success message or navigate to the next screen
      displayMessage('Post uploaded successfully!');
    } catch (e) {
      displayMessage('Error uploading post: $e');
    } finally {
      setState(() {
        _uploadingPost = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    // Implement your logic to get the current location here
    // Assign the current location to _currentLocation variable
    setState(() {
      _currentLocation = 'Dummy Location'; // Replace with actual location
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? name;
  String? image;
  String? email;
  var uid = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (snapshot.exists) {
        final userData = snapshot.data();
        setState(() {
          name = userData!['name'];
          image = userData['profile'];
          email = userData['email'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post', style: appbar,),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Choose an option',
                          textAlign: TextAlign.left,
                          style: appbar,
                        ),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              GestureDetector(
                                child: Text('Gallery', style: buttonText,),
                                onTap: () {
                                  _selectImage(ImageSource.gallery);
                                  Navigator.of(context).pop();
                                },
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                child: Text('Camera', style: buttonText,),
                                onTap: () {
                                  _selectImage(ImageSource.camera);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.green[200],
                    border: Border.all(
                      color: Colors.green,
                      width: 1.0,
                    ),
                  ),
                  child: _image != null
                      ? Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.camera_alt, color: Colors.green,),
                ),
              ),
              SizedBox(height: 25),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Title',
                  textAlign: TextAlign.left,
                  style: postuser
                ),
              ),

              SizedBox(
                height: 60,
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Description',
                  style: postuser
                ),
              ),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width
                      , 40)
                ),
                onPressed: _uploadingPost
                    ? null
                    : () {
                        _uploadPost();
                      },
                child: _uploadingPost
                    ? CircularProgressIndicator()
                    : Text('Submit Post', style: buttonText,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
