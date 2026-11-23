import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../config/admin_theme.dart';
import '../../controllers/admin_customer_care_controller.dart';
import '../../models/admin_models.dart';

class CustomerCareView extends StatefulWidget {
  final String initialCategory; // 'customer-care' | 'partner-support' | 'all'

  const CustomerCareView({
    super.key,
    this.initialCategory = 'customer-care',
  });

  @override
  State<CustomerCareView> createState() => _CustomerCareViewState();
}

class _CustomerCareViewState extends State<CustomerCareView> {
  late final AdminCustomerCareController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AdminCustomerCareController>()
        ? Get.find<AdminCustomerCareController>()
        : Get.put(AdminCustomerCareController());

    if (controller.selectedCategory.value != widget.initialCategory) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.filterCategory(widget.initialCategory);
      });
    }
  }

  @override
  void didUpdateWidget(covariant CustomerCareView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory) {
      controller.filterCategory(widget.initialCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('HH:mm');
    final isPartnerMode = widget.initialCategory == 'partner-support';

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 650;
              final titleText = isPartnerMode
                  ? 'Live Chat Dukungan Mitra 🐾'
                  : 'Pusat Bantuan & Live Chat Pelanggan 👤';
              final subText = isPartnerMode
                  ? 'Komunikasi real-time dua arah dengan seluruh penyedia jasa & mitra PawPaw.'
                  : 'Komunikasi real-time dua arah dengan pengguna (pemilik anabul) aplikasi PawPaw.';

              final titleCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AdminTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subText,
                    style: const TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
                  ),
                ],
              );

              final statusBadge = Obx(() {
                final connected = controller.isConnected.value;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: connected ? AdminTheme.successLight : AdminTheme.warningLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: connected
                          ? AdminTheme.success.withValues(alpha: 0.3)
                          : AdminTheme.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: connected ? AdminTheme.success : AdminTheme.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        connected ? 'WebSocket Online' : 'Polling Sync Mode',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: connected ? AdminTheme.success : AdminTheme.warning,
                        ),
                      ),
                    ],
                  ),
                );
              });

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleCol,
                    const SizedBox(height: 12),
                    statusBadge,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleCol),
                  const SizedBox(width: 16),
                  statusBadge,
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Main Chat Layout (Split Pane: Room list on left, conversation on right)
          Expanded(
            child: Container(
              decoration: AdminTheme.cardDecoration(),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, chatConstraints) {
                  final isCompact = chatConstraints.maxWidth < 680;
                  final leftPaneWidth = isCompact ? 250.0 : 320.0;

                  return Row(
                    children: [
                      // Left Pane: Room List
                      SizedBox(
                        width: leftPaneWidth,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: AdminTheme.border)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isPartnerMode ? Icons.support_agent_rounded : Icons.chat_bubble_outline_rounded,
                                    color: AdminTheme.textPrimary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isPartnerMode ? 'Percakapan Mitra' : 'Percakapan Pelanggan',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
                                        color: AdminTheme.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Obx(() => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AdminTheme.background,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AdminTheme.border),
                                        ),
                                        child: Text(
                                          '${controller.rooms.length}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AdminTheme.textSecondary,
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                        Expanded(
                          child: Obx(() {
                            if (controller.isLoadingRooms.value && controller.rooms.isEmpty) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (controller.rooms.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.chat_bubble_outline_rounded,
                                          size: 40, color: AdminTheme.textMuted),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Belum ada percakapan pelanggan',
                                        style: TextStyle(
                                          color: AdminTheme.textMuted,
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              itemCount: controller.rooms.length,
                              separatorBuilder: (ctx, i) => const Divider(height: 1, color: AdminTheme.divider),
                              itemBuilder: (ctx, index) {
                                final room = controller.rooms[index];
                                final isSelected = controller.selectedRoom.value?.id == room.id;

                                return Material(
                                  color: isSelected
                                      ? AdminTheme.primaryLight.withValues(alpha: 0.5)
                                      : Colors.transparent,
                                  child: InkWell(
                                    onTap: () => controller.selectRoom(room),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: AdminTheme.primaryLight,
                                            backgroundImage: room.userAvatar != null
                                                ? NetworkImage(room.userAvatar!)
                                                : null,
                                            child: room.userAvatar == null
                                                ? Text(
                                                    room.userName.isNotEmpty
                                                        ? room.userName[0].toUpperCase()
                                                        : 'U',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      color: AdminTheme.brandDark,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              room.userName,
                                                              style: const TextStyle(
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: 13.5,
                                                                color: AdminTheme.textPrimary,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 6),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                            decoration: BoxDecoration(
                                                              color: room.isPartner ? AdminTheme.primarySubtle : AdminTheme.infoLight,
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                            child: Text(
                                                              room.isPartner ? 'Mitra' : 'User',
                                                              style: TextStyle(
                                                                fontSize: 9.5,
                                                                fontWeight: FontWeight.bold,
                                                                color: room.isPartner ? AdminTheme.brandDark : AdminTheme.info,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Text(
                                                      dateFormat.format(room.lastUpdated),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: AdminTheme.textMuted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  room.lastMessage?.isNotEmpty == true
                                                      ? room.lastMessage!
                                                      : 'Memulai percakapan',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isSelected
                                                        ? AdminTheme.brandDark
                                                        : AdminTheme.textSecondary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  const VerticalDivider(width: 1, color: AdminTheme.border),

                  // Right Pane: Active Conversation
                  Expanded(
                    child: Obx(() {
                      final activeRoom = controller.selectedRoom.value;
                      if (activeRoom == null) {
                        return const Center(
                          child: Text('Pilih percakapan dari daftar di sebelah kiri'),
                        );
                      }

                      return Column(
                        children: [
                          // Chat Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: AdminTheme.border)),
                              color: AdminTheme.surface,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AdminTheme.primaryLight,
                                  backgroundImage: activeRoom.userAvatar != null
                                      ? NetworkImage(activeRoom.userAvatar!)
                                      : null,
                                  child: activeRoom.userAvatar == null
                                      ? Text(
                                          activeRoom.userName.isNotEmpty
                                              ? activeRoom.userName[0].toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AdminTheme.brandDark,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          activeRoom.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AdminTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: activeRoom.isPartner ? AdminTheme.primarySubtle : AdminTheme.infoLight,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            activeRoom.isPartner ? 'Mitra Bisnis' : 'Customer',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: activeRoom.isPartner ? AdminTheme.brandDark : AdminTheme.info,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      activeRoom.isPartner ? 'Mitra Penyedia Jasa PawPaw' : 'Pengguna PawPaw Mobile',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: activeRoom.isPartner ? AdminTheme.primaryDark : AdminTheme.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Message List
                          Expanded(
                            child: Obx(() {
                              if (controller.isLoadingMessages.value && controller.messages.isEmpty) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              return Container(
                                color: AdminTheme.background,
                                child: ListView.builder(
                                  controller: controller.scrollController,
                                  reverse: true,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                  itemCount: controller.messages.length,
                                  itemBuilder: (ctx, index) {
                                    final msg = controller.messages[index];
                                    return _buildMessageBubble(msg, dateFormat);
                                  },
                                ),
                              );
                            }),
                          ),

                          // Input Bar
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: AdminTheme.surface,
                              border: Border(top: BorderSide(color: AdminTheme.border)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller.textController,
                                    decoration: InputDecoration(
                                      hintText: 'Ketik balasan untuk ${activeRoom.userName}...',
                                      filled: true,
                                      fillColor: AdminTheme.background,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: const BorderSide(color: AdminTheme.border),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: const BorderSide(color: AdminTheme.border),
                                      ),
                                    ),
                                    onSubmitted: (_) => controller.sendMessage(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Obx(() {
                                  return IconButton.filled(
                                    style: IconButton.styleFrom(
                                      backgroundColor: AdminTheme.brandDark,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.all(12),
                                    ),
                                    onPressed: controller.isSending.value
                                        ? null
                                        : () => controller.sendMessage(),
                                    icon: controller.isSending.value
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.send_rounded, size: 20),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ],
  ),
);
  }

  Widget _buildMessageBubble(CustomerCareMessageModel msg, DateFormat dateFormat) {
    final isAdmin = msg.isAdmin;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isAdmin) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: AdminTheme.primaryLight,
              child: Icon(Icons.person, size: 16, color: AdminTheme.brandDark),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isAdmin ? AdminTheme.brandDark : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isAdmin ? 16 : 4),
                  bottomRight: Radius.circular(isAdmin ? 4 : 16),
                ),
                border: Border.all(
                  color: isAdmin ? AdminTheme.brandDark : AdminTheme.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (msg.type == 'image') ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        msg.content,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ] else ...[
                    Text(
                      msg.content,
                      style: TextStyle(
                        color: isAdmin ? Colors.white : AdminTheme.textPrimary,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    dateFormat.format(msg.date),
                    style: TextStyle(
                      fontSize: 10,
                      color: isAdmin
                          ? Colors.white.withValues(alpha: 0.6)
                          : AdminTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 14,
              backgroundColor: AdminTheme.primary,
              child: Icon(Icons.support_agent_rounded, size: 16, color: AdminTheme.brandDark),
            ),
          ],
        ],
      ),
    );
  }
}
