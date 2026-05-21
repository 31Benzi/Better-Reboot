import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart';
import 'package:reboot_common/common.dart';
import 'package:reboot_launcher/main.dart';
import 'package:reboot_launcher/src/messenger/info_bar.dart';
import 'package:reboot_launcher/src/page/settings_page.dart';
import 'package:reboot_launcher/src/util/translations.dart';
import 'package:path/path.dart' as path;
import 'package:reboot_launcher/src/controller/game_controller.dart';
import 'package:reboot_launcher/src/controller/hosting_controller.dart';

// TODO: Refactor me
class DllController extends GetxController {
  static const String storageName = "v3_dll_storage";

  late final GetStorage? _storage;
  late final TextEditingController customGameServerDll;
  late final TextEditingController unrealEngineConsoleDll;
  late final TextEditingController backendDll;
  late final TextEditingController memoryLeakDll;
  late final TextEditingController gameServerPort;
  late final Map<GameDll, StreamSubscription?> _subscriptions;

  DllController() {
    _storage = appWithNoStorage ? null : GetStorage(storageName);
    customGameServerDll = _createController("game_server", GameDll.gameServer);
    unrealEngineConsoleDll = _createController("unreal_engine_console", GameDll.console);
    backendDll = _createController("backend", GameDll.auth);
    memoryLeakDll = _createController("memory_leak", GameDll.memoryLeak);
    gameServerPort = TextEditingController(text: _storage?.read("game_server_port") ?? kDefaultGameServerPort);
    gameServerPort.addListener(() => _storage?.write("game_server_port", gameServerPort.text));
    _subscriptions = {};
  }

  TextEditingController _createController(String key, GameDll dll) {
    final controller = TextEditingController(text: _storage?.read(key) ?? getDefaultDllPath(dll));
    controller.addListener(() => _storage?.write(key, controller.text));
    return controller;
  }

  void resetGame() {
    customGameServerDll.text = getDefaultDllPath(GameDll.gameServer);
    unrealEngineConsoleDll.text = getDefaultDllPath(GameDll.console);
    backendDll.text = getDefaultDllPath(GameDll.auth);
  }

  void resetServer() {
    gameServerPort.text = kDefaultGameServerPort;
    customGameServerDll.text = getDefaultDllPath(GameDll.gameServer);
    download(GameDll.gameServer, customGameServerDll.text, force: true);
  }

  (File, bool) getInjectableData(String version, GameDll dll) {
    final defaultPath = canonicalize(getDefaultDllPath(dll));
    switch(dll){
      case GameDll.gameServer:
        final gameServerFile = File(customGameServerDll.text);
        return (gameServerFile, canonicalize(gameServerFile.path) != defaultPath);
      case GameDll.console:
        final ue4ConsoleFile = File(unrealEngineConsoleDll.text);
        return (ue4ConsoleFile, canonicalize(ue4ConsoleFile.path) != defaultPath);
      case GameDll.auth:
        final backendFile = File(backendDll.text);
        return (backendFile, canonicalize(backendFile.path) != defaultPath);
      case GameDll.memoryLeak:
        final memoryFile = File(memoryLeakDll.text);
        return (memoryFile, canonicalize(memoryFile.path) != defaultPath);
    }
  }

  TextEditingController getDllEditingController(GameDll dll) {
    switch(dll) {
      case GameDll.console:
        return unrealEngineConsoleDll;
      case GameDll.auth:
        return backendDll;
      case GameDll.gameServer:
        return customGameServerDll;
      case GameDll.memoryLeak:
        return memoryLeakDll;
    }
  }

  String getDefaultDllPath(GameDll dll) {
    switch(dll) {
      case GameDll.console:
        return "${dllsDirectory.path}\\console.dll";
      case GameDll.auth:
        return "${dllsDirectory.path}\\sinum.dll";
      case GameDll.gameServer:
        return "${dllsDirectory.path}\\reboot.dll";
      case GameDll.memoryLeak:
        return "${dllsDirectory.path}\\memory.dll";
    }
  }

