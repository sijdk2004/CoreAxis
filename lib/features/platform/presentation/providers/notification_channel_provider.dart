import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification_channel_model.dart';
import 'dart:math';

class NotificationChannelState {
  final List<NotificationChannel> channels;
  final List<ChannelUsageDataPoint> usageData;
  final bool isLoading;

  NotificationChannelState({
    required this.channels,
    required this.usageData,
    this.isLoading = false,
  });

  NotificationChannelState copyWith({
    List<NotificationChannel>? channels,
    List<ChannelUsageDataPoint>? usageData,
    bool? isLoading,
  }) {
    return NotificationChannelState(
      channels: channels ?? this.channels,
      usageData: usageData ?? this.usageData,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationChannelNotifier extends Notifier<NotificationChannelState> {
  @override
  NotificationChannelState build() {
    return NotificationChannelState(
      channels: _generateMockChannels(),
      usageData: _generateMockUsageData(),
    );
  }

  void updateChannelConfig(NotificationChannel updatedChannel) {
    state = state.copyWith(
      channels: state.channels.map((c) => c.id == updatedChannel.id ? updatedChannel : c).toList(),
    );
  }

  void toggleChannelStatus(String id, bool isEnabled) {
    state = state.copyWith(
      channels: state.channels.map((c) {
        if (c.id == id) {
          return c.copyWith(
            isEnabled: isEnabled,
            configStatus: isEnabled ? 'Active' : 'Disabled',
          );
        }
        return c;
      }).toList(),
    );
  }

  Future<bool> testConnection(String id) async {
    // Mock network delay for test connection
    await Future.delayed(const Duration(seconds: 1));
    // Always succeed for mock purposes
    return true;
  }

  List<NotificationChannel> _generateMockChannels() {
    return [
      NotificationChannel(
        id: 'CH_EMAIL',
        name: 'Email',
        provider: 'SendGrid',
        isEnabled: true,
        messagesSent: 45210,
        successRate: 0.992,
        configStatus: 'Active',
        apiKey: 'SG.mock_api_key_12345',
        senderName: 'ERP Platform',
        senderEmail: 'noreply@erpplatform.com',
      ),
      NotificationChannel(
        id: 'CH_SMS',
        name: 'SMS',
        provider: 'Twilio',
        isEnabled: true,
        messagesSent: 12450,
        successRate: 0.985,
        configStatus: 'Active',
        apiKey: 'SKmock_twilio_api_key_67890',
        senderName: 'ERP-Alert',
      ),
      NotificationChannel(
        id: 'CH_PUSH',
        name: 'Push Notifications',
        provider: 'Firebase Cloud Messaging',
        isEnabled: true,
        messagesSent: 89000,
        successRate: 0.954,
        configStatus: 'Active',
        apiKey: 'AIzaSyMockFirebaseKey999',
      ),
      NotificationChannel(
        id: 'CH_WA',
        name: 'WhatsApp',
        provider: 'Twilio',
        isEnabled: false,
        messagesSent: 0,
        successRate: 0.0,
        configStatus: 'Disabled',
        apiKey: '',
      ),
      NotificationChannel(
        id: 'CH_INAPP',
        name: 'In-App Notifications',
        provider: 'Internal Socket',
        isEnabled: true,
        messagesSent: 120500,
        successRate: 0.999,
        configStatus: 'Active',
      ),
    ];
  }

  List<ChannelUsageDataPoint> _generateMockUsageData() {
    final rand = Random();
    return [
      ChannelUsageDataPoint('Jan', rand.nextInt(5000) + 10000, rand.nextInt(2000) + 2000, rand.nextInt(10000) + 15000),
      ChannelUsageDataPoint('Feb', rand.nextInt(5000) + 11000, rand.nextInt(2000) + 2100, rand.nextInt(10000) + 16000),
      ChannelUsageDataPoint('Mar', rand.nextInt(5000) + 12000, rand.nextInt(2000) + 2500, rand.nextInt(10000) + 18000),
      ChannelUsageDataPoint('Apr', rand.nextInt(5000) + 10500, rand.nextInt(2000) + 2200, rand.nextInt(10000) + 17000),
      ChannelUsageDataPoint('May', rand.nextInt(5000) + 13000, rand.nextInt(2000) + 2800, rand.nextInt(10000) + 20000),
      ChannelUsageDataPoint('Jun', rand.nextInt(5000) + 15000, rand.nextInt(2000) + 3000, rand.nextInt(10000) + 22000),
    ];
  }
}

final notificationChannelProvider = NotifierProvider<NotificationChannelNotifier, NotificationChannelState>(() {
  return NotificationChannelNotifier();
});
