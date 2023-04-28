import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadImage() async {
  ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
  print('${file?.path}');

  if (file == null) return '';

  String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

  Reference referenceRoot = FirebaseStorage.instance.ref();
  Reference referenceDirImages = referenceRoot.child('images');
  Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

  try {
    await referenceImageToUpload.putFile(File(file.path));
    String imageUrl = await referenceImageToUpload.getDownloadURL();
    return imageUrl;
  } catch (e) {
    print(e);
    return '';
  }
}
