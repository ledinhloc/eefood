// core/services/livestream_websocket_manager.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:eefood/core/constants/app_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../../../core/di/injection.dart';

class LiveStreamWebSocketManager {
  final SharedPreferences prefs = getIt<SharedPreferences>();
  final int liveStreamId;
  final String logName;

  StompClient? _stompClient;

  final void Function(String error)? onError;
  final void Function()? onConnected;

  LiveStreamWebSocketManager({
    required this.liveStreamId,
    required this.logName,
    this.onError,
    this.onConnected,
  });

  bool get isConnected => _stompClient?.connected == true;

  void connect() {
    if (isConnected) {
      developer.log('Already connected to stream $liveStreamId', name: logName);
      return;
    }

    final token = prefs.getString(AppKeys.accessToken) ?? '';

    developer.log('Connecting to WebSocket for stream $liveStreamId', name: logName);

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: '${AppKeys.baseUrl}/ws-reaction?token=$token',
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        onConnect: _onConnectedInternal,
        onWebSocketError: (err) {
          developer.log('WS error: $err', name: logName);
          onError?.call('WebSocket error: $err');
        },
        onStompError: (frame) {
          developer.log('STOMP error: ${frame.body}', name: logName);
        },
        onDisconnect: (frame) {
          developer.log('Disconnected from stream $liveStreamId', name: logName);
        },
      ),
    );

    _stompClient!.activate();
  }

  void _onConnectedInternal(StompFrame frame) {
    developer.log('[WebSocket] Connected to stream $liveStreamId', name: logName);
    onConnected?.call();
  }

  void subscribe<T>({
    required String topic,
    required T Function(Map<String, dynamic>) fromJson,
    required void Function(T) onData,
    required String logPrefix,
  }) {
    final destination = '/topic/$topic/$liveStreamId';

    _stompClient?.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final json = jsonDecode(frame.body!);
            final data = fromJson(Map<String, dynamic>.from(json));

            developer.log('Received $logPrefix', name: logName);
            onData(data);
          } catch (e) {
            developer.log('Error parsing $logPrefix: $e', name: logName);
            onError?.call('Error parsing $logPrefix: $e');
          }
        }
      },
    );

    developer.log('Subscribed to: $destination', name: logName);
  }

  void subscribeUserQueue<T>({
    required String queue,
    required T Function(Map<String, dynamic>) fromJson,
    required void Function(T) onData,
    required String logPrefix,
  }) {

    final destination = '/user/queue/$queue';

    _stompClient?.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final json = jsonDecode(frame.body!);
            final data = fromJson(Map<String, dynamic>.from(json));

            developer.log('Received USER $logPrefix', name: logName);

            onData(data);
          } catch (e) {
            developer.log('Error parsing USER $logPrefix: $e', name: logName);
            onError?.call('Error parsing USER $logPrefix: $e');
          }
        }
      },
    );

    developer.log('Subscribed to USER queue: $destination', name: logName);
  }

  void disconnect() {
    developer.log('Disconnecting from stream $liveStreamId', name: logName);
    _stompClient?.deactivate();
  }
}