import 'package:flutter/material.dart';
import 'pages/biodata_page.dart';
import 'pages/aktivitas_harian_page.dart';
import 'pages/riwayat_pendidikan_page.dart';
import 'theme.dart';
import 'pages/pengalaman_page.dart';
import 'pages/draggable_info_button.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugas Proyek Aplikasi',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: SwipePages(
        onThemeToggle: _toggleTheme,
        currentThemeMode: _themeMode,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SwipePages extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  const SwipePages({
    super.key,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  @override
  State<SwipePages> createState() => _SwipePagesState();
}

class _SwipePagesState extends State<SwipePages> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Widget> get _pages => [
    BiodataPage(
      onThemeToggle: widget.onThemeToggle,
      currentThemeMode: widget.currentThemeMode,
    ),
    const AktivitasHarianPage(),
    const RiwayatPendidikanPage(),
    const PengalamanPage(),
  ];

  final List<String> _titles = [
    'Biodata',
    'Aktivitas Harian',
    'Riwayat Pendidikan',
    'Pengalaman',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.sunny;
      case ThemeMode.dark:
        return Icons.nightlight;
      default:
        return Icons.brightness_6;
    }
  }

  String _getThemeTooltip(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      default:
        return 'System Mode';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const DraggableInfoButton(),
        title: Text(_titles[_currentPage]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _getThemeIcon(widget.currentThemeMode),
            ),
            tooltip: _getThemeTooltip(widget.currentThemeMode),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: _pages,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.indigo : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