  Future<bool> download(GameDll dll, String filePath, {bool silent = false, bool force = false}) async {
    log("[DLL] Asking for $dll at $filePath(silent: $silent, force: $force)");
    InfoBarEntry? entry;
    try {
      if (dll == GameDll.gameServer) {
        if(!force && File(filePath).existsSync()) {
          log("[DLL] $dll already exists");
          _listenToFileEvents(dll);
          return true;
        }

        log("[DLL] Downloading $dll...");
        final fileNameWithoutExtension = basenameWithoutExtension(filePath);
        if(!silent) {
          entry = showRebootInfoBar(
              translations.downloadingDll(fileNameWithoutExtension),
              loading: true,
              duration: null
          );
        }
        final result = await downloadRebootDll(File(filePath), kRebootBelowS20DownloadUrl, false);
        if(!result) {
          entry?.close();
          showRebootInfoBar(
              translations.downloadDllAntivirus(antiVirusName ?? defaultAntiVirusName, dll.name),
              duration: infoBarLongDuration,
              severity: InfoBarSeverity.error
          );
          return false;
        }
        entry?.close();
        if(!silent) {
          entry = await showRebootInfoBar(
              translations.downloadDllSuccess(fileNameWithoutExtension),
              severity: InfoBarSeverity.success,
              duration: infoBarShortDuration
          );
        }
        _listenToFileEvents(dll);
        return true;
      }

      if(!force && File(filePath).existsSync()) {
        log("[DLL] $dll already exists");
        _listenToFileEvents(dll);
        return true;
      }

      log("[DLL] Downloading $dll...");
      final fileNameWithoutExtension = basenameWithoutExtension(filePath);
      if(!silent) {
        log("[DLL] Showing dialog while downloading $dll...");
        entry = showRebootInfoBar(
            translations.downloadingDll(fileNameWithoutExtension),
            loading: true,
            duration: null
        );
      }else {
        log("[DLL] Not showing dialog while downloading $dll...");
      }
      final result = await downloadDependency(dll, filePath);
      if(!result) {
        entry?.close();
        showRebootInfoBar(
            translations.downloadDllAntivirus(antiVirusName ?? defaultAntiVirusName, dll.name),
            duration: infoBarLongDuration,
            severity: InfoBarSeverity.error
        );
        return false;
      }
      log("[DLL] Downloaded $dll");
      entry?.close();
      if(!silent) {
        log("[DLL] Showing success dialog for $dll");
        entry = await showRebootInfoBar(
            translations.downloadDllSuccess(fileNameWithoutExtension),
            severity: InfoBarSeverity.success,
            duration: infoBarShortDuration
        );
      }else {
        log("[DLL] Not showing success dialog for $dll");
      }
      _listenToFileEvents(dll);
      return true;
    }catch(message) {
      log("[DLL] An error occurred while downloading $dll: $message");
      entry?.close();
      var error = message.toString();
      error = error.contains(": ") ? error.substring(error.indexOf(": ") + 2) : error;
      error = error.toLowerCase();
      final completer = Completer<bool>();
      await showRebootInfoBar(
          translations.downloadDllError(error.toString(), dll.name),
          duration: infoBarLongDuration,
          severity: InfoBarSeverity.error,
          onDismissed: () => completer.complete(false),
          action: Button(
            onPressed: () async {
              final result = await download(dll, filePath, silent: silent, force: force);
              completer.complete(result);
            },
            child: Text(translations.downloadDllRetry),
          )
      );
      return completer.future;
    }
  }

  Future<void> downloadAndGuardDependencies() async {
    for(final injectable in GameDll.values) {
      final controller = getDllEditingController(injectable);
      final defaultPath = getDefaultDllPath(injectable);

      if(path.equals(controller.text, defaultPath)) {
        await download(injectable, controller.text);
      }
    }
  }

  void _listenToFileEvents(GameDll injectable) {
    final controller = getDllEditingController(injectable);
    final defaultPath = getDefaultDllPath(injectable);

    void onFileEvent(FileSystemEvent event, String filePath) {
      if (!path.equals(event.path, filePath)) {
        return;
      }

      if(path.equals(filePath, defaultPath)) {
        Get.find<GameController>()
            .instance
            .value
            ?.kill();
        Get.find<HostingController>()
            .instance
            .value
            ?.kill();
        showRebootInfoBar(
            translations.downloadDllAntivirus(antiVirusName ?? defaultAntiVirusName, injectable.name),
            duration: infoBarLongDuration,
            severity: InfoBarSeverity.error
        );
      }

      _updateInput(injectable);
    }

    StreamSubscription subscribe(String filePath) => File(filePath)
        .parent
        .watch(events: FileSystemEvent.delete | FileSystemEvent.move)
        .listen((event) => onFileEvent(event, filePath));

    controller.addListener(() {
      _subscriptions[injectable]?.cancel();
      _subscriptions[injectable] = subscribe(controller.text);
    });
    _subscriptions[injectable] = subscribe(controller.text);
  }

  void _updateInput(GameDll injectable) {
    switch(injectable) {
      case GameDll.console:
        settingsConsoleDllInputKey.currentState?.validate();
        break;
      case GameDll.auth:
        settingsAuthDllInputKey.currentState?.validate();
        break;
      case GameDll.gameServer:
        settingsGameServerDllInputKey.currentState?.validate();
        break;
      case GameDll.memoryLeak:
        settingsMemoryDllInputKey.currentState?.validate();
        break;
    }
  }
}