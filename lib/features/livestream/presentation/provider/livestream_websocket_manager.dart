import 'dart:convert';
import 'dart:developer' as developer;

import 'package:eefood/core/constants/app_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../../../core/di/injection.dart';

typedef UnsubscribeFn = void Function({
  Map<String, String>? unsubscribeHeaders,
});

class LiveStreamWebSocketManager {
  final SharedPreferences prefs = getIt<SharedPreferences>();

  StompClient? _stompClient;
  bool _isConnecting = false;

  final Map<String, UnsubscribeFn> _subscriptions = {};
  final List<void Function()> _pendingOnConnected = [];

  bool get isConnected => _stompClient?.connected == true;

  void connect({
    required String logName,
    void Function(String error)? onError,
    void Function()? onConnected,
  }) {
    if (isConnected) {
      developer.log('WebSocket already connected', name: logName);
      onConnected?.call();
      return;
    }

    if (_isConnecting) {
      developer.log('WebSocket is connecting...', name: logName);
      if (onConnected != null) {
        _pendingOnConnected.add(onConnected);
      }
      return;
    }

    final token = prefs.getString(AppKeys.accessToken) ?? '';
    if (token.isEmpty) {
      onError?.call('Access token is empty');
      return;
    }

    _isConnecting = true;
    if (onConnected != null) {
      _pendingOnConnected.add(onConnected);
    }

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: '${AppKeys.baseUrl}/ws-reaction?token=$token',
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        onConnect: (frame) {
          _isConnecting = false;
          developer.log('WebSocket connected', name: logName);
          final callbacks = List<void Function()>.from(_pendingOnConnected);
          _pendingOnConnected.clear();
          for (final callback in callbacks) {
            callback();
          }
        },
        onWebSocketError: (err) {
          _isConnecting = false;
          _pendingOnConnected.clear();
          developer.log('WS error: $err', name: logName);
          onError?.call('WebSocket error: $err');
        },
        onStompError: (frame) {
          developer.log('STOMP error: ${frame.body}', name: logName);
          onError?.call('STOMP error: ${frame.body}');
        },
        onDisconnect: (frame) {
          _isConnecting = false;
          _pendingOnConnected.clear();
          developer.log('WebSocket disconnected', name: logName);
        },
      ),
    );

    _stompClient?.activate();
  }

  void subscribeTopic<T>({
    required int liveStreamId,
    required String topic,
    required T Function(Map<String, dynamic>) fromJson,
    required void Function(T) onData,
    required String logName,
    required String logPrefix,
    void Function(String error)? onError,
  }) {
    if (!isConnected) {
      developer.log('Cannot subscribe, WebSocket not connected', name: logName);
      return;
    }

    final destination = '/topic/$topic/$liveStreamId';

    if (_subscriptions.containsKey(destination)) {
      developer.log('Already subscribed: $destination', name: logName);
      return;
    }

    final unsubscribe = _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body == null) return;

        try {
          final json = jsonDecode(frame.body!);
          final data = fromJson(Map<String, dynamic>.from(json));
          developer.log('Received $logPrefix from $destination', name: logName);
          onData(data);
        } catch (e) {
          developer.log('Error parsing $logPrefix: $e', name: logName);
          onError?.call('Error parsing $logPrefix: $e');
        }
      },
    );

    _subscriptions[destination] = unsubscribe;
    developer.log('Subscribed to: $destination', name: logName);
  }

  void subscribeUserQueue<T>({
    required String queue,
    required T Function(Map<String, dynamic>) fromJson,
    required void Function(T) onData,
    required String logName,
    required String logPrefix,
    void Function(String error)? onError,
  }) {
    if (!isConnected) {
      developer.log('Cannot subscribe user queue, WebSocket not connected', name: logName);
      return;
    }

    final destination = '/user/queue/$queue';

    if (_subscriptions.containsKey(destination)) {
      developer.log('Already subscribed user queue: $destination', name: logName);
      return;
    }

    final unsubscribe = _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body == null) return;

        try {
          final json = jsonDecode(frame.body!);
          final data = fromJson(Map<String, dynamic>.from(json));
          developer.log('Received USER $logPrefix from $destination', name: logName);
          onData(data);
        } catch (e) {
          developer.log('Error parsing USER $logPrefix: $e', name: logName);
          onError?.call('Error parsing USER $logPrefix: $e');
        }
      },
    );

    _subscriptions[destination] = unsubscribe;
    developer.log('Subscribed USER queue: $destination', name: logName);
  }

  void unsubscribeTopic({
    required int liveStreamId,
    required String topic,
    required String logName,
  }) {
    final destination = '/topic/$topic/$liveStreamId';
    final unsubscribe = _subscriptions.remove(destination);

    if (unsubscribe != null) {
      unsubscribe();
      developer.log('Unsubscribed: $destination', name: logName);
    }
  }

  void unsubscribeUserQueue({
    required String queue,
    required String logName,
  }) {
    final destination = '/user/queue/$queue';
    final unsubscribe = _subscriptions.remove(destination);

    if (unsubscribe != null) {
      unsubscribe();
      developer.log('Unsubscribed USER queue: $destination', name: logName);
    }
  }

  void clearSubscriptions({required String logName}) {
    for (final entry in _subscriptions.entries) {
      entry.value();
      developer.log('Unsubscribed: ${entry.key}', name: logName);
    }
    _subscriptions.clear();
  }

  void disconnect({required String logName}) {
    developer.log('Disconnecting WebSocket...', name: logName);
    clearSubscriptions(logName: logName);
    _stompClient?.deactivate();
    _stompClient = null;
    _isConnecting = false;
  }
}
