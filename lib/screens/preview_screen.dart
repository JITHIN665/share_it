import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../models/media_file.dart';
import 'home_screen.dart';

class PreviewScreen extends StatefulWidget {
  final List<MediaFile> files;
  final Color filterColor;

  const PreviewScreen({super.key, required this.files, required this.filterColor});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final List<VideoPlayerController?> _videoControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeVideos();
  }

  void _initializeVideos() {
    for (var file in widget.files) {
      if (file.type == MediaType.video) {
        final videoController = VideoPlayerController.file(File(file.path));
        videoController.initialize().then((_) {
          videoController.setLooping(true);
          videoController.play();
          setState(() {});
        });
        _videoControllers.add(videoController);
      } else {
        _videoControllers.add(null);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  Widget buildPreview(MediaFile media, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            media.type == MediaType.image
                ? Image.file(File(media.path), fit: BoxFit.cover)
                : (_videoControllers[index]?.value.isInitialized ?? false)
                    ? AspectRatio(
                        aspectRatio: _videoControllers[index]!.value.aspectRatio,
                        child: VideoPlayer(_videoControllers[index]!),
                      )
                    : const Center(child: CircularProgressIndicator()),
            if (media.type == MediaType.image) Container(color: widget.filterColor.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Post')),
      body: Column(
        children: [
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.files.length,
              itemBuilder: (_, index) => SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: buildPreview(widget.files[index], index),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Share', style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () {
                context.read<PostBloc>().add(AddMediaFiles(widget.files));
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => HomeScreen(
                            filterColor: widget.filterColor,
                            files: widget.files,
                          )),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
