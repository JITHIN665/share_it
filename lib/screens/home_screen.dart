import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/media_file.dart';

class HomeScreen extends StatefulWidget {
  final List<MediaFile> files;
  final Color filterColor;

  const HomeScreen({super.key, required this.files, required this.filterColor});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<VideoPlayerController?> _videoControllers = [];
  final PageController _pageController = PageController();

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
    _pageController.dispose();
    super.dispose();
  }

  Widget preview(MediaFile media, int index) {
    return ClipRRect(
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
    );
  }

  Widget indicator(int length) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (index) => AnimatedBuilder(
          animation: _pageController,
          builder: (_, __) {
            double selected = (_pageController.page ?? _pageController.initialPage).roundToDouble();
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: selected == index ? Colors.purple : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/images/care_5.png'),
                ),
                SizedBox(width: 10),
                Text("John Karter", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(
            height: 250,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.files.length,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: preview(widget.files[index], index),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          indicator(widget.files.length),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(alignment: Alignment.centerLeft, child: Text("11 hours ago", style: TextStyle(color: Colors.grey))),
          ),
        ],
      ),
    );
  }
}
