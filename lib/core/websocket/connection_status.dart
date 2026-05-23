sealed class ConnectionStatus {
  const ConnectionStatus();
}

class ConnectionConnecting extends ConnectionStatus {
  const ConnectionConnecting();
}

class ConnectionConnected extends ConnectionStatus {
  final String serverUrl;
  const ConnectionConnected(this.serverUrl);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionConnected &&
          runtimeType == other.runtimeType &&
          serverUrl == other.serverUrl;

  @override
  int get hashCode => serverUrl.hashCode;
}

class ConnectionDisconnected extends ConnectionStatus {
  const ConnectionDisconnected();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionDisconnected && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
