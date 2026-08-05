import 'package:caibao/app/models/drive_file.dart';
import 'package:flutter/material.dart';

String formatDriveFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String formatDriveFileTime(DateTime? at) {
  if (at == null) return '';
  final local = at.toLocal();
  return '${local.month}/${local.day} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

String resolveDriveUrl(String? url) {
  final raw = url?.trim() ?? '';
  if (raw.isEmpty) return '';
  if (raw.startsWith('http://') ||
      raw.startsWith('https://') ||
      raw.startsWith('blob:')) {
    return raw;
  }
  return 'https://$raw';
}

IconData driveFileIcon(DriveFile file) {
  if (file.isImage) return Icons.image_outlined;
  final name = file.name ?? '';
  if (RegExp(r'\.(xlsx?|csv)$', caseSensitive: false).hasMatch(name)) {
    return Icons.table_chart_outlined;
  }
  if (RegExp(r'\.(pdf|docx?|txt|md)$', caseSensitive: false).hasMatch(name)) {
    return Icons.description_outlined;
  }
  return Icons.insert_drive_file_outlined;
}
