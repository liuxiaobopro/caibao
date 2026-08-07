import 'dart:io';

import 'package:caibao/app/models/drive_file.dart';
import 'package:caibao/bootstrap/extensions.dart';
import 'package:caibao/resources/themes/tokens/app_radius.dart';
import 'package:caibao/resources/themes/tokens/app_spacing.dart';
import 'package:caibao/resources/themes/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:caibao/resources/themes/tokens/app_sizes.dart';

class MessageAttachments extends StatelessWidget {
  const MessageAttachments({
    super.key,
    required this.attachments,
    this.onUserBubble = false,
  });

  final List<DriveFile> attachments;
  final bool onUserBubble;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    final palette = context.palette;

    return Wrap(
      spacing: AppSpacing.x2,
      runSpacing: AppSpacing.x2,
      children: [
        for (final file in attachments)
          if (file.isImage)
            _ImageThumb(file: file)
          else
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x2,
                vertical: AppSpacing.x1,
              ),
              decoration: BoxDecoration(
                color: onUserBubble
                    ? palette.brandOn.withValues(alpha: 0.15)
                    : palette.secondary,
                borderRadius: AppRadius.smAll,
              ),
              child: Text(
                file.name ?? '文件',
                style: TextStyle(
                  fontSize: AppTypography.xs,
                  color: onUserBubble
                      ? palette.onUserBubble
                      : palette.foreground,
                ),
              ),
            ),
      ],
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.file});

  final DriveFile file;

  @override
  Widget build(BuildContext context) {
    final url = file.url?.trim() ?? '';
    final isLocal = url.isNotEmpty && !url.startsWith('http');

    Widget image;
    if (url.isEmpty) {
      image = ColoredBox(
        color: context.palette.muted,
        child: Icon(Icons.broken_image_outlined, color: context.palette.mutedForeground),
      );
    } else if (isLocal) {
      image = Image.file(File(url), fit: BoxFit.cover);
    } else {
      image = Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => ColoredBox(
          color: context.palette.muted,
          child: Icon(
            Icons.broken_image_outlined,
            color: context.palette.mutedForeground,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: url.isEmpty
          ? null
          : () {
              showDialog<void>(
                context: context,
                builder: (ctx) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(AppSpacing.x4),
                  child: InteractiveViewer(
                    child: isLocal
                        ? Image.file(File(url))
                        : Image.network(url),
                  ),
                ),
              );
            },
      child: ClipRRect(
        borderRadius: AppRadius.smAll,
        child: SizedBox(width: AppSizes.previewThumb, height: AppSizes.previewThumb, child: image),
      ),
    );
  }
}
