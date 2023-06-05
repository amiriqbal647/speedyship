import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:speedyship/components/my_button.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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

  bool _isFileTypeAccepted(File? file) {
    if (file == null) return false;
    String fileExtension = extension(file.path).toLowerCase();
    return fileExtension == '.jpg';
  }

  void _uploadFiles(BuildContext context) async {
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
        title: const Text('Upload Your Documents'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Device.screenType == ScreenType.tablet
            ? Center(
                child: SizedBox(
                  width: 50.w,
                  child: Column(
                    children: [
                      Card(
                        elevation: 5,
                        child: ListTile(
                          leading: const Icon(
                            Icons.drive_file_rename_outline,
                            size: 30,
                          ),
                          title: Text(
                            'Drivers License',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          subtitle: _file1 == null
                              ? Text("No file selected")
                              : Text(basename(_file1!.path)),
                          tileColor: _isFileTypeAccepted(_file1)
                              ? null
                              : Colors.red.shade100,
                          trailing: IconButton(
                            icon: const Icon(Icons.file_upload),
                            onPressed: _pickFile1,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Card(
                        elevation: 5,
                        child: ListTile(
                          leading: const Icon(
                            Icons.drive_file_rename_outline,
                            size: 30,
                          ),
                          title: Text(
                            'Conviction Record',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          subtitle: _file2 == null
                              ? Text("No file selected")
                              : Text(basename(_file2!.path)),
                          tileColor: _isFileTypeAccepted(_file2)
                              ? null
                              : Colors.red.shade100,
                          trailing: IconButton(
                            icon: const Icon(Icons.file_upload),
                            onPressed: _pickFile2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Only JPG files are accepted',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 32),
                      MyButton(
                        buttonText: 'Submit Documents',
                        onTap: () => _uploadFiles(context),
                      )
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  Card(
                    elevation: 5,
                    child: ListTile(
                      leading: const Icon(
                        Icons.drive_file_rename_outline,
                        size: 30,
                      ),
                      title: Text(
                        'Drivers License',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      subtitle: _file1 == null
                          ? Text("No file selected")
                          : Text(basename(_file1!.path)),
                      tileColor: _isFileTypeAccepted(_file1)
                          ? null
                          : Colors.red.shade100,
                      trailing: IconButton(
                        icon: const Icon(Icons.file_upload),
                        onPressed: _pickFile1,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 5,
                    child: ListTile(
                      leading: const Icon(
                        Icons.drive_file_rename_outline,
                        size: 30,
                      ),
                      title: Text(
                        'Conviction Record',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      subtitle: _file2 == null
                          ? Text("No file selected")
                          : Text(basename(_file2!.path)),
                      tileColor: _isFileTypeAccepted(_file2)
                          ? null
                          : Colors.red.shade100,
                      trailing: IconButton(
                        icon: const Icon(Icons.file_upload),
                        onPressed: _pickFile2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Only JPG files are accepted',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  MyButton(
                    buttonText: 'Submit Documents',
                    onTap: () => _uploadFiles(context),
                  )
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
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Documents Uploaded Successfully',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your documents have been uploaded successfully. Please wait for verification.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 20,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 45,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(45)),
              child: Image.asset(
                'assets/images/checkmark.png',
                height: 80,
                width: 80,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

void main() {
  runApp(ResponsiveSizer(builder: (context, orientation, deviceType) {
    return MaterialApp(
      home: DocumentUploader(),
    );
  }));
}
