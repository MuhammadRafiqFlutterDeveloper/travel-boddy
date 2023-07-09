import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_buddy/constant/fonts.dart';

import '../account/login_screen.dart';
import '../constant/colors.dart';
import '../main.dart';

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        title: Text('User Screen', style: appbar,),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: usersCollection.doc(currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic>? userData =
                snapshot.data!.data() as Map<String, dynamic>?;

            if (userData != null) {
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: userData.containsKey('profile')
                          ? NetworkImage(userData['profile']) as ImageProvider
                          : AssetImage('assets/user_image.png'),
                    ),
                    SizedBox(height: 16),
                    Text(
                      userData.containsKey('name')
                          ? userData['name']
                          : 'John Doe',
                      style: appbar
                    ),
                    SizedBox(height: 8),
                    Text(
                      currentUser.email ?? 'john.doe@example.com',
                      style: title,
                    ),
                    SizedBox(height: 32),
                    ListTile(
                      leading: Icon(Icons.edit, color: Colors.green,),
                      title: Text('Edit Profile', style: postuser,),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.green,),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              image: userData['profile'],
                              name: userData['name'],
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.green,),
                      title: Text('Logout', style: postuser,),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.green,),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirmation', style: appbar,),
                              content: Text('Are you sure you want to logout?', style: postuser,),
                              actions: [
                                TextButton(
                                  child: Text('Cancel', style: buttonText,),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Logout', style: buttonText,),
                                  onPressed: () {
                                    // Perform logout
                                    FirebaseAuth.instance.signOut();
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (_) => LoginPage()),
                                          (Route<dynamic> route) => false,
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                  ],
                ),
              );
            }
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: red),));
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String image;

  EditProfileScreen({required this.name, required this.image});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  File? selectedImage;

  @override
  void initState() {
    _nameController.text = widget.name;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> chooseImage(type) async {
    var image;
    if (type == "camera") {
      image = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
    } else {
      image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
    }
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: appbar,),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profile',
              style: postuser,
            ),
            SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () {
                  _choseShowDialog(context);
                },
                child: ClipOval(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!) as ImageProvider
                        : NetworkImage(widget.image),
                  ),
                ),
              ),
            ),
            SizedBox(height: 50),
            Container(
              height: 60,
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 50),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width, 50)
                ),
                onPressed: () async {
                  // Save changes and update the profile
                  String newName = _nameController.text;
                  File? newImage = selectedImage;
                  String uid = FirebaseAuth.instance.currentUser!.uid;

                  try {
                    if (newImage != null) {
                      // Upload the new image to Firebase Storage
                      Reference ref = FirebaseStorage.instance
                          .ref()
                          .child('userImages')
                          .child(uid + '.jpg');
                      await ref.putFile(newImage);
                      String imageUrl = await ref.getDownloadURL();

                      // Update the name and image URL in Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .update({
                        'name': newName,
                        'profile': imageUrl,
                      });
                    } else {
                      // Update only the name in Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .update({
                        'name': newName,
                      });
                    }

                    // Profile update successful
                    displayMessage('Profile updated successfully.');
                  } catch (error) {
                    // Error updating profile
                    displayMessage('Failed to update profile: $error');
                  }
                },
                child: Text('Save Changes', style: buttonText,),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _choseShowDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image From',style: appbar,),
          actions: [
            GestureDetector(
              child: Text(
                'Gallery',
                style: buttonText,
              ),
              onTap: () {
                chooseImage('Gallery');
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.all(10),
              child: GestureDetector(
                child: Text(
                  'Camera',
                  style: buttonText,
                ),
                onTap: () {
                  chooseImage('camera');
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
