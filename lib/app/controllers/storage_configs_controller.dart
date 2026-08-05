import 'package:caibao/app/controllers/controller.dart';
import 'package:caibao/app/models/storage_config.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';

class StorageConfigsController extends Controller {
  List<S3StorageConfig> items = [];
  bool loading = true;

  Future<void> refresh() async {
    setState(setState: () => loading = true);
    try {
      final result = await api<ApiService>((r) => r.listStorageConfigs());
      setState(setState: () => items = result ?? []);
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      setState(setState: () => loading = false);
    }
  }

  Future<S3StorageConfig?> fetchConfig(String id) async {
    try {
      return await api<ApiService>((r) => r.getStorageConfig(id));
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
      return null;
    } catch (e) {
      showToastSorry(description: e.toString());
      return null;
    }
  }

  Future<bool> saveConfig({
    S3StorageConfig? editing,
    required Map<String, dynamic> body,
  }) async {
    try {
      if (editing == null) {
        await api<ApiService>((r) => r.createStorageConfig(body));
      } else {
        await api<ApiService>(
          (r) => r.updateStorageConfig(editing.id!, body),
        );
      }
      await refresh();
      return true;
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
      return false;
    } catch (e) {
      showToastSorry(description: e.toString());
      return false;
    }
  }

  Future<void> enable(S3StorageConfig item) async {
    if (item.id == null) return;
    try {
      await api<ApiService>((r) => r.enableStorageConfig(item.id!));
      await refresh();
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }

  Future<void> deleteConfig(S3StorageConfig item) async {
    if (item.id == null) return;
    try {
      await api<ApiService>((r) => r.deleteStorageConfig(item.id!));
      await refresh();
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }
}
