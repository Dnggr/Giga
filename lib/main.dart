import 'dart:async';
import 'package:flutter/material.dart';
import 'streak_service.dart';
import 'streak_model.dart';
import 'notification_service.dart';

Color getBadgeColor(String badge) {
  switch (badge) {
    case 'Absolute Giga Chad':
      return const Color(0xFF00BFFF);
    case 'Giga Chad':
      return const Color(0xFF39FF14);
    case 'Absolute Chad':
      return const Color(0xFFFF9500);
    case 'Chad':
      return const Color(0xFFFFD700);
    case 'Sigma':
      return const Color(0xFF4A9EFF);
    case 'Advanced':
      return const Color(0xFFC0C0C0);
    case 'Average':
      return const Color(0xFFCD7F32);
    case 'Novice':
      return const Color(0xFFAAAAAA);
    case 'Noob':
      return const Color(0xFF888888);
    default:
      return const Color(0xFFFF3131);
  }
}

const List<String> _motivationalQuotes = [
  "Every day you resist, you become stronger.",
  "Your future self is watching you right now.",
  "Discipline is choosing between what you want now and what you want most.",
  "The man who masters himself is free.",
  "You are not a slave to your impulses.",
  "Real strength is controlling what you consume.",
  "Every streak starts with a single day.",
  "Pain is temporary. Regret is permanent.",
  "You don't have to be great to start, but you have to start to be great.",
  "The hardest walk is alone, but it makes you stronger.",
  "Stop being a spectator of your own life.",
  "What you do in private determines who you are in public.",
  "Weak men wait for opportunities. Strong men make them.",
  "Your brain is lying to you. Keep going.",
  "A year from now you'll wish you started today.",
  "Small daily improvements lead to stunning results.",
  "You were born to do more than this.",
  "The body achieves what the mind believes.",
  "It always seems impossible until it's done.",
  "Be the man your dog thinks you are.",
  "Don't count the days. Make the days count.",
  "The cave you fear to enter holds the treasure you seek.",
  "Motivation gets you started. Discipline keeps you going.",
  "Fall seven times, stand up eight.",
  "A desire, a dream, a vision — that's what champions are made of.",
  "Hardships prepare ordinary people for an extraordinary destiny.",
  "Do something today that your future self will thank you for.",
  "You are the author of your own story.",
  "The courage to continue is what counts.",
  "The secret of getting ahead is getting started.",
  "One day or day one. You decide.",
  "Conquer yourself and you conquer the world.",
  "Your addiction is your enemy. Defeat it daily.",
  "Wake up and chase your dreams.",
  "The struggle today builds the strength for tomorrow.",
  "Be so good they can't ignore you.",
  "The only person you are destined to become is who you decide to be.",
  "Believe you can and you're halfway there.",
  "Do not wait — the time will never be just right.",
  "Act as if what you do makes a difference. It does.",
  "Success is small efforts repeated day in and day out.",
  "The harder the battle, the sweeter the victory.",
  "You have power over your mind — not outside events.",
  "He who has mastered himself is mightier than any conqueror.",
  "Excellence is not an act, but a habit.",
  "No man is free who is not master of himself.",
  "To conquer oneself is the greatest victory.",
  "First say what you would be, then do what you have to do.",
  "You don't rise to your goals. You fall to your systems.",
  "The best time was 20 years ago. The second best time is now.",
  "Prove them wrong — especially yourself.",
  "Your only limit is your mind.",
  "Stay hard.",
];

