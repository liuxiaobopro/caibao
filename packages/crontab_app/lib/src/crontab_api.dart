import 'models.dart';

abstract class CrontabApi {
  Future<List<CronJob>> listJobs();

  Future<CronJob> createJob(CronJob draft);

  Future<CronJob> updateJob(String id, CronJob draft);

  Future<void> deleteJob(String id);

  Future<CronRunStatus> runJob(String id);

  Future<List<CronJobRun>> listRuns(String id);
}
