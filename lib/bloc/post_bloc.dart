import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_event.dart';
import 'post_state.dart';
import '../models/media_file.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final List<MediaFile> posts = [];

  PostBloc() : super(PostInitial()) {
    on<AddMediaFiles>((event, emit) {
      posts.addAll(event.files);
      emit(PostLoaded(List.from(posts)));
    });
  }
}