String getDailyQuote() {
  final dayOfYear = DateTime.now()
      .difference(DateTime(DateTime.now().year))
      .inDays;
  return _motivationalQuotes[dayOfYear % _motivationalQuotes.length];
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await NotificationService.scheduleDailyQuote(
    quote: getDailyQuote(),
    hour: 8, // 8:00 AM — change this to whatever time you want
    minute: 0,
  );
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
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
  final _historyKey = GlobalKey<_HistoryScreenState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onRelapse: () => _historyKey.currentState?._loadHistory()),
          HistoryScreen(key: _historyKey),
        ],
      ),
      bottomNavigationBar: _AnimatedNavBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 1) _historyKey.currentState?._loadHistory();
          setState(() => _currentIndex = i);
        },
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
      height: 68,
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        border: Border(top: BorderSide(color: Color(0xFF1E1E1E))),
      ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF39FF14).withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          border: isSelected
              ? Border.all(
                  color: const Color(0xFF39FF14).withOpacity(0.2),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? const Color(0xFF39FF14)
                  : const Color(0xFF555555),
              size: 22,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFF39FF14),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          letterSpacing: 0.3,
                        ),
                      ),
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
  final VoidCallback? onRelapse;
  const HomeScreen({super.key, this.onRelapse});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _service = StreakService();
  Timer? _timer;

  DateTime? _startTime;
  bool _isRunning = false;

  int _days = 0;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  String _currentBadge = 'Clown';

  late AnimationController _panelController;
  late Animation<Offset> _panelSlide;
  bool _panelOpen = false;

  late AnimationController _badgeController;
  late Animation<double> _badgeScale;
  late Animation<double> _badgeFade;

  final List<Map<String, dynamic>> _badges = const [
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

    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _panelSlide = Tween<Offset>(begin: const Offset(-1.0, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _panelController, curve: Curves.easeInOut),
        );

    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _badgeScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.elasticOut),
    );
    _badgeFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _badgeController, curve: Curves.easeIn));

    _badgeController.forward();
    _loadStreak();
  }

  void _openPanel() {
    setState(() => _panelOpen = true);
    _panelController.forward();
  }

  void _closePanel() {
    _panelController.reverse().then((_) {
      if (mounted) setState(() => _panelOpen = false);
    });
  }

  Future<void> _loadStreak() async {
    final running = await _service.isStreakRunning();
    final start = await _service.loadStartTime();
    if (!mounted) return;
    setState(() {
      _isRunning = running;
      _startTime = start;
    });
    if (running && start != null) _startTicking();
  }

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _startTime == null) return;
      final diff = DateTime.now().difference(_startTime!);
      final newBadge = _service.getCurrentBadge(diff.inDays);
      if (newBadge != _currentBadge) {
        _badgeController
          ..reset()
          ..forward();
      }
      setState(() {
        _days = diff.inDays;
        _hours = diff.inHours % 24;
        _minutes = diff.inMinutes % 60;
        _seconds = diff.inSeconds % 60;
        _currentBadge = newBadge;
      });
    });
  }

  Future<void> _handleStart() async {
    await _service.startStreak();
    final start = await _service.loadStartTime();
    if (!mounted) return;
    setState(() {
      _isRunning = true;
      _startTime = start;
      _days = 0;
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
      _currentBadge = 'Clown';
    });
    _badgeController
      ..reset()
      ..forward();
    _startTicking();
  }

  Future<void> _handleRelapse() async {
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '🤡 You became a Clown again?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your $_days day streak will be reset to 0.',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                hintStyle: const TextStyle(color: Color(0xFF555555)),
                filled: true,
                fillColor: const Color(0xFF0D0D0D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF555555)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3131),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'I relapsed 🤡',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
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
      if (!mounted) return;
      setState(() {
        _isRunning = false;
        _days = 0;
        _hours = 0;
        _minutes = 0;
        _seconds = 0;
        _currentBadge = 'Clown';
        _startTime = null;
      });
      _badgeController
        ..reset()
        ..forward();
      widget.onRelapse?.call();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _panelController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badgeImage = _service.getBadgeImage(_currentBadge);
    final screenWidth = MediaQuery.of(context).size.width;
    final accentColor = getBadgeColor(_currentBadge);

    final dayProgress = _days >= 365 ? 1.0 : (_days / 365).clamp(0.0, 1.0);
    // inner ring = progress through current 24hr cycle
    final totalSeconds = (_startTime != null && _isRunning)
        ? DateTime.now().difference(_startTime!).inSeconds
        : 0;
    final secondsIntoDay = totalSeconds % 86400; // 86400 = 24hrs in seconds
    final hourProgress = secondsIntoDay / 86400.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF888888), size: 22),
          onPressed: _openPanel,
        ),
        title: const Text(
          'DONT GOON, YOU FUCKING GOONER',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 1.2,
            color: Color(0xFF444444),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),

      body: Stack(
        children: [
          // ── MAIN CONTENT
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── BADGE CARD
                  FadeTransition(
                    opacity: _badgeFade,
                    child: ScaleTransition(
                      scale: _badgeScale,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accentColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: accentColor,
                                  width: 2.5,
                                ),
                                color: const Color(0xFF0A0A0A),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  badgeImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.person,
                                    size: 32,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentBadge,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: accentColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const Text(
                                  'Current rank',
                                  style: TextStyle(
                                    color: Color(0xFF444444),
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: accentColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '$_days d',
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── DOUBLE RING TIMER using CustomPainter
                  RepaintBoundary(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(200, 200),
                            painter: _RingPainter(
                              outerProgress: dayProgress,
                              innerProgress: hourProgress,
                              color: accentColor,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$_days',
                                style: const TextStyle(
                                  fontSize: 72,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1,
                                  letterSpacing: -2,
                                ),
                              ),
                              const Text(
                                'DAYS',
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 11,
                                  letterSpacing: 3,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111111),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF222222),
                                  ),
                                ),
                                child: Text(
                                  '${_hours.toString().padLeft(2, '0')}:${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: accentColor.withOpacity(0.8),
                                    fontSize: 16,
                                    fontFamily: 'monospace',
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── CLOWN BUTTON
                  _PulseButton(
                    isRunning: _isRunning,
                    accentColor: accentColor,
                    badgeImage: 'assets/badges/clown.png',
                    onTap: _isRunning ? _handleRelapse : _handleStart,
                  ),

                  const SizedBox(height: 12),
                  Text(
                    _isRunning ? 'tap to relapse 🤡' : 'tap to start',
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF1A1A1A),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '💬  daily quote',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '"${getDailyQuote()}"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: accentColor.withOpacity(0.7),
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            height: 1.6,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // ── OVERLAY
          if (_panelOpen)
            GestureDetector(
              onTap: _closePanel,
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),

          // ── SLIDING BADGE PANEL
          SlideTransition(
            position: _panelSlide,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: screenWidth * 0.75,
                height: double.infinity,
                color: const Color(0xFF0D0D0D),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
                        child: Row(
                          children: [
                            const Text(
                              'All Badges',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Color(0xFF444444),
                                size: 20,
                              ),
                              onPressed: _closePanel,
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xFF1A1A1A), height: 1),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: _badges.length,
                          itemBuilder: (context, index) {
                            final badge = _badges[index];
                            final isCurrentBadge =
                                badge['name'] == _currentBadge;
                            final isUnlocked = _days >= (badge['days'] as int);
                            final badgeAccent = getBadgeColor(
                              badge['name'] as String,
                            );

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 3,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrentBadge
                                    ? badgeAccent.withOpacity(0.07)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isCurrentBadge
                                    ? Border.all(
                                        color: badgeAccent.withOpacity(0.3),
                                        width: 1,
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Opacity(
                                    opacity: isUnlocked ? 1.0 : 0.2,
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isCurrentBadge
                                              ? badgeAccent
                                              : const Color(0xFF2A2A2A),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          badge['image'] as String,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Icon(
                                            Icons.person,
                                            color: badgeAccent,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          badge['name'] as String,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isUnlocked
                                                ? Colors.white
                                                : const Color(0xFF333333),
                                          ),
                                        ),
                                        Text(
                                          '${badge['days']}+ days',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF444444),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isCurrentBadge)
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: badgeAccent,
                                      ),
                                    ),
                                  if (!isUnlocked && !isCurrentBadge)
                                    const Icon(
                                      Icons.lock_outline,
                                      color: Color(0xFF2A2A2A),
                                      size: 14,
                                    ),
                                  if (isUnlocked && !isCurrentBadge)
                                    const Icon(
                                      Icons.check,
                                      color: Color(0xFF2A7A2A),
                                      size: 14,
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

// ─── CUSTOM RING PAINTER ───────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double outerProgress;
  final double innerProgress;
  final Color color;

  _RingPainter({
    required this.outerProgress,
    required this.innerProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const startAngle = -3.14159265 / 2;
    const fullCircle = 2 * 3.14159265;

    // outer track
    canvas.drawCircle(
      center,
      size.width / 2 - 5,
      Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // outer progress arc
    if (outerProgress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width / 2 - 5),
        startAngle,
        outerProgress * fullCircle,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round,
      );
    }

    // inner track
    final innerR = size.width / 2 - 22;
    canvas.drawCircle(
      center,
      innerR,
      Paint()
        ..color = const Color(0xFF141414)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    // inner progress arc (24hr)
    if (innerProgress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerR),
        startAngle,
        innerProgress * fullCircle,
        false,
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.outerProgress != outerProgress ||
      old.innerProgress != innerProgress ||
      old.color != color;
}

// ─── PULSE BUTTON ──────────────────────────────────────────────────
class _PulseButton extends StatefulWidget {
  final bool isRunning;
  final Color accentColor;
  final String badgeImage;
  final VoidCallback onTap;

  const _PulseButton({
    required this.isRunning,
    required this.accentColor,
    required this.badgeImage,
    required this.onTap,
  });

  @override
  State<_PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<_PulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    if (widget.isRunning) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulseButton old) {
    super.didUpdateWidget(old);
    if (widget.isRunning && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isRunning && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) => Transform.scale(
          scale: widget.isRunning ? _pulseAnim.value : 1.0,
          child: child,
        ),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF111111),
            border: Border.all(
              color: widget.isRunning
                  ? const Color(0xFFFF3131)
                  : const Color(0xFF39FF14),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              widget.badgeImage,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(
                widget.isRunning ? Icons.stop : Icons.play_arrow,
                color: widget.isRunning
                    ? const Color(0xFFFF3131)
                    : const Color(0xFF39FF14),
                size: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── HISTORY SCREEN ────────────────────────────────────────────────
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = StreakService();
  List<StreakEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await _service.loadHistory();
    if (!mounted) return;
    setState(() => _history = data);
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Clean history?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3131),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Clean'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3A1A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.clearHistory();
      _loadHistory();
    }
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: const Text(
          'History',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: Color(0xFF444444),
                size: 22,
              ),
              onPressed: _confirmClearHistory,
            ),
        ],
      ),
      body: _history.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 48, color: Color(0xFF1A1A1A)),
                  SizedBox(height: 16),
                  Text(
                    'No history yet',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your past streaks will appear here',
                    style: TextStyle(color: Color(0xFF222222), fontSize: 12),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF39FF14),
              onRefresh: _loadHistory,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _history.length + 1, // +1 for the stats header
                itemBuilder: (context, index) {
                  // ── STATS HEADER (index 0)
                  if (index == 0) {
                    final best = _history
                        .map((e) => e.daysReached)
                        .reduce((a, b) => a > b ? a : b);
                    final total = _history.length;
                    final avg =
                        (_history
                                    .map((e) => e.daysReached)
                                    .reduce((a, b) => a + b) /
                                total)
                            .toStringAsFixed(1);
                    final bestEntry = _history.firstWhere(
                      (e) => e.daysReached == best,
                    );
                    final bestColor = getBadgeColor(bestEntry.badgeName);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: bestColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: bestColor,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Personal Best',
                                style: TextStyle(
                                  color: bestColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _StatBox(
                                  label: 'Best Streak',
                                  value: '$best days',
                                  color: bestColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatBox(
                                  label: 'Total Attempts',
                                  value: '$total',
                                  color: const Color(0xFF444444),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatBox(
                                  label: 'Avg Streak',
                                  value: '$avg d',
                                  color: const Color(0xFF444444),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  // ── HISTORY ENTRIES (index 1+)
                  final entry = _history[index - 1];
                  final badgeImage = _service.getBadgeImage(entry.badgeName);
                  final color = getBadgeColor(entry.badgeName);
                  final isBest =
                      entry.daysReached ==
                      _history
                          .map((e) => e.daysReached)
                          .reduce((a, b) => a > b ? a : b);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isBest
                            ? color.withOpacity(0.4)
                            : const Color(0xFF1A1A1A),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color.withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              badgeImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.person, color: color, size: 26),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    entry.badgeName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${entry.daysReached}d',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (isBest) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFFFD700,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        '🏆 best',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFFFFD700),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${_formatDate(entry.startTime)} → ${_formatDate(entry.endTime)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              if (entry.note.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  entry.note,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF444444),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E1E1E)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color == const Color(0xFF444444) ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF444444),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
