import 'dart:async';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'telemetry_service.dart';
import 'user_profile.dart';

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.badge,
  });

  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? badge;
}

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({
    required this.profile,
    super.key,
  });

  final UserProfile profile;

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isGenerating = false;

  late final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Hello ${widget.profile.name.split(" ").first}! I am Utano AI Assistant, integrated with Google Gemini architecture for clinical vital sign analytics.\n\nI am monitoring Miriam Bandure\'s real-time upper-arm telemetry. How can I assist you with her care today?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      badge: 'Gemini Medical AI',
    ),
  ];

  final List<String> _quickPrompts = [
    '🩺 Analyze Miriam\'s current telemetry',
    '🏃 Explain exercise motion filter correlation',
    '🚨 How does the 2-minute emergency call trigger?',
    '💧 Elderly hydration & temperature advice',
    '📊 Compare vitals to clinical baseline',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendQuery(String query) {
    final text = query.trim();
    if (text.isEmpty || _isGenerating) return;

    _controller.clear();
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isGenerating = true;
    });
    _scrollToBottom();

    // Simulate Gemini AI context-aware inference based on live telemetry snapshot
    final snapshot = TelemetryService.instance.snapshot;

    Timer(const Duration(milliseconds: 750), () {
      if (!mounted) return;
      final aiResponse = _generateContextualResponse(text, snapshot);

      setState(() {
        _messages.add(
          ChatMessage(
            text: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
            badge: 'Gemini Clinical Insight',
          ),
        );
        _isGenerating = false;
      });
      _scrollToBottom();
    });
  }

  String _generateContextualResponse(String prompt, TelemetrySnapshot snap) {
    final lower = prompt.toLowerCase();

    if (lower.contains('analyze') || lower.contains('current') || lower.contains('telemetry')) {
      final statusDesc = snap.isCritical
          ? 'CRITICAL ALERT (Immediate caregiver review recommended)'
          : snap.isExercise
              ? 'ACTIVE AEROBIC EXERCISE (Elevated pulse normal for movement)'
              : 'STABLE & WITHIN CLINICAL BASELINE';

      return '### 📋 Clinical Telemetry Assessment\n'
          '**Patient:** Miriam Bandure (Upper-Arm Pod AU-001)\n\n'
          '• **Heart Rate:** ${snap.heartRate} BPM (Normal range: 60–100 resting)\n'
          '• **Blood Oxygen (SpO₂):** ${snap.spo2.toStringAsFixed(1)}% (Target > 95%)\n'
          '• **Body Temperature:** ${snap.temperature.toStringAsFixed(1)}°C (Normothermic: 36.5–37.5°C)\n'
          '• **Movement Speed:** ${snap.speedKmh.toStringAsFixed(1)} km/h\n'
          '• **Battery Pod:** ${snap.batteryPercentage}%\n\n'
          '**Status Evaluation:** $statusDesc.\n'
          'Brachial arterial pulsatile signal is strong with minimal motion artifacts.';
    }

    if (lower.contains('exercise') || lower.contains('motion') || lower.contains('filter')) {
      return '### 🏃 Smart Exercise Filter Analytics\n'
          'When Miriam walks or engages in light activity, her heart rate elevates naturally.\n\n'
          '• **Current Velocity:** ${snap.speedKmh.toStringAsFixed(1)} km/h\n'
          '• **Motion Correlation:** ${snap.isActivityCorrelated ? "ACTIVE" : "INACTIVE"}\n\n'
          'Utano AI utilizes GPS velocity (> 5.5 km/h) and upper-arm accelerometer harmonics to differentiate physiologic cardio exertion from acute pathologic tachycardia. This prevents false emergency alarms while preserving caregiver peace of mind.';
    }

    if (lower.contains('emergency') || lower.contains('call') || lower.contains('2-minute') || lower.contains('minute')) {
      return '### 🚨 Automated Emergency Escalation Protocol\n'
          'Utano is configured with an automated 2-minute safety net for Miriam Bandure:\n\n'
          '1. **Threshold Breach:** If SpO₂ drops below 90% or Heart Rate spikes above 120 BPM while resting, an audible in-app alert triggers.\n'
          '2. **Caregiver Window:** You have 120 seconds to acknowledge the notification if it is a false alarm or known situation.\n'
          '3. **Automated Voice Call:** If unacknowledged at 00:00, Utano initiates an automated emergency voice call with patient GPS coordinates and vital readings.';
    }

    if (lower.contains('hydrate') || lower.contains('hydration') || lower.contains('temperature') || lower.contains('advice')) {
      return '### 💧 Geriatric Health & Hydration Guidance\n'
          'Elderly patients often experience diminished thirst sensation. Based on Miriam\'s skin temperature (${snap.temperature.toStringAsFixed(1)}°C):\n\n'
          '• Ensure an intake of 1.5–2.0 liters of fresh water daily.\n'
          '• Monitor for signs of orthostatic hypotension when rising.\n'
          '• Ensure the upper-arm neoprene sleeve is adjusted comfortably (not constricting circulation).';
    }

    // Default conversational AI response
    return '### 💡 Utano AI Clinical Response\n'
        'Thank you for your question regarding Miriam Bandure\'s care.\n\n'
        'Her live readings currently indicate **${snap.heartRate} BPM** and **${snap.spo2.toStringAsFixed(1)}% SpO₂** under ${snap.statusText.toLowerCase()}.\n\n'
        '*(Note: For production deployment, this response will be generated directly by Google Gemini Live Health API via the configured project API key.)*';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TelemetryService.instance,
      builder: (context, _) {
        final snapshot = TelemetryService.instance.snapshot;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [forest, Color(0xFF0F3D35)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome, color: lime, size: 18),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Utano AI Assistant',
                      style: TextStyle(
                        color: ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Gemini Clinical Telemetry Engine',
                      style: TextStyle(
                        color: forest,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: snapshot.isCritical
                      ? coral.withValues(alpha: 0.15)
                      : forest.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: snapshot.isCritical ? coral : forest,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: snapshot.isCritical ? coral : forest,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${snapshot.heartRate} BPM · ${snapshot.spo2.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: snapshot.isCritical ? coral : forest,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Live Telemetry Banner for Context
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF2EE),
                  border: Border(bottom: BorderSide(color: line)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hub_rounded, size: 14, color: forest),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Live Context: Patient Miriam Bandure · Upper-Arm Pod AU-001 · HiveMQ MQTT Stream',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: forest,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Chat Messages Area
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildMessageBubble(msg);
                  },
                ),
              ),

              // Generating Animation Indicator
              if (_isGenerating)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: forest.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: forest,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Utano AI is evaluating vital signals with Gemini...',
                        style: TextStyle(
                          fontSize: 12,
                          color: mutedInk,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

              // Quick Prompts Chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickPrompts.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final prompt = _quickPrompts[index];
                    return ActionChip(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: line),
                      label: Text(
                        prompt,
                        style: const TextStyle(
                          fontSize: 11,
                          color: ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => _sendQuery(prompt),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Chat Input Bar
              Container(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: line)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Ask Utano AI about Miriam\'s health...',
                          hintStyle: const TextStyle(color: mutedInk, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: canvas,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: _sendQuery,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: forest,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
                        onPressed: () => _sendQuery(_controller.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [forest, Color(0xFF0F3D35)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: lime, size: 16),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!msg.isUser && msg.badge != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: lime.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        msg.badge!,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: forest,
                        ),
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: msg.isUser ? forest : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                    ),
                    border: msg.isUser ? null : Border.all(color: line),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: msg.isUser ? Colors.white : ink,
                      fontSize: 13.5,
                      height: 1.42,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 2, right: 2),
                  child: Text(
                    '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 10, color: mutedInk),
                  ),
                ),
              ],
            ),
          ),
          if (msg.isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFD3E5D8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person, color: forest, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}
