// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:smarty/model/message_data_model.dart';

// class MqttProvider with ChangeNotifier {
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
//   static const int _connectionTimeout = 60; // Increased timeout

//   MqttServerClient? _client;
//   MqttConnectionState _connectionState = MqttConnectionState.disconnected;
//   int _reconnectAttempts = 0;
//   bool _isConnecting = false;
//   Timer? _connectionTimer;

//   final List<MessageData> _receivedMessages = [];

//   List<MessageData> get receivedMessages =>
//       List.unmodifiable(_receivedMessages);
//   MqttConnectionState get connectionState => _connectionState;
//   bool get isConnected => _connectionState == MqttConnectionState.connected;

//   /// Kết nối tới MQTT Broker
//   Future<void> connect() async {
//     if (_isConnecting) {
//       debugPrint('🔄 Đang trong quá trình kết nối, vui lòng đợi...');
//       return;
//     }
//     if (_client != null && isConnected) {
//       debugPrint('✅ Đã kết nối tới MQTT broker rồi.');
//       return;
//     }

//     _isConnecting = true;

//     final clientId = 'flutter_mqtt_${DateTime.now().millisecondsSinceEpoch}';
//     _client = MqttServerClient(_host, clientId);
//     _setupClient();

//     try {
//       debugPrint('🌐 Đang kiểm tra domain $_host...');
//       final result = await InternetAddress.lookup(_host);
//       if (result.isEmpty)
//         throw SocketException('Không phân giải được tên miền $_host');
//       debugPrint('✅ Domain resolve thành công: ${result.first.address}');

//       // Setup timeout
//       _connectionTimer?.cancel();
//       _connectionTimer = Timer(Duration(seconds: _connectionTimeout), () {
//         if (_client!.connectionStatus!.state != MqttConnectionState.connected) {
//           debugPrint('❌ Kết nối quá timeout $_connectionTimeout giây.');
//           _handleConnectionError('Connection timeout');
//         }
//       });

//       debugPrint('🔗 Đang kết nối tới $_host:$_port...');
//       await _client!.connect();
//       debugPrint('📨 CONNECT message đã gửi');

//       if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
//         debugPrint('🎉 Kết nối MQTT thành công!');
//         _connectionState = MqttConnectionState.connected;
//         _reconnectAttempts = 0;
//         _subscribe();
//         _listenMessages();
//       } else {
//         throw Exception(
//             'Kết nối thất bại với trạng thái: ${_client!.connectionStatus!.state}');
//       }
//     } catch (e, stacktrace) {
//       debugPrint('❌ Lỗi khi kết nối: $e\n$stacktrace');
//       _handleConnectionError(e);
//     } finally {
//       _isConnecting = false;
//       notifyListeners();
//     }
//   }

//   /// Cấu hình client trước khi connect
//   void _setupClient() {
//     _client!
//       ..port = _port
//       ..logging(on: true)
//       ..keepAlivePeriod = _keepAlivePeriod
//       ..secure = true
//       ..setProtocolV311()
//       ..securityContext = SecurityContext.defaultContext
//       ..onBadCertificate = (dynamic cert) {
//         debugPrint('⚠️ Certificate không hợp lệ: $cert');
//         return true;
//       }
//       ..onConnected = _onConnected
//       ..onDisconnected = _onDisconnected
//       ..onSubscribed = _onSubscribed;

//     final connMessage = MqttConnectMessage()
//         .withClientIdentifier(
//             'flutter_mqtt_${DateTime.now().millisecondsSinceEpoch}')
//         .authenticateAs(_username, _password)
//         .withWillQos(MqttQos.atLeastOnce)
//         .withProtocolVersion(4)
//         .startClean()
//         .withWillRetain();

//     _client!.connectionMessage = connMessage;
//   }

//   /// Đăng ký topic
//   void _subscribe() {
//     _client!.subscribe(_subTopic, MqttQos.atLeastOnce);
//     debugPrint('📡 Đã đăng ký topic: $_subTopic');
//   }

//   /// Lắng nghe các message từ broker
//   void _listenMessages() {
//     _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? event) {
//       if (event == null || event.isEmpty) return;

//       final recMess = event.first.payload as MqttPublishMessage;
//       final payload =
//           MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
//       debugPrint('📥 Nhận message: $payload');

//       try {
//         final jsonData = json.decode(payload);
//         final message = MessageData.fromJson(jsonData);
//         _receivedMessages.add(message);
//         notifyListeners();
//       } catch (e) {
//         debugPrint('❌ Parse lỗi: $e');
//       }
//     });
//   }

//   /// Gửi message
//   void publishMessage(String message) {
//     if (!isConnected) {
//       debugPrint('⚠️ Không thể gửi, client chưa kết nối.');
//       return;
//     }
//     final builder = MqttClientPayloadBuilder();
//     builder.addString(message);
//     _client!.publishMessage(_pubTopic, MqttQos.atLeastOnce, builder.payload!);
//     debugPrint('📤 Đã gửi message: $message');
//   }

//   /// Callback khi kết nối thành công
//   void _onConnected() {
//     debugPrint('✅ Client đã kết nối tới broker.');
//     _connectionState = MqttConnectionState.connected;
//     notifyListeners();
//   }

//   /// Callback khi mất kết nối
//   void _onDisconnected() {
//     debugPrint('🔌 Client bị ngắt kết nối.');
//     _connectionState = MqttConnectionState.disconnected;
//     notifyListeners();
//   }

//   /// Callback khi subscribe thành công
//   void _onSubscribed(String topic) {
//     debugPrint('📡 Đã đăng ký topic thành công: $topic');
//   }

//   /// Xử lý lỗi kết nối và reconnect
//   void _handleConnectionError(dynamic error) {
//     debugPrint('❌ Lỗi kết nối: $error');
//     _connectionState = MqttConnectionState.disconnected;
//     _client?.disconnect();
//     _connectionTimer?.cancel();

//     if (_reconnectAttempts < _maxReconnectAttempts) {
//       _reconnectAttempts++;
//       final delay = Duration(seconds: _reconnectDelay * _reconnectAttempts);
//       debugPrint(
//           '🔄 Thử reconnect lần $_reconnectAttempts sau ${delay.inSeconds} giây...');
//       Future.delayed(delay, connect);
//     } else {
//       debugPrint(
//           '❌ Đã vượt quá số lần reconnect tối đa ($_maxReconnectAttempts)');
//     }
//   }

//   /// Ngắt kết nối
//   void disconnect() {
//     debugPrint('🔌 Đang ngắt kết nối...');
//     _client?.disconnect();
//     _connectionState = MqttConnectionState.disconnected;
//     notifyListeners();
//   }

//   /// Hủy timer và disconnect khi dispose provider
//   @override
//   void dispose() {
//     _connectionTimer?.cancel();
//     disconnect();
//     super.dispose();
//   }
// }
