import 'package:flutter/material.dart';

class VoiceMessageWidget extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onSend;
  final String transcribedText;
  final bool isRecording;

  const VoiceMessageWidget({
    super.key,
    required this.onCancel,
    required this.onSend,
    required this.transcribedText,
    required this.isRecording,
  });

  @override
  State<VoiceMessageWidget> createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    if (widget.isRecording) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(VoiceMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_animationController.isAnimating) {
      _animationController.repeat();
    } else if (!widget.isRecording && _animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D32), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recording Status
          if (widget.isRecording)
            Row(
              children: [
                ScaleTransition(
                  scale: Tween(begin: 0.8, end: 1.2).animate(
                    CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
                  ),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Listening...',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            )
          else
            const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                SizedBox(width: 12),
                Text(
                  'Voice Message Ready',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 16),
          
          // Waveform Visualization (Animated bars)
          if (widget.isRecording)
            _buildWaveform()
          else
            const SizedBox.shrink(),
          
          const SizedBox(height: 16),
          
          // Transcribed Text
          if (widget.transcribedText.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transcribed Text:',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.transcribedText,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else if (widget.isRecording)
            const SizedBox(height: 8)
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'No transcription yet',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Cancel Button
              TextButton.icon(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              // Send Button (Only enabled when not recording)
              FilledButton.icon(
                onPressed: widget.isRecording ? null : widget.onSend,
                icon: const Icon(Icons.send),
                label: const Text('Send'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build animated waveform visualization
  Widget _buildWaveform() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return ScaleTransition(
          scale: Tween(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                index * 0.2,
                (index + 1) * 0.2,
                curve: Curves.easeInOut,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 4,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
