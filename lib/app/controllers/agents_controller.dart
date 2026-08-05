import 'package:caibao/app/controllers/controller.dart';
import 'package:caibao/app/models/agent.dart';
import 'package:caibao/app/networking/api_exception.dart';
import 'package:caibao/app/networking/api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AgentsController extends Controller {
  List<Agent> items = [];
  bool loading = true;
  String tab = 'system';

  List<Agent> get filtered => items.where((a) => a.scope == tab).toList();

  void setTab(String value) {
    setState(setState: () => tab = value);
  }

  Future<void> refresh() async {
    setState(setState: () => loading = true);
    try {
      final result = await api<ApiService>((r) => r.listAgents());
      setState(setState: () => items = result ?? []);
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    } finally {
      setState(setState: () => loading = false);
    }
  }

  Future<Agent?> fetchAgent(String id) async {
    try {
      return await api<ApiService>((r) => r.getAgent(id));
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
      return null;
    } catch (e) {
      showToastSorry(description: e.toString());
      return null;
    }
  }

  Future<bool> saveAgent({
    Agent? editing,
    required String name,
    required String instruction,
    required String description,
  }) async {
    final trimmedName = name.trim();
    final trimmedInstruction = instruction.trim();
    if (trimmedName.isEmpty || trimmedInstruction.isEmpty) {
      showToastSorry(description: '请填写名称和指令');
      return false;
    }
    try {
      if (editing == null) {
        await api<ApiService>(
          (r) => r.createAgent(
            name: trimmedName,
            instruction: trimmedInstruction,
            description: description.trim(),
          ),
        );
      } else {
        await api<ApiService>(
          (r) => r.updateAgent(
            editing.id!,
            name: trimmedName,
            instruction: trimmedInstruction,
            description: description.trim(),
          ),
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

  Future<void> deleteAgent(Agent agent) async {
    if (agent.id == null) return;
    try {
      await api<ApiService>((r) => r.deleteAgent(agent.id!));
      await refresh();
    } on ApiException catch (e) {
      showToastSorry(description: e.message);
    } catch (e) {
      showToastSorry(description: e.toString());
    }
  }
}
