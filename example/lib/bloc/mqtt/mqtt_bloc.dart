// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:typed_data/typed_buffers.dart';

// import 'package:flutter/foundation.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mqtt5_client/mqtt5_client.dart';
// import 'package:mqtt5_client/mqtt5_server_client.dart';

// import 'package:smarty/bloc/mqtt/mqtt_event.dart' as events;
// import 'package:smarty/bloc/mqtt/mqtt_state.dart';
// import 'package:smarty/model/message_data_model.dart';

// class MqttBloc extends Bloc<events.MqttEvent, MqttState> {
//   // MQTT Config
//   static const String _host =
//       '91f23c134c8849b5939188b245411169.s1.eu.hivemq.cloud';
//   static const int _port = 8883;
//   static const String _username = 'nguyenquan';
//   static const String _password = '!@#QWEasdzxc123';
//   static const String _pubTopic = 'test/req';
//   static const String _subTopic = 'test/req';

//   // Connection config
//   static const int _keepAlivePeriod = 60;
//   static const int _reconnectDelay = 5;
//   static const int _maxReconnectAttempts = 3;
//   static const int _connectionTimeout = 60;
//   static const int _messageRetryCount = 3;
//   static const int _messageRetryDelay = 2;

//   MqttServerClient? _client;
//   int _reconnectAttempts = 0;
//   Timer? _connectionTimer;
//   StreamSubscription? _mqttSubscription;
//   bool _isConnecting = false;
//   final Map<String, int> _messageRetryMap = {};

//   MqttBloc() : super(const MqttInitial()) {
//     on<events.MqttConnectRequested>(_onConnectRequested);
//     on<events.MqttDisconnectRequested>(_onDisconnectRequested);
//     on<events.MqttPublishMessage>(_onMessagePublished);
//     on<events.MqttReceiveMessage>(_onMessageReceived);
//   }

//   Future<void> _onConnectRequested(
//       events.MqttConnectRequested event, Emitter<MqttState> emit) async {
//     if (_isConnecting) {
//       debugPrint('🔄 Đang trong quá trình kết nối, vui lòng đợi...');
//       return;
//     }

//     if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
//       debugPrint('✅ Đã kết nối tới MQTT broker rồi.');
//       return;
//     }

//     _isConnecting = true;
//     emit(const MqttConnecting());

//     try {
//       final clientId = 'flutter_mqtt_${DateTime.now().millisecondsSinceEpoch}';
//       _client = MqttServerClient(_host, clientId);
//       _setupClient();

//       debugPrint('🌐 Đang kiểm tra domain $_host...');
//       final result = await InternetAddress.lookup(_host);
//       if (result.isEmpty) {
//         throw SocketException('Không phân giải được tên miền $_host');
//       }
//       debugPrint('✅ Domain resolve thành công: ${result.first.address}');

//       _connectionTimer?.cancel();
//       _connectionTimer = Timer(Duration(seconds: _connectionTimeout), () {
//         if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
//           debugPrint('❌ Kết nối quá timeout $_connectionTimeout giây.');
//           _handleConnectionError('Connection timeout');
//         }
//       });

//       debugPrint('🔗 Đang kết nối tới $_host:$_port...');
//       await _client!.connect();
//       debugPrint('📨 CONNECT message đã gửi');

//       if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
//         debugPrint('🎉 Kết nối MQTT thành công!');
//         _reconnectAttempts = 0;
//         _subscribe();
//         _listenMessages();
//         emit(MqttConnected(
//           connectionState: MqttConnectionState.connected,
//           messages: const [],
//         ));
//       } else {
//         throw Exception(
//             'Kết nối thất bại với trạng thái: ${_client!.connectionStatus!.state}');
//       }
//     } catch (e, stacktrace) {
//       debugPrint('❌ Lỗi khi kết nối: $e\n$stacktrace');
//       _handleConnectionError(e);
//       emit(MqttError(e.toString()));
//     } finally {
//       _isConnecting = false;
//     }
//   }

//   void _setupClient() {
//     _client!
//       ..port = _port
//       ..logging(on: true)
//       ..keepAlivePeriod = _keepAlivePeriod
//       ..secure = true
//       ..securityContext = SecurityContext.defaultContext
//       ..onBadCertificate = (dynamic cert) {
//         debugPrint('⚠️ Certificate không hợp lệ: $cert');
//         return true;
//       }
//       ..onConnected = () {
//         debugPrint('✅ Client đã kết nối tới broker.');
//       }
//       ..onDisconnected = () {
//         debugPrint('🔌 Client bị ngắt kết nối.');
//         if (!_isConnecting) {
//           add(const events.MqttDisconnectRequested());
//         }
//       }
//       ..onSubscribed = (String topic, SubscribeReasonCode reasonCode) {
//         debugPrint('📡 Đã đăng ký topic thành công: $topic, lý do: $reasonCode');
//       };

