/*
 * WeWorkLocal
 * Hyperlocal Commerce & Delivery Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Website: https://localwala.tech
 * Email: weworklocal1@gmail.com
 *
 * Proprietary and Confidential.
 *
 * Unauthorized copying, distribution, publication, resale, reverse
 * engineering, or use of this software without prior written authorization is
 * strictly prohibited.
 */

import 'package:socket_io_client/socket_io_client.dart' as socketclient;
import 'package:user/app/env.dart';

typedef StoresDriverLocation = void Function(double latitude, double longitude);

/// An order or delivery lifecycle change for the tracked order.
typedef StoresOrderStatus = void Function(Map<String, dynamic> status);

/// Live driver location and lifecycle for one order.
///
/// The customer joins `store-order:<orderId>`, not the driver's user room. The
/// server checks that the authenticated customer owns the order before letting
/// the socket join, so an order id cannot be used to watch someone else's
/// delivery. The driver's location is fanned out by the server only for the
/// deliveries that driver is currently carrying.
class StoresTrackingSocket {
  socketclient.Socket? _socket;
  String? _orderId;

  void connect({
    required String orderId,
    required String authToken,
    required StoresDriverLocation onLocation,
    StoresOrderStatus? onStatus,
  }) {
    if (authToken.isEmpty || orderId.isEmpty) return;
    if (_socket != null && _socket!.connected && _orderId == orderId) return;

    _socket?.dispose();
    _orderId = orderId;

    _socket = socketclient.io(
      Environments.apiBaseURL,
      socketclient.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth(<String, String>{'token': authToken})
          .enableReconnection()
          .build(),
    );

    void join() => _socket!.emit('joinOrderTracking', <String, String>{
      'orderId': orderId,
    });

    _socket!.onConnect((_) => join());
    _socket!.onReconnect((_) => join());
    _socket!.on('orderLocation', (dynamic raw) {
      if (raw is! Map) return;
      final double? latitude = double.tryParse('${raw['latitude']}');
      final double? longitude = double.tryParse('${raw['longitude']}');
      if (latitude == null || longitude == null) return;
      onLocation(latitude, longitude);
    });

    void handleStatus(dynamic raw) {
      if (raw is! Map || onStatus == null) return;
      onStatus(Map<String, dynamic>.from(raw));
    }

    _socket!.on('orderStatus', handleStatus);
    _socket!.on('deliveryStatus', handleStatus);

    _socket!.connect();
  }

  void disconnect() {
    final socketclient.Socket? socket = _socket;
    if (socket == null) return;
    final String? orderId = _orderId;
    if (orderId != null) {
      socket.emit('leaveOrderTracking', <String, String>{'orderId': orderId});
    }
    socket.off('orderLocation');
    socket.off('orderStatus');
    socket.off('deliveryStatus');
    socket.disconnect();
    socket.dispose();
    _socket = null;
    _orderId = null;
  }
}
