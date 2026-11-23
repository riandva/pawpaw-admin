import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import '../api/admin_api.dart';
import '../config/constants.dart';
import '../models/admin_models.dart';
import '../views/widgets/app_notification.dart';

class AdminCustomerCareController extends GetxController {
  final AdminApi _api = AdminApi();

  final RxList<CustomerCareRoomModel> rooms = <CustomerCareRoomModel>[].obs;
  final Rxn<CustomerCareRoomModel> selectedRoom = Rxn<CustomerCareRoomModel>();
  final RxList<CustomerCareMessageModel> messages = <CustomerCareMessageModel>[].obs;
  final RxString selectedCategory = 'all'.obs; // 'all' | 'customer-care' | 'partner-support'

  final RxBool isLoadingRooms = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isConnected = false.obs;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  socket_io.Socket? _socket;
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    loadRooms();
    connectSocket();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      loadRooms(silent: true);
      if (selectedRoom.value != null) {
        loadMessages(selectedRoom.value!.id, silent: true);
      }
    });
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> connectSocket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey) ?? '';

      // Socket Server base URL
      final socketUri = AppConstants.baseUrl.replaceAll('/api/', '');

      _socket = socket_io.io(
        socketUri,
        socket_io.OptionBuilder()
            .setTransports(['websocket'])
            .setQuery({'token': token})
            .enableAutoConnect()
            .build(),
      );

      _socket!.onConnect((_) {
        isConnected.value = true;
        debugPrint('[AdminSocket] Connected to $socketUri');
      });

      _socket!.onDisconnect((_) {
        isConnected.value = false;
        debugPrint('[AdminSocket] Disconnected');
      });

      // Listen to broadcast event from backend for customer-care
      _socket!.on('customer-care-admin', (data) {
        if (data != null && data is Map) {
          final room = data['room']?.toString();
          if (room != null && selectedRoom.value?.id == room) {
            final msgJson = data['message'] as Map<String, dynamic>?;
            if (msgJson != null) {
              final newMsg = CustomerCareMessageModel.fromJson(msgJson);
              if (!messages.any((m) => m.id == newMsg.id)) {
                messages.insert(0, newMsg);
              }
            }
          }
          loadRooms(silent: true);
        }
      });
    } catch (e) {
      debugPrint('[AdminSocket] Connection error: $e');
    }
  }

  Future<void> loadRooms({bool silent = false}) async {
    if (!silent && rooms.isEmpty) {
      isLoadingRooms.value = true;
    }
    try {
      final list = await _api.getCustomerCareRooms(category: selectedCategory.value);
      rooms.value = list;
      if (selectedRoom.value == null && list.isNotEmpty) {
        selectRoom(list.first);
      }
    } finally {
      isLoadingRooms.value = false;
    }
  }

  void filterCategory(String cat) {
    if (selectedCategory.value != cat) {
      selectedCategory.value = cat;
      selectedRoom.value = null;
      messages.clear();
      loadRooms();
    }
  }

  Future<void> selectRoom(CustomerCareRoomModel room) async {
    selectedRoom.value = room;
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join_room', room.id);
      _socket!.on(room.id, (data) {
        if (data != null && data is Map<String, dynamic>) {
          final newMsg = CustomerCareMessageModel.fromJson(data);
          if (!messages.any((m) => m.id == newMsg.id)) {
            messages.insert(0, newMsg);
          }
        }
      });
    }
    await loadMessages(room.id);
  }

  Future<void> loadMessages(String roomId, {bool silent = false}) async {
    if (!silent && messages.isEmpty) {
      isLoadingMessages.value = true;
    }
    try {
      final list = await _api.getCustomerCareMessages(roomId);
      messages.value = list;
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty || selectedRoom.value == null) return;

    final roomId = selectedRoom.value!.id;
    textController.clear();
    isSending.value = true;

    try {
      final sent = await _api.sendCustomerCareMessage(roomId, text);
      if (sent != null) {
        if (!messages.any((m) => m.id == sent.id)) {
          messages.insert(0, sent);
        }
        // Update last message in room list
        final rIdx = rooms.indexWhere((r) => r.id == roomId);
        if (rIdx != -1) {
          final old = rooms[rIdx];
          rooms[rIdx] = CustomerCareRoomModel(
            id: old.id,
            userId: old.userId,
            userName: old.userName,
            userAvatar: old.userAvatar,
            lastMessage: text,
            lastMessageType: 'text',
            lastUpdated: DateTime.now(),
            unreadCount: 0,
          );
        }
      } else {
        AppNotification.showError(
          title: 'Gagal Mengirim',
          message: 'Pesan tidak dapat terkirim ke pelanggan.',
        );
      }
    } finally {
      isSending.value = false;
    }
  }
}
