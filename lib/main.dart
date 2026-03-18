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
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF39FF14),
          surface: Color(0xFF111111),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [HomeScreen(), HistoryScreen()],
      ),
      bottomNavigationBar: _AnimatedNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ─── ANIMATED NAV BAR ──────────────────────────────────────────────
class _AnimatedNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AnimatedNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: const Color(0xFF111111),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.history_outlined,
            activeIcon: Icons.history,
            label: 'History',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF39FF14).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF39FF14) : Colors.grey,
              size: 24,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Color(0xFF39FF14),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _service = StreakService();
  Timer? _timer;

  DateTime? _startTime;
  bool _isRunning = false;

  int _days = 0;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  String _currentBadge = 'Clown';

  // side panel
  late AnimationController _panelController;
  late Animation<Offset> _panelSlide;
  bool _panelOpen = false;

  final List<Map<String, dynamic>> _badges = [
    {'name': 'Clown', 'days': 0, 'image': 'assets/badges/clown.png'},
    {'name': 'Noob', 'days': 1, 'image': 'assets/badges/noob.png'},
    {'name': 'Novice', 'days': 3, 'image': 'assets/badges/novice.png'},
    {'name': 'Average', 'days': 7, 'image': 'assets/badges/average.png'},
    {'name': 'Advanced', 'days': 15, 'image': 'assets/badges/advanced.png'},
    {'name': 'Sigma', 'days': 30, 'image': 'assets/badges/sigma.png'},
    {'name': 'Chad', 'days': 45, 'image': 'assets/badges/chad.png'},
    {
      'name': 'Absolute Chad',
      'days': 60,
      'image': 'assets/badges/absolute_chad.png',
    },
    {'name': 'Giga Chad', 'days': 120, 'image': 'assets/badges/giga_chad.png'},
    {
      'name': 'Absolute Giga Chad',
      'days': 365,
      'image': 'assets/badges/absolute_giga_chad.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadStreak();

    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _panelSlide = Tween<Offset>(begin: const Offset(-1.0, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _panelController, curve: Curves.easeInOut),
        );
  }

  void _openPanel() {
    setState(() => _panelOpen = true);
    _panelController.forward();
  }

  void _closePanel() {
    _panelController.reverse().then((_) {
      setState(() => _panelOpen = false);
    });
  }

  Future<void> _loadStreak() async {
    final running = await _service.isStreakRunning();
    final start = await _service.loadStartTime();
    setState(() {
      _isRunning = running;
      _startTime = start;
    });
    if (running && start != null) _startTicking();
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

  Future<void> _handleStart() async {
    await _service.startStreak();
    final start = await _service.loadStartTime();
    setState(() {
      _isRunning = true;
      _startTime = start;
    });
    _startTicking();
  }

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
    _panelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badgeImage = _service.getBadgeImage(_currentBadge);
    final progress = _days >= 365 ? 1.0 : (_days / 365).clamp(0.0, 1.0);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: _openPanel,
        ),
        title: const Text(
          'DONT GOON, YOU FUCKING GOONER',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 1.2,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),

      body: Stack(
        children: [
          // ── MAIN CONTENT (centered)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // BADGE CARD
                Container(
                  width: 220,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
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
                            errorBuilder: (_, __, ___) => const Icon(
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

                // CIRCULAR TIMER
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
                      mainAxisSize: MainAxisSize.min,
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

                const SizedBox(height: 40),

                // CLOWN BUTTON
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
                        errorBuilder: (_, __, ___) => Icon(
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
              ],
            ),
          ),

          // ── DARK OVERLAY when panel open
          if (_panelOpen)
            GestureDetector(
              onTap: _closePanel,
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),

          // ── SLIDING BADGE PANEL (75% width)
          SlideTransition(
            position: _panelSlide,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: screenWidth * 0.75,
                height: double.infinity,
                color: const Color(0xFF111111),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Panel header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                        child: Row(
                          children: [
                            const Text(
                              'All Badges',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: _closePanel,
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xFF222222)),

                      // Badge list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _badges.length,
                          itemBuilder: (context, index) {
                            final badge = _badges[index];
                            final isCurrentBadge =
                                badge['name'] == _currentBadge;
                            final isUnlocked = _days >= badge['days'];

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrentBadge
                                    ? const Color(
                                        0xFF39FF14,
                                      ).withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: isCurrentBadge
                                    ? Border.all(
                                        color: const Color(0xFF39FF14),
                                        width: 1,
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  // badge image
                                  Opacity(
                                    opacity: isUnlocked ? 1.0 : 0.3,
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isCurrentBadge
                                              ? const Color(0xFF39FF14)
                                              : const Color(0xFF333333),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          badge['image'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.person,
                                                color: Colors.grey,
                                                size: 24,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // badge info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          badge['name'],
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: isUnlocked
                                                ? Colors.white
                                                : Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          '${badge['days']}+ Days',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isCurrentBadge)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF39FF14),
                                      size: 18,
                                    ),
                                  if (!isUnlocked && !isCurrentBadge)
                                    const Icon(
                                      Icons.lock,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HISTORY SCREEN (placeholder) ─────────────────────────────────
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
