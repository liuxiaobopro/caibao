import 'package:caibao/app/controllers/controller.dart';
import 'package:caibao/app/models/drive_file.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/app/utils/drive_file_helpers.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:url_launcher/url_launcher.dart';

class DriveController extends Controller {
  List<DriveFile> items = [];
  bool loading = true;

  Future<void> refresh() async {
    setState(setState: () => loading = true);
    try {
      final result = await api<ApiService>((r) => r.listFiles());
      setState(setState: () => items = result ?? []);
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      setState(setState: () => loading = false);
    }
  }

  Future<String> resolveFileUrl(DriveFile file) async {
    var url = resolveDriveUrl(file.url);
    if (url.isEmpty && file.id != null) {
      url = resolveDriveUrl(
        await api<ApiService>((r) => r.getFileURL(file.id!)),
      );
    }
    return url;
  }

  Future<void> openExternal(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      showToastSorry(description: '无法打开文件');
    }
  }

  Future<void> deleteFile(DriveFile file) async {
    if (file.id == null) return;
    try {
      await api<ApiService>((r) => r.deleteFile(file.id!));
      await refresh();
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }

  IconData iconFor(DriveFile file) => driveFileIcon(file);
}
