import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CounterImageToggleApp());
}

class CounterImageToggleApp extends StatelessWidget {
  const CounterImageToggleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CW1 Counter & Toggle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // Counter and Step Control
  int _counter = 0;
  int _step = 1; // default increment step
  final List<int> _steps = [1, 5, 10];

  // Theme
  bool _isDark = false;

  // Image Toggle
  bool _isFirstImage = true;
  late final AnimationController _controller;
  late final Animation<double> _fade;

  // SharedPreferences instance
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _loadState(); // Load saved state on startup
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ------------------ State Persistence ------------------
  Future<void> _loadState() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = _prefs.getInt('counter') ?? 0;
      _isFirstImage = _prefs.getBool('isFirstImage') ?? true;
      _isDark = _prefs.getBool('isDark') ?? false;

      // Ensure animation matches saved image state
      if (_isFirstImage) {
        _controller.value = 0.0;
      } else {
        _controller.value = 1.0;
      }
    });
  }

  Future<void> _saveState() async {
    await _prefs.setInt('counter', _counter);
    await _prefs.setBool('isFirstImage', _isFirstImage);
    await _prefs.setBool('isDark', _isDark);
  }

  // ------------------ Counter Controls ------------------
  void _incrementCounter() {
    setState(() {
      _counter += _step;
    });
    _saveState();
  }

  void _decrementCounter() {
    setState(() {
      if (_counter - _step >= 0) {
        _counter -= _step;
      } else {
        _counter = 0;
      }
    });
    _saveState();
  }

  void _setStep(int step) {
    setState(() {
      _step = step;
    });
  }

  // ------------------ Image Toggle ------------------
  void _toggleImage() {
    if (_isFirstImage) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFirstImage = !_isFirstImage;
    });
    _saveState();
  }

  // ------------------ Theme Toggle ------------------
  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
    _saveState();
  }

  // ------------------ Reset ------------------
  Future<void> _resetApp() async {
    setState(() {
      _counter = 0;
      _isFirstImage = true;
      _isDark = false;
      _step = 1;
      _controller.value = 0.0; // reset animation
    });
    await _prefs.clear();
  }

  Future<void> _showResetDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Reset'),
          content: const Text(
              'Are you sure you want to reset all data? This cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Reset'),
              onPressed: () {
                _resetApp();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CW1 Counter & Toggle'),
          actions: [
            IconButton(
              onPressed: _toggleTheme,
              icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ----------- Counter Display -----------
                Text(
                  'Counter: $_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),

                // ----------- Step Buttons -----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _steps
                      .map(
                        (s) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: () => _setStep(s),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _step == s ? Colors.blue : Colors.grey,
                            ),
                            child: Text('+$s'),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),

                // ----------- Increment / Decrement Buttons -----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _counter > 0 ? _decrementCounter : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _counter > 0 ? Colors.red : Colors.grey,
                      ),
                      child: const Text('-'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _incrementCounter,
                      child: Text('+$_step'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ----------- Reset Button -----------
                ElevatedButton(
                  onPressed: _showResetDialog,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Reset App'),
                ),
                const SizedBox(height: 24),

                // ----------- Animated Image Toggle -----------
                FadeTransition(
                  opacity: _fade,
                  child: Image.asset(
                    _isFirstImage ? 'assets/image1.png' : 'assets/image2.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _toggleImage,
                  child: const Text('Toggle Image'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}