import 'package:equatable/equatable.dart';

abstract class MqttEvent extends Equatable {
  const MqttEvent();

  @override
  List<Object?> get props => [];
}

class MqttConnectRequested extends MqttEvent {
  const MqttConnectRequested();
}

class MqttDisconnectRequested extends MqttEvent {
  const MqttDisconnectRequested();
}

class MqttPublishMessage extends MqttEvent {
  final String message;

  const MqttPublishMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class MqttReceiveMessage extends MqttEvent {
  final String message;

  const MqttReceiveMessage(this.message);

  @override
  List<Object?> get props => [message];
}
