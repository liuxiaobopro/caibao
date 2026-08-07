import 'dart:io';

import 'package:caibao/app/models/drive_file.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_sizes.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nylo_framework/nylo_framework.dart';

typedef ChatComposerSubmit = void Function(
  String text, {
  List<String> fileIds,
  List<DriveFile> attachments,
});

enum _PendingStatus { uploading, done, error }

class _PendingAttachment {
  _PendingAttachment({
    required this.localId,
    required this.file,
    required this.filename,
    required this.contentType,
  });

  final String localId;
  final File file;
  final String filename;
  final String contentType;
  _PendingStatus status = _PendingStatus.uploading;
  DriveFile? item;
  String? error;
}

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    this.conversationId,
    this.onSubmit,
    this.enabled = true,
    this.allowAttachments = true,
  });

  final TextEditingController controller;
  final String? conversationId;
  final ChatComposerSubmit? onSubmit;
  final bool enabled;
  final bool allowAttachments;

  @override
  State<ChatComposer> createState() => ChatComposerState();
}

class ChatComposerState extends State<ChatComposer> {
  final ImagePicker _picker = ImagePicker();
  final List<_PendingAttachment> _attachments = [];
  int _localSeq = 0;

  void clearAttachments() {
    setState(() => _attachments.clear());
  }

  bool get _canSubmit {
    if (!widget.enabled || widget.onSubmit == null) return false;
    final hasText = widget.controller.text.trim().isNotEmpty;
    final ready = _attachments
        .where((a) => a.status == _PendingStatus.done && a.item?.id != null)
        .toList();
    final uploading =
        _attachments.any((a) => a.status == _PendingStatus.uploading);
    if (uploading) return false;
    return hasText || ready.isNotEmpty;
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickImages() async {
    if (!widget.enabled || !widget.allowAttachments) return;
    try {
      final files = await _picker.pickMultiImage(imageQuality: 85);
      if (files.isEmpty) return;
      for (final x in files) {
        final path = x.path;
        if (path.isEmpty) continue;
        final file = File(path);
        final size = await file.length();
        if (size <= 0) continue;
        final localId =
            'local-${DateTime.now().microsecondsSinceEpoch}-${_localSeq++}';
        final name = x.name.isNotEmpty
            ? x.name
            : path.split(Platform.pathSeparator).last;
        final mime = x.mimeType?.trim().isNotEmpty == true
            ? x.mimeType!
            : _guessContentType(name);
        final pending = _PendingAttachment(
          localId: localId,
          file: file,
          filename: name,
          contentType: mime,
        );
        setState(() => _attachments.add(pending));
        _uploadOne(pending);
      }
    } catch (e) {
      _toast(e.toString());
    }
  }

  String _guessContentType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.bmp')) return 'image/bmp';
    if (lower.endsWith('.svg')) return 'image/svg+xml';
    return 'image/jpeg';
  }

  Future<void> _uploadOne(_PendingAttachment pending) async {
    try {
      final item = await api<ApiService>(
        (r) => r.uploadFileDirect(
          file: pending.file,
          filename: pending.filename,
          contentType: pending.contentType,
          conversationId: widget.conversationId,
        ),
      );
      if (!mounted) return;
      setState(() {
        pending.status = _PendingStatus.done;
        pending.item = item;
        pending.error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        pending.status = _PendingStatus.error;
        pending.error = e.message;
      });
      _toast(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        pending.status = _PendingStatus.error;
        pending.error = e.toString();
      });
      _toast(e.toString());
    }
  }

  Future<void> _removeAttachment(_PendingAttachment pending) async {
    final id = pending.item?.id;
    setState(() => _attachments.removeWhere((a) => a.localId == pending.localId));
    if (id == null || id.isEmpty) return;
    try {
      await api<ApiService>((r) => r.deleteFile(id));
    } catch (_) {
      // ignore
    }
  }

  void _retry(_PendingAttachment pending) {
    setState(() {
      pending.status = _PendingStatus.uploading;
      pending.error = null;
    });
    _uploadOne(pending);
  }

  void _submit() {
    if (!_canSubmit || widget.onSubmit == null) return;
    final text = widget.controller.text;
    final done = _attachments
        .where((a) => a.status == _PendingStatus.done && a.item?.id != null)
        .toList();
    final fileIds = done.map((a) => a.item!.id!).toList();
    final attachments = done.map((a) {
      final item = a.item!;
      return DriveFile(
        id: item.id,
        storageConfigId: item.storageConfigId,
        storageConfigName: item.storageConfigName,
        conversationId: item.conversationId,
        name: item.name ?? a.filename,
        size: item.size,
        contentType: item.contentType ?? a.contentType,
        url: item.url?.isNotEmpty == true ? item.url : a.file.path,
        source: item.source,
      );
    }).toList();

    widget.onSubmit!(
      text,
      fileIds: fileIds,
      attachments: attachments,
    );
    setState(() => _attachments.clear());
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      color: palette.card,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x4,
        AppSpacing.x2,
        AppSpacing.x4,
        AppSpacing.x3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_attachments.isNotEmpty)
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _attachments.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = _attachments[index];
                  return _AttachmentChip(
                    attachment: item,
                    onRemove: () => _removeAttachment(item),
                    onRetry: () => _retry(item),
                  );
                },
              ),
            ),
          if (_attachments.isNotEmpty) const SizedBox(height: AppSpacing.x2),
          Container(
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              color: palette.secondary,
              borderRadius: AppRadius.fullAll,
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x1),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.enabled && widget.allowAttachments
                      ? _pickImages
                      : null,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    color: palette.foreground,
                    size: 22,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submit(),
                    onChanged: (_) => setState(() {}),
                    enabled: widget.enabled && widget.onSubmit != null,
                    style: TextStyle(
                      fontSize: 15,
                      color: palette.foreground,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: '发消息或按住说话',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: palette.mutedForeground,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.x3,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: palette.foreground,
                    size: 22,
                  ),
                ),
                ListenableBuilder(
                  listenable: widget.controller,
                  builder: (context, _) {
                    if (_canSubmit) {
                      return IconButton(
                        onPressed: _submit,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.send_rounded,
                          color: palette.userBubble,
                          size: AppSizes.iconXl,
                        ),
                      );
                    }
                    return IconButton(
                      onPressed: widget.enabled && widget.allowAttachments
                          ? _pickImages
                          : null,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: palette.foreground,
                        size: 24,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({
    required this.attachment,
    required this.onRemove,
    required this.onRetry,
  });

  final _PendingAttachment attachment;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  attachment.file,
                  fit: BoxFit.cover,
                ),
                if (attachment.status == _PendingStatus.uploading)
                  ColoredBox(
                    color: palette.foreground.withValues(alpha: 0.35),
                    child: const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                if (attachment.status == _PendingStatus.error)
                  ColoredBox(
                    color: palette.danger.withValues(alpha: 0.55),
                    child: Center(
                      child: IconButton(
                        onPressed: onRetry,
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: palette.brandOn,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: InkWell(
            onTap: onRemove,
            customBorder: const CircleBorder(),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: palette.foreground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 12,
                color: palette.background,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
