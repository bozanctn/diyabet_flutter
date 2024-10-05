import 'package:flutter/material.dart';
import 'dart:async';

class RoundIconButton extends StatefulWidget {
  const RoundIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.incrementValue = 1,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback onPressed;
  final int incrementValue; // İsteğe bağlı olarak artış/azalış değeri

  @override
  _RoundIconButtonState createState() => _RoundIconButtonState();
}

class _RoundIconButtonState extends State<RoundIconButton> {
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onLongPressStart: (details) {
        _startLongPressAction();
      },
      onLongPressEnd: (details) {
        _stopLongPressAction();
      },
      child: Container(
        width: 56.0,
        height: 56.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF4C4F5E),
        ),
        child: Icon(widget.icon, color: Colors.white),
      ),
    );
  }

  // Basılı tutma başladığında artış/azalış işlemini başlatır
  void _startLongPressAction() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      widget.onPressed(); // Belirtilen `onPressed` işlevini sürekli çalıştırır
    });
  }

  // Basılı tutma bırakıldığında işlemi durdurur
  void _stopLongPressAction() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Timer'ı iptal eder
    super.dispose();
  }
}
