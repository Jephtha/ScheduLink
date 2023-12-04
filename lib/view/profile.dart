import 'dart:io';
import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/schedule_service.dart';
import '../model/user_info.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _Profile();
}

class _Profile extends State<Profile> {
  final ScheduleService scheduleService = ScheduleService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String contact = '';
  String imgURL = '';
  String name = '';
  List courses = [];
  List<Map<String, dynamic>> courseInfo = [];

  List<String> contactOptions = [
    'email',
    'phone number',
    'instagram',
    'snapchat',
    'twitter'
  ];
  String? selectedContactOption = '';

  void setSelectedContactOption(String? value) {
    setState(() => selectedContactOption = value);
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      UserInfo user = await scheduleService.getUserInfo();
      setState(() {
        name = user.name;
        contact = user.contactInfo;
        imgURL = user.profileImg;
        courseInfo = user.userCourses!;
        List tempCourse = [];

        List<Map<String, dynamic>> c = user.userCourses!;
        for (var element in c) {
          tempCourse.add(element['course']);
        }

        courses = tempCourse;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/homepage');
              }),
          title: Text("Profile"),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 140, 0)),
                      Expanded(
                        child: TextFormField(
                          initialValue: name,
                          decoration: InputDecoration(
                            labelText: "Name:",
                            border: InputBorder.none,
                            hintText: 'Your Name',
                            icon: const Icon(Icons.edit),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Name';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            setState(() => name = value!);
                          },
                        ),
                      ),
                      //Text(name!,style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  if (imgURL == '')
                    Container(
                      constraints: const BoxConstraints(maxWidth: 250),
                      child: Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          child: Text(
                            name == '' ? 'A' : name[0],
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        //CircleAvatar(child: Image.network("https://img.freepik.com/premium-vector/account-icon-user-icon-vector-graphics_292645-552.jpg",width: 250,height: 250)),
                      ),
                    ),
                  if (imgURL != '')
                    Container(
                      constraints: const BoxConstraints(maxWidth: 250),
                      child: Center(
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(imgURL),
                          radius: 70,
                        ),
                        //Image.network(imgURL!),
                      ),
                    ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ImageSet()),
                      ).then((value) => setState(() {
                            imgURL = value;
                          }));
                    },
                    child: Text('Change Profile Image'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                            'Please pick one of the available options for Contact Info'),
                        SingleChildScrollView(
                          child: InlineChoice<String>.single(
                            clearable: true,
                            value: selectedContactOption,
                            onChanged: setSelectedContactOption,
                            itemCount: contactOptions.length,
                            itemBuilder: (state, i) {
                              return ChoiceChip(
                                selected: state.selected(contactOptions[i]),
                                selectedColor: Colors.blue,
                                onSelected: state.onSelected(contactOptions[i]),
                                label: Text(contactOptions[i]),
                              );
                            },
                            listBuilder: ChoiceList.createScrollable(
                              spacing: 10,
                              runSpacing: 10,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Row(children: [
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 115, 0)),
                              Expanded(
                                child: TextFormField(
                                  initialValue: contact,
                                  decoration: InputDecoration(
                                    labelText: "Contact: ",
                                    border: InputBorder.none,
                                    hintText: 'Enter your contact info',
                                    icon: const Icon(Icons.edit),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your contact Info';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    setState(() {
                                      contact = "";
                                      if (selectedContactOption != '') {
                                        contact = "${selectedContactOption!}- ";
                                      }
                                      contact = contact + value.toString();
                                      scheduleService
                                          .addContactInfo2User(contact);
                                      print(contact);
                                    });
                                  },
                                ),
                              )
                            ])),
                      ]),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Courses: ", style: TextStyle(fontSize: 18)),
                  SizedBox(
                    height: 10,
                  ),
                  for (var i in courses) courseButton(i),
                  SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _addUserInfo();
                    },
                    child: Text('Submit'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _signOut();
                      if (context.mounted)
                        Navigator.pushReplacementNamed(context, '/sign-in');
                    },
                    child: Text('Sign Out'),
                  ),
                ]),
          ),
        ));
  }

  Future<void> _addUserInfo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final userInfo = UserInfo(
          name: name,
          profileImg: imgURL,
          contactInfo: contact,
          userCourses: courseInfo);
      print("$name $contact $imgURL");
      await scheduleService.updateUserInfo(userInfo);

      if (context.mounted) {
        if (!Navigator.canPop(context)) {
          Navigator.pushReplacementNamed(context, '/homepage');
        } else {
          //Navigator.of(context).pop();
        }
      }
    } else {
      print("Form is invalid");
    }
  }

  Widget courseButton(String courseNo) {
    return Column(
      children: [
        ElevatedButton(
          style: ButtonStyle(
              padding:
                  MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.greenAccent),
              shadowColor: MaterialStateProperty.all<Color>(Colors.grey),
              elevation: MaterialStateProperty.resolveWith<double>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) return 10;
                  return 5; // default elevation
                },
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              animationDuration: Duration(milliseconds: 200)),
          onPressed: () => {},
          child: Text(
            courseNo,
            style: TextStyle(color: Colors.black),
          ),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}

class ImageSet extends StatefulWidget {
  const ImageSet({super.key});
  @override
  State<ImageSet> createState() => _ImageSet();
}

class _ImageSet extends State<ImageSet> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String imgURL = '';

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
        if (context.mounted) Navigator.pop(context, imgURL);
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
                  Navigator.pop(context, imgURL);
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
