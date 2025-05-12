import 'package:equatable/equatable.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:smarty/model/message_data_model.dart';

abstract class MqttState extends Equatable {
  const MqttState();

  @override
  List<Object?> get props => [];
}

class MqttInitial extends MqttState {
  const MqttInitial();
}

class MqttConnecting extends MqttState {
  const MqttConnecting();
}

class MqttConnected extends MqttState {
  final MqttConnectionState connectionState;
  final List<MessageData> messages;

  const MqttConnected({
    required this.connectionState,
    this.messages = const [],
  });

  @override
  List<Object?> get props => [connectionState, messages];

  MqttConnected copyWith({
    MqttConnectionState? connectionState,
    List<MessageData>? messages,
  }) {
    return MqttConnected(
      connectionState: connectionState ?? this.connectionState,
      messages: messages ?? this.messages,
    );
  }
}

class MqttDisconnected extends MqttState {
  const MqttDisconnected();
}

class MqttError extends MqttState {
  final String message;

  const MqttError(this.message);

  @override
  List<Object?> get props => [message];
}
