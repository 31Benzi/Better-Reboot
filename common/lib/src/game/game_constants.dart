import 'package:version/version.dart';

const String kDefaultPlayerName = "Player";
const String kDefaultHostName = "Host";
const String kDefaultGameServerHost = "127.0.0.1";
const String kDefaultGameServerPort = "7777";
const String kInitializedLine = "Game Engine Initialized";
const List<String> kLoggedInLines = [
  "[UOnlineAccountCommon::ContinueLoggingIn]",
  "(Completed)"
];
const String kShutdownLine = "FOnlineSubsystemGoogleCommon::Shutdown()";
const List<String> kCorruptedBuildErrors = [
  "Critical error",
  "when 0 bytes remain",
  "Pak chunk signature verification failed!",
  "LogWindows:Error: Fatal error!"
];
const List<String> kCannotConnectErrors = [
  "port 3551 failed: Connection refused",
  "Unable to login to Fortnite servers",
  "HTTP 400 response from ",
  "Network failure when attempting to check platform restrictions",
  "UOnlineAccountCommon::ForceLogout"
];
const String kGameFinishedLine = "TeamsLeft: 1";
const String kDisplayLine = "Display";
const String kDisplayInitializedLine = "Initialized";
const String kShippingExe = "FortniteClient-Win64-Shipping.exe";
const String kLauncherExe = "FortniteLauncher.exe";
const String kEacExe = "FortniteClient-Win64-Shipping_EAC.exe";
const String kEacEosExe = "FortniteClient-Win64-Shipping_EAC_EOS.exe";
const String kCrashReportExe = "CrashReportClient.exe";
const String kGFSDKAftermathLibDll = "GFSDK_Aftermath_Lib.dll";
const String kCalderaEac = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50X2lkIjoiYmU5ZGE1YzJmYmVhNDQwN2IyZjQwZWJhYWQ4NTlhZDQiLCJnZW5lcmF0ZWQiOjE2Mzg3MTcyNzgsImNhbGRlcmFHdWlkIjoiMzgxMGI4NjMtMmE2NS00NDU3LTliNTgtNGRhYjNiNDgyYTg2IiwiYWNQcm92aWRlciI6IkVhc3lBbnRpQ2hlYXQiLCJub3RlcyI6IiIsImZhbGxiYWNrIjpmYWxzZX0.VAWQB67RTxhiWOxx7DBjnzDnXyyEnX7OljJm-j2d88G_WgwQ9wrE6lwMEHZHjBd1ISJdUO1UVUqkfLdU5nofBQ";
const String kCalderaEacEos = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50X2lkIjoic2FyYWgiLCJnZW5lcmF0ZWQiOjE3NzQxMjEzNzksImNhbGRlcmFHdWlkIjoiZWYzMGE4MjUtMzFlNi00ZWRhLTlmM2EtZTI4YzgwNjYxODkxIiwiYWNQcm92aWRlciI6IkVhc3lBbnRpQ2hlYXRFT1MiLCJub3RlcyI6IiIsImZhbGxiYWNrIjpmYWxzZX0.f7EcDmsjj3XHzdbMl41YHyJE-LlAirjbjaqzcdqBB_Y";
final Version kMaxAllowedVersion = Version.parse("99.99");
