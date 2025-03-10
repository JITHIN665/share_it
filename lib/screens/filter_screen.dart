import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/media_file.dart';
import '../widgets/filter_widget.dart';
import 'preview_screen.dart';

class FilterScreen extends StatefulWidget {
  final List<MediaFile> files;
  const FilterScreen({super.key, required this.files});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  Color selectedFilter = Colors.transparent;
  late PageController _pageController;
  int currentIndex = 0;
  final List<VideoPlayerController?> _videoControllers = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    initVideoControllers();
  }

  void initVideoControllers() {
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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Post")),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.files.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: mediaPreview(widget.files[index], index),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          FilterWidget(onFilterSelected: (color) {
            setState(() => selectedFilter = color);
          }),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text('Next', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PreviewScreen(files: widget.files, filterColor: selectedFilter),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget mediaPreview(MediaFile media, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: media.type == MediaType.image
              ? Image.file(File(media.path), fit: BoxFit.cover)
              : (_videoControllers[index] != null && _videoControllers[index]!.value.isInitialized)
                  ? AspectRatio(
                      aspectRatio: _videoControllers[index]!.value.aspectRatio,
                      child: VideoPlayer(_videoControllers[index]!),
                    )
                  : const Center(child: CircularProgressIndicator()),
        ),
        if (media.type == MediaType.image) Container(color: selectedFilter.withOpacity(0.3)),
      ],
    );
  }
}
