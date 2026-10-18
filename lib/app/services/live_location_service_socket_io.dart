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

class LiveLocationServiceSocket {
  socketclient.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  /// [authToken] is required. The server authenticates every socket in
  /// `io.use()` before any event handler runs, so an unauthenticated handshake
  /// is rejected outright and live tracking silently stops working. It also
  /// closes a hole where any client could subscribe to any driver's location
  /// by guessing the id.
  void connectToServer(String driverId, String authToken, Function(dynamic data) onLocation) {
    if (authToken.isEmpty) return;
    if (_socket != null && _socket!.connected) return;

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
      _socket!.emit('joinLiveLocation', {'driverId': driverId});
      _socket!.on('receiveLocation', onLocation);
    });

    // Re-join after a network drop, or tracking stays dead until the app is
    // restarted.
    _socket!.onReconnect((_) {
      _socket!.emit('joinLiveLocation', {'driverId': driverId});
    });

    _socket!.connect();
  }

  void sendLocation(String driverId, double latitude, double longitude) {
    if (_socket == null || !_socket!.connected) return;

    _socket!.emit('sendLocation', {'driverId': driverId, 'latitude': latitude, 'longitude': longitude});
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.off('receiveLocation');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }
}

