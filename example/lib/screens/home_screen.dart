// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:smarty/bloc/mqtt/mqtt_bloc.dart';
// import 'package:smarty/bloc/mqtt/mqtt_event.dart';
// import 'package:smarty/bloc/mqtt/mqtt_state.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<MqttBloc>().add(const MqttConnectRequested());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Smarty IoT'),
//         actions: [
//           BlocBuilder<MqttBloc, MqttState>(
//             builder: (context, state) {
//               if (state is MqttConnected) {
//                 return IconButton(
//                   icon: const Icon(Icons.link),
//                   onPressed: () {
//                     context
//                         .read<MqttBloc>()
//                         .add(const MqttDisconnectRequested());
//                   },
//                 );
//               }
//               return IconButton(
//                 icon: const Icon(Icons.link_off),
//                 onPressed: () {
//                   context.read<MqttBloc>().add(const MqttConnectRequested());
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: BlocBuilder<MqttBloc, MqttState>(
//         builder: (context, state) {
//           if (state is MqttInitial) {
//             return const Center(child: Text('Khởi tạo...'));
//           }

//           if (state is MqttConnecting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (state is MqttError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('Lỗi: ${state.message}'),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       context
//                           .read<MqttBloc>()
//                           .add(const MqttConnectRequested());
//                     },
//                     child: const Text('Thử lại'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (state is MqttConnected) {
//             return Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: state.messages.length,
//                     itemBuilder: (context, index) {
//                       final message = state.messages[index];
//                       return ListTile(
//                         title: Text(message.toString()),
//                         subtitle: Text('Topic: test/req'),
//                       );
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           decoration: const InputDecoration(
//                             hintText: 'Nhập message...',
//                             border: OutlineInputBorder(),
//                           ),
//                           onSubmitted: (message) {
//                             if (message.isNotEmpty) {
//                               context
//                                   .read<MqttBloc>()
//                                   .add(MqttMessagePublished(message));
//                             }
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       ElevatedButton(
//                         onPressed: () {
//                           context
//                               .read<MqttBloc>()
//                               .add(const MqttDisconnectRequested());
//                         },
//                         child: const Text('Ngắt kết nối'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           }

//           return const Center(child: Text('Không xác định trạng thái'));
//         },
//       ),
//     );
//   }
// }
