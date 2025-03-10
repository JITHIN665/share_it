import '../models/media_file.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoaded extends PostState {
  final List<MediaFile> posts;
  PostLoaded(this.posts);
}
