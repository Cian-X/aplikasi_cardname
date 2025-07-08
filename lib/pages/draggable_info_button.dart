import 'package:flutter/material.dart';
import 'tentang_aplikasi_page.dart';

class DraggableInfoButton extends StatefulWidget {
  const DraggableInfoButton({Key? key}) : super(key: key);
  @override
  State<DraggableInfoButton> createState() => _DraggableInfoButtonState();
}

class _DraggableInfoButtonState extends State<DraggableInfoButton> {
  double _dragOffset = 0;
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dx;
        });
        if (_dragOffset > 80 && !_navigated) {
          _navigated = true;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TentangAplikasiPage()),
          ).then((_) {
            setState(() {
              _dragOffset = 0;
              _navigated = false;
            });
          });
        }
      },
      onHorizontalDragEnd: (_) {
        setState(() {
          _dragOffset = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: IconButton(
              icon: Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TentangAplikasiPage()),
                );
              },
              tooltip: 'Informasi Lanjutan',
            ),
          ),
        ),
      ),
    );
  }
} 