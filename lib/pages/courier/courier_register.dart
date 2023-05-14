import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';

class DocumentUploader extends StatefulWidget {
  @override
  _DocumentUploaderState createState() => _DocumentUploaderState();
}

Future<void> addUserStatusPending(String userId) async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .update({"status": "pending"});
}

class _DocumentUploaderState extends State<DocumentUploader> {
  File? _file1;
  File? _file2;

  void _pickFile1() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _file1 = File(result.files.single.path!);
      });
    }
  }

  void _pickFile2() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _file2 = File(result.files.single.path!);
      });
    }
  }

  void _uploadFiles(BuildContext context) async {
    // Add BuildContext as a parameter
    if (_file1 != null && _file2 != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final uid = currentUser!.uid;
      final userDoc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      final firstName = userDoc.get("firstName");
      final lastName = userDoc.get("lastName");

      final folderRef = FirebaseStorage.instance
          .ref()
          .child("courier_records/$uid/$firstName" + "_" + "$lastName");

      final file1Name = basename(_file1!.path);
      final file1Ref = folderRef.child(file1Name);
      await file1Ref.putFile(_file1!);

      final file2Name = basename(_file2!.path);
      final file2Ref = folderRef.child(file2Name);
      await file2Ref.putFile(_file2!);

      final usid = currentUser!.uid;
      await addUserStatusPending(usid);

      showDialog(
        context: context,
        builder: (BuildContext context) => _buildDialogContent(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Your Documents'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 5,
              child: ListTile(
                leading: Icon(Icons.drive_file_rename_outline,
                    color: Color(0xFFF57C00), size: 30),
                title: Text('Drivers License',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: _file1 == null
                    ? Text("No file selected")
                    : Text(basename(_file1!.path)),
                trailing: IconButton(
                  icon: Icon(Icons.file_upload, color: Color(0xFFF57C00)),
                  onPressed: _pickFile1,
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              child: ListTile(
                leading: Icon(Icons.drive_file_rename_outline,
                    color: Color(0xFFF57C00), size: 30),
                title: Text('Conviction Record',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: _file2 == null
                    ? Text("No file selected")
                    : Text(basename(_file2!.path)),
                trailing: IconButton(
                  icon: Icon(Icons.file_upload, color: Color(0xFFF57C00)),
                  onPressed: _pickFile2,
                ),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _uploadFiles(context),
              child: Text("Submit Documents"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
                primary: Colors.teal,
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDialogContent(BuildContext context) {
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 0,
    backgroundColor: Colors.transparent,
    child: Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 100,
            bottom: 20,
            left: 20,
            right: 20,
          ),
          margin: EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Your application has been submitted. Please wait until the admin approves your request.',
                style: TextStyle(
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 16,
          right: 16,
          child: CircleAvatar(
            backgroundColor: Colors.green,
            radius: 45,
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
      ],
    ),
  );
}
