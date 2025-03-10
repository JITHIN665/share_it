import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../models/media_file.dart';
import 'filter_screen.dart';

class MediaPickerScreen extends StatefulWidget {
  const MediaPickerScreen({super.key});

  @override
  State<MediaPickerScreen> createState() => _MediaPickerScreenState();
}

class _MediaPickerScreenState extends State<MediaPickerScreen> {
  List<AssetEntity> assets = [];
  List<AssetEntity> selectedAssets = [];
  AssetEntity? previewAsset;
  int currentTab = 0;

  @override
  void initState() {
    super.initState();
    fetchAssets(RequestType.common);
  }

  Future<void> fetchAssets(RequestType type) async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) {
      PhotoManager.openSetting();
      return;
    }
    final albums = await PhotoManager.getAssetPathList(type: type);
    assets = await albums.first.getAssetListPaged(page: 0, size: 100);
    setState(() {
      previewAsset = assets.isNotEmpty ? assets.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Post"),
        actions: [
          TextButton(
            onPressed: selectedAssets.isEmpty
                ? null
                : () async {
                    final files = await Future.wait(selectedAssets.map((e) async {
                      final file = await e.file;
                      return MediaFile(path: file!.path, type: e.type == AssetType.video ? MediaType.video : MediaType.image);
                    }));
                    Navigator.push(context, MaterialPageRoute(builder: (_) => FilterScreen(files: files)));
                  },
            child: const Text("Next", style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
      body: Column(
        children: [
          if (previewAsset != null)
            Container(
              height: 200,
              color: Colors.black12,
              child: AssetEntityImage(previewAsset!, fit: BoxFit.cover, width: double.infinity),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              tab(Icons.access_time, "Recent", 0, RequestType.common),
              tab(Icons.photo_library, "Photos", 1, RequestType.image),
              tab(Icons.videocam, "Videos", 2, RequestType.video),
            ],
          ),
          const Divider(),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
              itemCount: assets.length,
              itemBuilder: (_, i) {
                final asset = assets[i];
                final selected = selectedAssets.contains(asset);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        selectedAssets.remove(asset);
                      } else {
                        selectedAssets.add(asset);
                        previewAsset = asset;
                      }
                    });
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AssetEntityImage(
                        asset,
                        fit: BoxFit.cover,
                        thumbnailSize: const ThumbnailSize.square(200),
                      ),
                      if (asset.type == AssetType.video)
                        const Positioned(
                          bottom: 5,
                          left: 5,
                          child: Icon(Icons.videocam, color: Colors.white, size: 18),
                        ),
                      if (selected) selectionNumber(asset),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget tab(IconData icon, String label, int tabIndex, RequestType type) {
    final bool isSelected = currentTab == tabIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentTab = tabIndex;
          fetchAssets(type);
          selectedAssets.clear();
        });
      },
      child: Row(
        children: [
          Icon(icon, color: isSelected ? Colors.purple : Colors.grey),
          Text(label, style: TextStyle(color: isSelected ? Colors.purple : Colors.grey)),
        ],
      ),
    );
  }

  Widget selectionNumber(AssetEntity asset) {
    final index = selectedAssets.indexOf(asset);
    return Positioned(
      top: 5,
      right: 5,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
        child: Center(
          child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ),
    );
  }
}
