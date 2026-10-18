/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Website: https://localwala.tech
 * Email: weworklocal1@gmail.com
 *
 * Proprietary and Confidential.
 *
 * WeWorkLocal is a technology platform that connects
 * customers, vendors, service providers, and delivery
 * partners through a unified digital ecosystem.
 *
 * Core features include local commerce, food delivery,
 * service bookings, referral programs, wallet management,
 * real-time tracking, digital payments, and business
 * management solutions.
 *
 * This source code, including all associated assets,
 * APIs, databases, business logic, designs, and
 * documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution,
 * publication, resale, reverse engineering, or use of
 * this software without prior written authorization is
 * strictly prohibited.
 */

import 'package:socket_io_client/socket_io_client.dart' as socketclient;
import 'package:user/app/env.dart';

class ChatService {
  socketclient.Socket? _socket;
  String? _joinedRoom;

  bool get isConnected => _socket?.connected ?? false;

  /// Connect, authenticate and join [chatRoomId].
  ///
  /// [authToken] is required: the server authenticates every socket in
  /// `io.use()` and rejects an unauthenticated handshake outright.
  ///
  /// Switching rooms is explicit — the previous implementation returned early
  /// when the socket was already connected, so opening a second ticket left the
  /// app listening in the FIRST ticket's room and never received a message for
  /// the ticket actually on screen.
  void connectToServer(String chatRoomId, String authToken, Function(dynamic data) onMessage) {
    if (authToken.isEmpty) {
      // Fail loudly rather than connect a socket that will be rejected.
      return;
    }

    if (_socket != null && _socket!.connected) {
      _switchRoom(chatRoomId, onMessage);
      return;
    }

    _socket?.dispose();

    _socket = socketclient.io(
      Environments.apiBaseURL,
      socketclient.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': authToken})
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      _socket!.emit('joinRoom', {'chatRoomId': _joinedRoom ?? chatRoomId});
      _socket!.on('receiveMessage', onMessage);
      if (_typingHandler != null) {
        _socket!.on('typing', _typingHandler!);
      }
      if (_readHandler != null) {
        _socket!.on('messageRead', _readHandler!);
      }
    });

    // A dropped socket re-joins on reconnect. Without this the user silently
    // stops receiving messages after a network blip.
    _socket!.onReconnect((_) {
      if (_joinedRoom != null) {
        _socket!.emit('joinRoom', {'chatRoomId': _joinedRoom});
      }
    });

    _joinedRoom = chatRoomId;
    _socket!.connect();
  }

  void _switchRoom(String chatRoomId, Function(dynamic data) onMessage) {
    if (_joinedRoom == chatRoomId) return;
    if (_joinedRoom != null) {
      _socket!.emit('leaveRoom', {'chatRoomId': _joinedRoom});
    }
    _socket!.off('receiveMessage');
    _socket!.off('typing');
    _socket!.off('messageRead');
    _socket!.off('messageFailed');
    _joinedRoom = chatRoomId;
    _socket!.emit('joinRoom', {'chatRoomId': chatRoomId});
    _socket!.on('receiveMessage', onMessage);
    if (_typingHandler != null) {
      _socket!.on('typing', _typingHandler!);
    }
    if (_readHandler != null) {
      _socket!.on('messageRead', _readHandler!);
    }
    if (_failedHandler != null) {
      _socket!.on('messageFailed', _failedHandler!);
    }
  }

  Function(dynamic data)? _typingHandler;
  Function(dynamic data)? _readHandler;
  Function(dynamic data)? _failedHandler;

  /// Subscribes to the other party's typing indicator. Replaces any previous
  /// handler — the view calls this once per room, and a stale handler would
  /// paint typing state for the wrong ticket.
  void onTyping(Function(dynamic data) handler) {
    _typingHandler = handler;
    if (_socket != null && _socket!.connected) {
      _socket!.off('typing');
      _socket!.on('typing', handler);
    }
  }

  /// Subscribes to read receipts (agent saw your messages). Same
  /// replace-on-room semantics as typing: one ticket at a time.
  void onMessageRead(Function(dynamic data) handler) {
    _readHandler = handler;
    if (_socket != null && _socket!.connected) {
      _socket!.off('messageRead');
      _socket!.on('messageRead', handler);
    }
  }

  /// Subscribes to server-reported send failures. Same replace-on-room
  /// semantics as typing/read receipts.
  void onMessageFailed(Function(dynamic data) handler) {
    _failedHandler = handler;
    if (_socket != null && _socket!.connected) {
      _socket!.off('messageFailed');
      _socket!.on('messageFailed', handler);
    }
  }

  void sendTyping(String chatRoomId, bool isTyping) {
    if (_socket == null || !_socket!.connected) return;
    _socket!.emit('typing', {'chatRoomId': chatRoomId, 'isTyping': isTyping});
  }

  void sendMessageRead(String chatRoomId, String upToMessageId) {
    if (_socket == null || !_socket!.connected) return;
    _socket!.emit('messageRead', {
      'chatRoomId': chatRoomId,
      'upToMessageId': upToMessageId,
    });
  }

  /// Send message safely. Returns whether the socket accepted the send; callers
  /// fall back to REST only when this is false, so one logical message is
  /// never persisted by both transports.
  bool sendMessage({required String chatRoomId, required String senderId, required String message, required String role, required String randomId, String? firstName, String? lastName, required String cover}) {
    if (_socket == null || !_socket!.connected) return false;

    _socket!.emit('sendMessage', {'chatRoomId': chatRoomId, 'senderId': senderId, 'message': message, 'role': role, 'randomId': randomId, 'senderFirstName': firstName, 'senderLastName': lastName, 'senderCover': cover});
    return true;
  }

  /// Disconnect safely
  void disconnect() {
    if (_socket != null) {
      if (_joinedRoom != null) {
        _socket!.emit('leaveRoom', {'chatRoomId': _joinedRoom});
      }
      _socket!.off('receiveMessage');
      _socket!.off('typing');
      _socket!.off('messageRead');
      _socket!.off('messageFailed');
      _typingHandler = null;
      _readHandler = null;
      _failedHandler = null;
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _joinedRoom = null;
    }
  }
}