import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao_crontab_app/caibao_crontab_app.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CrontabApiAdapter implements CrontabApi {
  @override
  Future<List<CronJob>> listJobs() async {
    return await api<ApiService>((r) => r.listCronJobs()) ?? [];
  }

  @override
  Future<CronJob> createJob(CronJob draft) async {
    return await api<ApiService>((r) => r.createCronJob(draft));
  }

  @override
  Future<CronJob> updateJob(String id, CronJob draft) async {
    return await api<ApiService>((r) => r.updateCronJob(id, draft));
  }

  @override
  Future<void> deleteJob(String id) async {
    await api<ApiService>((r) => r.deleteCronJob(id));
  }

  @override
  Future<CronRunStatus> runJob(String id) async {
    return await api<ApiService>((r) => r.runCronJob(id));
  }

  @override
  Future<List<CronJobRun>> listRuns(String id) async {
    return await api<ApiService>((r) => r.listCronJobRuns(id)) ?? [];
  }
}
