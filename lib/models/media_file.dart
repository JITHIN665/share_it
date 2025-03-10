enum MediaType { image, video }

class MediaFile {
  final String path;
  final MediaType type;

  MediaFile({required this.path, required this.type});
}
