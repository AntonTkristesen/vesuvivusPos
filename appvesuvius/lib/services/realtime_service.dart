import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../models/order.dart';

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  PusherChannelsFlutter? pusher;
  final Set<String> _subscribedChannels = {};

  Future<void> init() async {
    if (pusher != null) return;
    pusher = PusherChannelsFlutter.getInstance();
    await pusher!.init(
      apiKey: '79d18163499cc5509379',
      cluster: 'eu',
      onError: (String message, int? code, dynamic e) {
        if (kDebugMode) print('Pusher error: $message');
      },
      useTLS: true
    );
    await pusher!.connect();
  }

  void subscribeToUserOrders(int userId, Function(List<OrderModel>) callback) {
    final channelName = 'orders.$userId';
    if (pusher == null || _subscribedChannels.contains(channelName)) return;

    pusher!.subscribe(
  channelName: channelName,
  onEvent: (event) {
    final e = event as PusherEvent;

    if (kDebugMode) {
      print('Raw Pusher event: ${e.toString()}');
      print('Event name: ${e.eventName}');
      print('Event data: ${e.data}');
    }

    if (e.eventName == 'OrdersUpdated' && e.data != null) {
      try {
        final dataMap = json.decode(e.data.toString()) as Map<String, dynamic>;
        if (kDebugMode) print('Decoded JSON: $dataMap');

        final orders = (dataMap['orders'] as List)
            .map((x) => OrderModel.fromJson(x as Map<String, dynamic>))
            .toList();
        callback(orders);
      } catch (err) {
        if (kDebugMode) print('Error parsing orders: $err');
      }
    }
  },
);


    _subscribedChannels.add(channelName);
  }

  void unsubscribeFromUserOrders(int userId) {
    final channelName = 'orders.$userId';
    if (!_subscribedChannels.contains(channelName)) return;
    pusher?.unsubscribe(channelName: channelName);
    _subscribedChannels.remove(channelName);
  }

  void disconnect() {
    pusher?.disconnect();
    pusher = null;
    _subscribedChannels.clear();
  }
}
