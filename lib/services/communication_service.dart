import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

typedef MessageCallback = void Function(String type, String content, bool isMe);

class CommunicationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? roomId;
  final String mySessionId = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(10000).toString();

  MessageCallback? onMessageReceived;
  Function()? onRoomReady;
  Function(String)? onError;
  Function()? onPeerDisconnected;
  Function(String)? onRoomCreated;

  // ── Oda Oluştur ────────────────────────────────────────────────────────────
  Future<void> createRoom() async {
    try {
      final roomRef = _db.collection('rooms').doc();
      roomId = roomRef.id;

      // 6 haneli kısa kod oluştur
      final shortCode = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();

      await roomRef.set({
        'shortCode': shortCode,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'waiting',
      });

      onRoomCreated?.call(shortCode);

      // Durum değişikliklerini dinle
      roomRef.snapshots().listen((snapshot) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data == null) return;

        if (data['status'] == 'connected') {
          onRoomReady?.call();
        }

        if (data['status'] == 'disconnected') {
          onPeerDisconnected?.call();
        }
      });

      _listenMessages(roomRef);
    } catch (e) {
      onError?.call('Oda oluşturulamadı: $e');
    }
  }

  // ── Odaya Katıl ────────────────────────────────────────────────────────────
  Future<void> joinRoom(String code) async {
    try {
      // Kod 6 haneli kısa bir ID; tam Firestore doc ID değil
      final query = await _db
          .collection('rooms')
          .where('shortCode', isEqualTo: code)
          .where('status', isEqualTo: 'waiting')
          .limit(1)
          .get();

      DocumentReference roomRef;
      if (query.docs.isEmpty) {
        // Direkt doc ID ile dene (eski yöntem için fallback)
        roomRef = _db.collection('rooms').doc(code);
        final doc = await roomRef.get();
        if (!doc.exists) {
          onError?.call('Oda bulunamadı. Kodu kontrol edin.');
          return;
        }
      } else {
        roomRef = query.docs.first.reference;
      }

      roomId = roomRef.id;

      await roomRef.update({
        'status': 'connected',
      });

      onRoomReady?.call();

      // Durum değişikliklerini dinle (örneğin kurucu çıkarsa)
      roomRef.snapshots().listen((snapshot) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data == null) return;

        if (data['status'] == 'disconnected') {
          onPeerDisconnected?.call();
        }
      });

      _listenMessages(roomRef);
    } catch (e) {
      onError?.call('Odaya katılınamadı: $e');
    }
  }

  // ── Mesaj Gönder/Al ────────────────────────────────────────────────────────
  void sendMessage(String type, String content) {
    if (roomId == null) return;
    _db.collection('rooms').doc(roomId).collection('messages').add({
      'type': type,
      'content': content,
      'senderId': mySessionId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _listenMessages(DocumentReference roomRef) {
    roomRef.collection('messages').orderBy('timestamp').snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          final isMe = data['senderId'] == mySessionId;
          onMessageReceived?.call(data['type'] ?? 'text', data['content'] ?? '', isMe);
        }
      }
    });
  }

  // ── Oda Kapat ──────────────────────────────────────────────────────────────
  Future<void> hangUp() async {
    if (roomId != null) {
      await _db
          .collection('rooms')
          .doc(roomId)
          .update({'status': 'disconnected'}).catchError((_) {});
    }

    roomId = null;
  }
}
