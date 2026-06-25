
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );
    return image;
  }

Future<String> uploadMenuItemImage(XFile imageFile) async {
  final fileName =
      'menu_items/${DateTime.now().millisecondsSinceEpoch}.jpg';

  final ref = _storage.ref().child(fileName);

  final bytes = await imageFile.readAsBytes();

  final snapshot = await ref.putData(
    bytes,
    SettableMetadata(contentType: 'image/jpeg'),
  );

  return await snapshot.ref.getDownloadURL();
}

  // pick AND upload in one step
  // returns URL or null if user cancelled
  Future<String?> pickAndUploadImage() async {
    final image = await pickImageFromGallery();
    if (image == null) return null;

    final url = await uploadMenuItemImage(image);
    return url;
  }
}