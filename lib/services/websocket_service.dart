import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  
  // Merkezi Sunucu IP Adresi
  final String serverUrl = 'ws://127.0.0.1:8765';

  bool get isConnected => _channel != null;

  /// Sunucuya bağlanır ve WebSocket kanalını açar.
  Future<void> connect() async {
    try {
      if (_channel != null) return;
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      await _channel!.ready;
      debugPrint('✅ WebSocketService: Bağlandı -> $serverUrl');
    } catch (e) {
      debugPrint('❌ WebSocketService: Bağlantı hatası -> $e');
      rethrow;
    }
  }

  /// Sunucudan gelen JSON yanıtlarını dinlemek için Stream döner.
  Stream<dynamic> get stream {
    if (_channel == null) {
      return const Stream.empty();
    }
    return _channel!.stream.map((message) => jsonDecode(message));
  }

  /// Kameradan gelen ham YUV karelerini sunucuya gönderir.
  void sendFrame(List<int> bytes) {
    if (_channel != null) {
      try {
        _channel!.sink.add(bytes);
      } catch (e) {
        debugPrint('❌ WebSocketService: Frame gönderim hatası -> $e');
      }
    }
  }

  /// Bağlantıyı kapatır.
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    debugPrint('🗑️ WebSocketService: Bağlantı kapatıldı.');
  }
}
