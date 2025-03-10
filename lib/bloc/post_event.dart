
import '../models/media_file.dart';

abstract class PostEvent {}

class AddMediaFiles extends PostEvent {
  final List<MediaFile> files;
  AddMediaFiles(this.files);
}
