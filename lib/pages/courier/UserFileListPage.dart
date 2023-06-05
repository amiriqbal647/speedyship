import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image/flutter_image.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class UserFileListPage extends StatelessWidget {
  final String userId;
  final String firstName;
  final String lastName;

  UserFileListPage({
    required this.userId,
    required this.firstName,
    required this.lastName,
  });

  @override
  Widget build(BuildContext context) {
    final userFilesRef = FirebaseStorage.instance
        .ref()
        .child("courier_records/$userId/$firstName" + "_" + "$lastName");

    return Scaffold(
      appBar: AppBar(
        title: Text('User File List'),
      ),
      body: FutureBuilder<ListResult>(
        future: userFilesRef.listAll(),
        builder: (BuildContext context, AsyncSnapshot<ListResult> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = snapshot.data!.items[index];
                return ListTile(
                  title: Text(item.name),
                  onTap: () => openFile(context, item),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error retrieving user files'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void openFile(BuildContext context, Reference fileRef) async {
    final fileUrl = await fileRef.getDownloadURL();
    final fileBytes = await fileRef.getData();

    // Check if the file is an image (JPEG)
    if (fileRef.name.toLowerCase().endsWith('.jpg') ||
        fileRef.name.toLowerCase().endsWith('.jpeg')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageFileViewer(fileBytes),
        ),
      );
    }
    // Check if the file is a PDF
    else if (fileRef.name.toLowerCase().endsWith('.pdf')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfFileViewer(fileUrl),
        ),
      );
    }
    // Add other file types as needed
    // Handle unrecognized file types
    else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Unsupported File'),
          content: Text('The selected file format is not supported.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

class ImageFileViewer extends StatelessWidget {
  final Uint8List? fileBytes;

  ImageFileViewer(this.fileBytes);

  @override
  Widget build(BuildContext context) {
    if (fileBytes != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Image Viewer'),
        ),
        body: Center(
          child: Image.memory(fileBytes!),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Image Viewer'),
        ),
        body: Center(
          child: Text('Error loading image'),
        ),
      );
    }
  }
}

class PdfFileViewer extends StatelessWidget {
  final String fileUrl;

  PdfFileViewer(this.fileUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: PDFView(
        filePath: fileUrl,
      ),
    );
  }
}
