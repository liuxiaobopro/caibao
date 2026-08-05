import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:caibao/app/networking/api_service.dart';
import 'package:caibao/config/app.dart';
import 'package:caibao/config/storage_keys.dart';
import 'package:nylo_framework/nylo_framework.dart';

class Analytics {
  Analytics._();

  static final Analytics instance = Analytics._();

  static const int _maxBatch = 50;
  static const int _flushAt = 10;

  final List<Map<String, dynamic>> _queue = [];
  Timer? _timer;
  String? _deviceId;
  bool _flushing = false;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    final stored = await NyStorage.read(StorageKeysConfig.deviceId);
    final id = stored?.toString();
    if (id != null && id.isNotEmpty) {
      _deviceId = id;
    } else {
      _deviceId = _newDeviceId();
      await NyStorage.save(StorageKeysConfig.deviceId, _deviceId!);
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      unawaited(flush());
    });
    _ready = true;
  }

  void track(
    String event, {
    String? page,
    Map<String, dynamic>? props,
  }) {
    final name = event.trim();
    if (name.isEmpty) return;

    _queue.add({
      'event': name,
      if (page != null && page.isNotEmpty) 'page': page,
      if (props != null && props.isNotEmpty) 'props': props,
      'platform': Platform.operatingSystem,
      'app_version': AppConfig.version,
      if (_deviceId != null && _deviceId!.isNotEmpty) 'device_id': _deviceId,
      'client_ts': DateTime.now().toUtc().toIso8601String(),
    });

    if (_queue.length >= _flushAt) {
      unawaited(flush());
    }
  }

  void pageView(String page) {
    final p = page.trim();
    if (p.isEmpty) return;
    track('page_view', page: p);
  }

  Future<void> flush() async {
    if (_flushing || _queue.isEmpty) return;
    if (!await Auth.isAuthenticated()) return;

    _flushing = true;
    final batch = _queue.take(_maxBatch).toList();
    try {
      await api<ApiService>((r) => r.trackEvents(batch));
      _queue.removeRange(0, batch.length);
    } catch (_) {
      // 静默失败，下次再试
    } finally {
      _flushing = false;
    }
  }

  void clear() {
    _queue.clear();
  }

  String _newDeviceId() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
