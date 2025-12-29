import 'package:file_picker/file_picker.dart';

class MediaServices {
  MediaServices();

  Future<PlatformFile?> pickImageFromLibrary() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    return result != null ? result.files[0] : null;
  }
}