//     final connMessage = MqttConnectMessage()
//         .withClientIdentifier(
//             'flutter_mqtt_${DateTime.now().millisecondsSinceEpoch}')
//         .authenticateAs(_username, _password)
//         .withWillQos(MqttQos.atLeastOnce)
//         .startClean();

//     _client!.connectionMessage = connMessage;
//   }

//   void _subscribe() {
//     try {
//       _client!.subscribe(_subTopic, MqttQos.atLeastOnce);
//       debugPrint('📡 Đã đăng ký topic: $_subTopic');
//     } catch (e) {
//       debugPrint('❌ Lỗi khi đăng ký topic: $e');
//       _handleConnectionError(e);
//     }
//   }

//   void _listenMessages() {
//     _mqttSubscription?.cancel();
//     _mqttSubscription = _client!.updates
//         ?.listen((List<MqttReceivedMessage<MqttMessage?>>? event) {
//       if (event == null || event.isEmpty) return;

//       final recMess = event.first.payload as MqttPublishMessage;
//       final payload = utf8.decode(recMess.payload.message?.toList() ?? []);
//       debugPrint('📥 Nhận message: $payload');

//       try {
//         json.decode(payload); // check parse trước
//         add(events.MqttReceiveMessage(payload));
//       } catch (e) {
//         debugPrint('❌ Parse lỗi: $e');
//       }
//     });
//   }

//   void _onDisconnectRequested(
//       events.MqttDisconnectRequested event, Emitter<MqttState> emit) {
//     debugPrint('🔌 Đang ngắt kết nối...');
//     _mqttSubscription?.cancel();
//     _connectionTimer?.cancel();
//     _client?.disconnect();
//     _client = null;
//     _reconnectAttempts = 0;
//     _messageRetryMap.clear();
//     emit(const MqttDisconnected());
//   }

//   Future<void> _onMessagePublished(
//       events.MqttPublishMessage event, Emitter<MqttState> emit) async {
//     if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
//       debugPrint('⚠️ Không thể gửi, client chưa kết nối.');
//       return;
//     }

//     final messageId = DateTime.now().millisecondsSinceEpoch.toString();
//     _messageRetryMap[messageId] = 0;

//     await _publishWithRetry(event.message, messageId);
//   }

//   Future<void> _publishWithRetry(String message, String messageId) async {
//     try {
//       final payload = Uint8Buffer()..addAll(utf8.encode(message));
//       _client!.publishMessage(
//         _pubTopic,
//         MqttQos.atLeastOnce,
//         payload,
//       );
//       debugPrint('📤 Đã gửi message: $message');
//       _messageRetryMap.remove(messageId);
//     } catch (e) {
//       debugPrint('❌ Lỗi khi gửi message: $e');
//       final retryCount = _messageRetryMap[messageId] ?? 0;
//       if (retryCount < _messageRetryCount) {
//         _messageRetryMap[messageId] = retryCount + 1;
//         debugPrint(
//             '🔄 Thử gửi lại message lần ${retryCount + 1} sau $_messageRetryDelay giây...');
//         await Future.delayed(Duration(seconds: _messageRetryDelay));
//         await _publishWithRetry(message, messageId);
//       } else {
//         debugPrint(
//             '❌ Đã vượt quá số lần thử gửi lại tối đa ($_messageRetryCount)');
//         _messageRetryMap.remove(messageId);
//       }
//     }
//   }

//   void _onMessageReceived(
//       events.MqttReceiveMessage event, Emitter<MqttState> emit) {
//     if (state is MqttConnected) {
//       final currentState = state as MqttConnected;
//       try {
//         final jsonData = json.decode(event.message);
//         final message = MessageData.fromJson(jsonData);
//         final updatedMessages = List<MessageData>.from(currentState.messages)
//           ..add(message);
//         emit(currentState.copyWith(messages: updatedMessages));
//       } catch (e) {
//         debugPrint('❌ Parse lỗi: $e');
//       }
//     }
//   }

//   void _handleConnectionError(dynamic error) {
//     debugPrint('❌ Lỗi kết nối: $error');
//     _client?.disconnect();
//     _connectionTimer?.cancel();

//     if (_reconnectAttempts < _maxReconnectAttempts) {
//       _reconnectAttempts++;
//       final delay = Duration(seconds: _reconnectDelay * _reconnectAttempts);
//       debugPrint(
//           '🔄 Thử reconnect lần $_reconnectAttempts sau ${delay.inSeconds} giây...');
//       Future.delayed(delay, () {
//         if (!_isConnecting) {
//           add(const events.MqttConnectRequested());
//         }
//       });
//     } else {
//       debugPrint(
//           '❌ Đã vượt quá số lần reconnect tối đa ($_maxReconnectAttempts)');
//     }
//   }

//   @override
//   Future<void> close() {
//     _mqttSubscription?.cancel();
//     _connectionTimer?.cancel();
//     _client?.disconnect();
//     _messageRetryMap.clear();
//     return super.close();
//   }
// }
