import 'package:caibao/app/controllers/controller.dart';
import 'package:caibao/app/models/llm_model.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LlmModelsController extends Controller {
  static const List<String> categories = [
    'text',
    'vision',
    'multimodal',
    'embedding',
    'rerank',
    'image',
    'asr',
    'tts',
    'audio',
    'video',
    'code',
    'moderation',
    'reasoning',
  ];

  List<LlmModel> items = [];
  bool loading = true;

  Future<void> refresh() async {
    setState(setState: () => loading = true);
    try {
      final result = await api<ApiService>((r) => r.listLlmModels());
      setState(setState: () => items = result ?? []);
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      setState(setState: () => loading = false);
    }
  }

  Future<LlmModel?> fetchModel(String id) async {
    try {
      return await api<ApiService>((r) => r.getLlmModel(id));
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
      return null;
    } catch (e) {
      showToastSorry(description: e.toString());
      return null;
    }
  }

  Future<bool> saveModel({
    LlmModel? editing,
    required Map<String, dynamic> body,
  }) async {
    try {
      if (editing == null) {
        await api<ApiService>((r) => r.createLlmModel(body));
      } else {
        await api<ApiService>((r) => r.updateLlmModel(editing.id!, body));
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

  Future<void> enable(LlmModel item) async {
    if (item.id == null) return;
    try {
      await api<ApiService>((r) => r.enableLlmModel(item.id!));
      await refresh();
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }

  Future<void> deleteModel(LlmModel item) async {
    if (item.id == null) return;
    try {
      await api<ApiService>((r) => r.deleteLlmModel(item.id!));
      await refresh();
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }
}
