import 'dart:async';
import 'dart:io';

import 'package:discord_rich_presence/discord_rich_presence.dart';
import 'package:get/get.dart';
import 'package:reboot_common/common.dart';
import 'package:reboot_launcher/src/config/discord_rpc_config.dart';
import 'package:reboot_launcher/src/controller/game_controller.dart';
import 'package:reboot_launcher/src/controller/hosting_controller.dart';
import 'package:reboot_launcher/src/controller/settings_controller.dart';
import 'package:reboot_launcher/src/page/pages.dart';
import 'package:reboot_launcher/src/pager/page_type.dart';

class DiscordRpcService extends GetxService {
  static const String _appName = 'Better Reboot';
  static const Duration _presenceRefreshInterval = Duration(seconds: 5);

  Client? _client;
  bool _connected = false;
  DateTime? _presenceStart;
  String? _lastPresenceKey;
  Timer? _presenceRefreshTimer;
  final List<Worker> _workers = [];

  static DiscordRpcService? get optional =>
      Get.isRegistered<DiscordRpcService>() ? Get.find<DiscordRpcService>() : null;

  Future<void> init() async {
    if (!Platform.isWindows || !isDiscordRpcConfigured) {
      return;
    }

    final settings = Get.find<SettingsController>();
    _workers.addAll([
      ever(settings.discordRichPresence, (_) => _onEnabledChanged()),
      ever(pageIndex, (_) => syncPresence()),
      ever(Get.find<GameController>().started, (_) => syncPresence()),
      ever(Get.find<HostingController>().started, (_) => syncPresence()),
      ever(Get.find<GameController>().instance, (_) => syncPresence()),
      ever(Get.find<HostingController>().instance, (_) => syncPresence()),
    ]);

    if (settings.discordRichPresence.value) {
      await _connect();
      await syncPresence();
    }
  }

  Future<void> _onEnabledChanged() async {
    final enabled = Get.find<SettingsController>().discordRichPresence.value;
    if (enabled) {
      await _connect();
      await syncPresence();
    } else {
      await _disconnect();
    }
  }

  Future<void> _connect() async {
    if (_connected || !Get.find<SettingsController>().discordRichPresence.value) {
      return;
    }

    try {
      _client ??= Client(clientId: kDiscordApplicationId);
      await _client!.connect();
      _connected = true;
      _startPresenceRefreshTimer();
      log("[DISCORD] Rich Presence connected");
    } catch (error) {
      _connected = false;
      log("[DISCORD] Rich Presence unavailable: $error");
    }
  }

  Future<void> _disconnect() async {
    if (!_connected) {
      return;
    }

    try {
      await _client?.disconnect();
    } catch (error) {
      log("[DISCORD] Disconnect error: $error");
    } finally {
      _stopPresenceRefreshTimer();
      _connected = false;
      _lastPresenceKey = null;
      _presenceStart = null;
    }
  }

  void _startPresenceRefreshTimer() {
    _stopPresenceRefreshTimer();
    _presenceRefreshTimer = Timer.periodic(
      _presenceRefreshInterval,
      (_) => unawaited(syncPresence(force: true)),
    );
  }

  void _stopPresenceRefreshTimer() {
    _presenceRefreshTimer?.cancel();
    _presenceRefreshTimer = null;
  }

  Future<void> syncPresence({bool force = false}) async {
    if (!Platform.isWindows ||
        !isDiscordRpcConfigured ||
        !Get.find<SettingsController>().discordRichPresence.value) {
      return;
    }

    if (!_connected) {
      await _connect();
    }
    if (!_connected || _client == null) {
      return;
    }

    final presence = _buildPresence();
    final key = presence.key;
    if (!force && key == _lastPresenceKey) {
      return;
    }

    if (_lastPresenceKey == null || _presenceKind(key) != _presenceKind(_lastPresenceKey!)) {
      _presenceStart = DateTime.now();
    }
    _lastPresenceKey = key;

    try {
      await _client!.setActivity(
        Activity(
          name: _appName,
          details: presence.details,
          type: ActivityType.playing,
          timestamps: ActivityTimestamps(start: _presenceStart),
          assets: const ActivityAssets(
            largeImage: kDiscordLargeImageKey,
            largeText: _appName,
          ),
        ),
      );
    } catch (error) {
      _connected = false;
      log("[DISCORD] Failed to update presence: $error");
    }
  }

  Future<void> shutdown() async {
    _stopPresenceRefreshTimer();
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    await _disconnect();
  }

  _PresenceData _buildPresence() {
    final game = Get.find<GameController>();
    final host = Get.find<HostingController>();
    final tab = _currentTabName();
    final playingVersion = _playingVersion(game, host);

    if (playingVersion != null) {
      return _PresenceData(
        key: 'playing:$playingVersion',
        details: 'Playing $playingVersion',
      );
    }

    return _PresenceData(
      key: 'tab:$tab',
      details: 'In $tab',
    );
  }

  String? _playingVersion(GameController game, HostingController host) {
    final gameInstance = game.instance.value;
    final hostInstance = host.instance.value;

    if (game.started.value && gameInstance?.launched == true) {
      return _normalizeVersion(gameInstance!.version);
    }
    if (host.started.value && hostInstance?.launched == true) {
      return _normalizeVersion(hostInstance!.version);
    }
    return null;
  }

  String? _normalizeVersion(String? version) {
    if (version == null || version.isEmpty) {
      return null;
    }
    return version;
  }

  String _currentTabName() {
    switch (PageType.values[pageIndex.value]) {
      case PageType.play:
        return 'Play';
      case PageType.host:
        return 'Host';
      case PageType.backend:
        return 'Backend';
      case PageType.info:
        return 'Info';
      case PageType.settings:
        return 'Settings';
    }
  }

  String _presenceKind(String key) => key.split(':').first;
}

class _PresenceData {
  final String key;
  final String details;

  const _PresenceData({
    required this.key,
    required this.details,
  });
}
