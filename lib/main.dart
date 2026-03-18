import 'dart:async';
import 'package:flutter/material.dart';
import 'streak_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giga',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF39FF14),
          surface: const Color(0xFF111111),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// ─── MAIN SCREEN ───────────────────────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    BadgesScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: const Color(0xFF111111),
        indicatorColor: const Color(0xFF39FF14).withOpacity(0.15),
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF39FF14)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: Color(0xFF39FF14)),
            label: 'Badges',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: Color(0xFF39FF14)),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

// ─── HOME SCREEN ───────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = StreakService();
  Timer? _timer;

  DateTime? _startTime;
  bool _isRunning = false;

  int _days = 0;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  String _currentBadge = 'Clown';

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final running = await _service.isStreakRunning();
    final start = await _service.loadStartTime();
    setState(() {
      _isRunning = running;
      _startTime = start;
    });
    if (running && start != null) {
      _startTicking();
    }
  }

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime == null) return;
      final diff = DateTime.now().difference(_startTime!);
      setState(() {
        _days = diff.inDays;
        _hours = diff.inHours % 24;
        _minutes = diff.inMinutes % 60;
        _seconds = diff.inSeconds % 60;
        _currentBadge = _service.getCurrentBadge(_days);
      });
    });
  }

  // ── START button pressed
  Future<void> _handleStart() async {
    await _service.startStreak();
    final start = await _service.loadStartTime();
    setState(() {
      _isRunning = true;
      _startTime = start;
    });
    _startTicking();
  }

  // ── RELAPSE button pressed — show popup
  Future<void> _handleRelapse() async {
    final noteController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '🤡 You became a Clown again?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your $_days day streak will be reset to 0.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF111111),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3131),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('I relapsed 🤡'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.relapse(
        note: noteController.text.trim(),
        badgeName: _currentBadge,
        daysReached: _days,
      );
      _timer?.cancel();
      setState(() {
        _isRunning = false;
        _days = 0;
        _hours = 0;
        _minutes = 0;
        _seconds = 0;
        _currentBadge = 'Clown';
        _startTime = null;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badgeImage = _service.getBadgeImage(_currentBadge);
    final progress = _days >= 90 ? 1.0 : (_days / 90).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: const Text(
          'NO FAP!',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 2,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),

          // ── BADGE CARD
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // badge image circle
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF39FF14),
                      width: 2,
                    ),
                    color: const Color(0xFF111111),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      badgeImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _currentBadge,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Current Badge',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ── CIRCULAR TIMER
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: const Color(0xFF222222),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF39FF14),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$_days',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const Text(
                    'Days',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_hours.toString().padLeft(2, '0')}:${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // ── CLOWN BUTTON
          GestureDetector(
            onTap: _isRunning ? _handleRelapse : _handleStart,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1A1A),
                border: Border.all(
                  color: _isRunning
                      ? const Color(0xFFFF3131)
                      : const Color(0xFF39FF14),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/badges/clown.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    _isRunning ? Icons.stop : Icons.play_arrow,
                    color: _isRunning
                        ? const Color(0xFFFF3131)
                        : const Color(0xFF39FF14),
                    size: 36,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          Text(
            _isRunning ? 'Tap to relapse 🤡' : 'Tap to start',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── PLACEHOLDER SCREENS ───────────────────────────────────────────
class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: Center(
        child: Text(
          'Badges — coming Day 2',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: Center(
        child: Text(
          'History — coming Day 2',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
