import 'dart:io';
import 'dart:typed_data';

import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/post/presentation/provider/story_list_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/story/crud_story/media_editor/media_editor_page.dart';
import 'package:eefood/features/post/presentation/widgets/story/crud_story/multi_create_story_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryPickerPage extends StatefulWidget {
  final int userId;
  final StoryCubit storyCubit;
  const GalleryPickerPage({
    super.key,
    required this.userId,
    required this.storyCubit,
  });

  @override
  State<GalleryPickerPage> createState() => _GalleryPickerPageState();
}

class _GalleryPickerPageState extends State<GalleryPickerPage> {
  List<AssetEntity> assets = [];
  bool isLoading = true;

  final ValueNotifier<bool> isMulti = ValueNotifier(false);
  final ValueNotifier<Set<String>> selectedIds = ValueNotifier({});

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    final ps = await PhotoManager.requestPermissionExtend();
    if (!ps.hasAccess) return PhotoManager.openSetting();

    final recent = (await PhotoManager.getAssetPathList(
      type: RequestType.common,
    )).first;
    assets = await recent.getAssetListPaged(page: 0, size: 200);

    setState(() => isLoading = false);
  }

  Future<void> _finish() async {
    final List<File> files = [];

    for (final a in assets) {
      if (selectedIds.value.contains(a.id)) {
        final f = await a.file;
        if (f != null) files.add(f);
      }
    }

    // Mở preview
    if (widget.storyCubit != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: widget.storyCubit!,
            child: MultiPreviewPage(files: files, userId: widget.userId),
          ),
        ),
      );
      if (result != null) {
        Navigator.pop(context, result);
      }
    } else {
      Navigator.pop(context, files);
    }
  }

  @override
  void dispose() {
    isMulti.dispose();
    selectedIds.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: ValueListenableBuilder(
        valueListenable: isMulti,
        builder: (_, multi, __) => ValueListenableBuilder(
          valueListenable: selectedIds,
          builder: (_, ids, __) =>
              Text(multi ? "Đã chọn (${ids.length})" : "Chọn ảnh hoặc video"),
        ),
      ),
      actions: [
        ValueListenableBuilder(
          valueListenable: isMulti,
          builder: (_, multi, __) {
            if (!multi) {
              return TextButton(
                onPressed: () {
                  isMulti.value = true;
                },
                child: const Text(
                  "Chọn nhiều",
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              );
            }
            return ValueListenableBuilder(
              valueListenable: selectedIds,
              builder: (_, ids, __) => TextButton(
                onPressed: ids.isEmpty ? null : _finish,
                child: const Text("Xong"),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _checkbox(String id) {
    return ValueListenableBuilder<bool>(
      valueListenable: isMulti,
      builder: (_, multi, __) {
        if (!multi) return const SizedBox.shrink();

        return ValueListenableBuilder<Set<String>>(
          valueListenable: selectedIds,
          builder: (_, ids, __) {
            final checked = ids.contains(id);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked ? Colors.blue : Colors.white70,
              ),
              child: Icon(
                checked ? Icons.check : Icons.circle_outlined,
                color: checked ? Colors.white : Colors.black54,
                size: 18,
              ),
            );
          },
        );
      },
    );
  }

  Widget _assetItem(AssetEntity asset) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(300, 300)),
      builder: (_, snap) {
        if (!snap.hasData) return Container(color: Colors.grey[200]);

        return GestureDetector(
          onTap: () async {
            if (!isMulti.value) {
              if (asset.type == AssetType.image) {
                // Chuyển sang chỉnh sửa ảnh
                File? imageFile = await asset.file;
                final editedFile = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MediaEditorPage(file: imageFile, isImage: true),
                  ),
                );
                if (editedFile != null) {
                  Navigator.pop(context, editedFile);
                }
              } else if (asset.type == AssetType.video) {
                // Chuyển sang chỉnh sửa video
                File? videoFile = await asset.file;
                final editedVideo = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MediaEditorPage(file: videoFile, isImage: false),
                  ),
                );
                Navigator.pop(context, editedVideo);
              }
              return;
            }

            // Nếu đang chọn nhiều
            final ids = selectedIds.value.toSet();
            if (!ids.contains(asset.id) && ids.length >= 5) {
              showCustomSnackBar(
                context,
                "Bạn chỉ có thể chọn tối đa 10 ảnh hoặc video",
                isError: true,
              );
              return;
            }
            ids.contains(asset.id) ? ids.remove(asset.id) : ids.add(asset.id);
            selectedIds.value = ids;
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.memory(snap.data!, fit: BoxFit.cover),
              ),
              Positioned(top: 6, right: 6, child: _checkbox(asset.id)),
              if (asset.type == AssetType.video)
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: _videoDuration(asset.videoDuration),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _videoDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, "0");
    final s = (d.inSeconds % 60).toString().padLeft(2, "0");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_arrow, color: Colors.white, size: 16),
          Text(
            "$m:$s",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(4),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: assets.length,
              itemBuilder: (_, i) => _assetItem(assets[i]),
            ),
    );
  }
}
