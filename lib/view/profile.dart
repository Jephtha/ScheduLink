// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, unused_import

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:schedulink/controller/schedule_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schedulink/view/course_info.dart';

String? contact, imgURL, name;

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<Profile> {
  final _usersStream = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          if (snapshot.data["profileImg"] != null) {
            imgURL = snapshot.data['profileImg'];
          }
          if (snapshot.data["contactInfo"] != null) {
            contact = snapshot.data['contactInfo'];
          }
          if (snapshot.data["name"] != null) {
            name = snapshot.data['name'];
          }
          var courses = snapshot.data['userCourses'];

          var cName = [];
          for (var element in courses) {
            String courseName = element['course'];
            cName.add(courseName);
          }
          return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                title: Text("Profile"),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.fromLTRB(0, 60, 0, 0)),
                    if (name != null)
                      Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(name!,style: TextStyle(fontSize: 20)), 
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              /* edit name */
                            },
                          ),
                      ],),

                    if (imgURL == null)
                      Container(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: Center(child: Stack(children: [
                        IconButton.filledTonal(
                          icon: const Icon(Icons.edit),
                          tooltip: ("Add image"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ImageSet()),
                            ).then((value) => setState(() {}));
                          },
                        ),
                        CircleAvatar(child: Image.network("https://img.freepik.com/premium-vector/account-icon-user-icon-vector-graphics_292645-552.jpg",width: 250,height: 250)),
                      ],))),
    
                    if (imgURL != null)
                      Container(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: Center(child: Stack(children: [
                        Image.network(imgURL!),
                        IconButton.filledTonal(
                          color: Colors.black,
                          iconSize: 20,
                          icon: const Icon(Icons.edit),
                          tooltip: ("Edit image"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ImageSet()),
                            ).then((value) => setState(() {}));
                          },
                        ),
                      ],))),

                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Contact: ",
                              style: TextStyle(fontSize: 18)),
                          if (contact != null)
                            Container(
                                alignment: Alignment.center,
                                child: Text(contact!, style: TextStyle(fontSize: 18))),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditContact()),
                              ).then((value) => setState(() {}));
                            },
                          ),
                        ]),
                    if (contact == null)
                      Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(20),
                          child: Text("Please Enter Contact Information.",
                              style: TextStyle(fontSize: 18))),
                    Text("Courses: ", style: TextStyle(fontSize: 18)),
                    for (var c in cName)
                      Text(c, style: TextStyle(fontSize: 18))
                  ])));
        });
  }
}

class ImageSet extends StatefulWidget {
  const ImageSet({super.key});
  @override
  _ImageSet createState() => _ImageSet();
}

class _ImageSet extends State<ImageSet> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  Future<void> _uploadImageToFirebase() async {
    final ScheduleService service = ScheduleService();
    if (_image == null) return;
    if (service.currentUser == null) return;
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('images/${service.currentUser!.uid}/${_image!.name}');
    try {
      final uploadTask = await firebaseStorageRef.putFile(File(_image!.path));
      if (uploadTask.state == TaskState.success) {
        final downloadURL = await firebaseStorageRef.getDownloadURL();
        service.addProfileImg2User(downloadURL);
        imgURL = downloadURL;
        print("Uploaded to: $downloadURL");
        Navigator.pop(context);
      }
    } catch (e) {
      print("Failed to upload image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Update Profile Picture'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_image != null)
                Container(
                  margin: EdgeInsets.all(20),
                  height: 200,
                  width: 200,
                  child: Image.file(
                    File(_image!.path),
                  ),
                ),
              ElevatedButton(
                onPressed: _pickImageFromGallery,
                child: Text('Pick Image from Gallery'),
              ),
              ElevatedButton(
                onPressed: _pickImageFromCamera,
                child: Text('Capture Image from Camera'),
              ),
              ElevatedButton(
                onPressed: _uploadImageToFirebase,
                child: Text('Set User Picture'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditContact extends StatefulWidget {
  @override
  _EditContact createState() => _EditContact();
}

class _EditContact extends State<EditContact> {
  final _formKey = GlobalKey<FormState>();
  final ScheduleService service = ScheduleService();
  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      // Saves the form's current state.
      _formKey.currentState!.save();

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Change Contact Information'),
        content: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'contact information'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact information';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    service.addContactInfo2User(value!);
                    contact = value;
                  },
                ),
              ],
            )),
        actions: [
          ElevatedButton(
            onPressed: _saveContact,
            child: Text('edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          )
        ]);
  }
}
