import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with TickerProviderStateMixin {
  String _pin = '';
  String? _savedPin;
  bool _isSettingPin = false;
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _hasError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _loadPin();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('vault_pin');
    setState(() {
      _savedPin = pin;
      _isSettingPin = pin == null;
    });
  }

  Future<void> _savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vault_pin', pin);
  }

  void _onKeyTap(String key) {
    setState(() {
      _hasError = false;
      if (_pin.length < 4) {
        _pin += key;
        if (_pin.length == 4) {
          _processPinInput();
        }
      }
    });
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _processPinInput() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_isSettingPin) {
        if (!_isConfirming) {
          setState(() {
            _confirmPin = _pin;
            _pin = '';
            _isConfirming = true;
          });
        } else {
          if (_pin == _confirmPin) {
            _savePin(_pin);
            _navigateHome();
          } else {
            _shakeAndReset();
          }
        }
      } else {
        if (_pin == _savedPin) {
          _navigateHome();
        } else {
          _shakeAndReset();
        }
      }
    });
  }

  void _shakeAndReset() {
    _shakeController.forward(from: 0).then((_) {
      setState(() {
        _pin = '';
        _hasError = true;
        if (_isConfirming) _isConfirming = false;
      });
    });
  }

  void _navigateHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.surface, AppTheme.surfaceElevated, AppTheme.surface],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              _buildHeader(),
              const SizedBox(height: 48),
              _buildPinDots(),
              const SizedBox(height: 16),
              if (_hasError)
                const Text('ভুল পিন! আবার চেষ্টা করুন',
                    style: TextStyle(color: AppTheme.danger, fontSize: 14)),
              const Spacer(),
              _buildKeypad(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primary, width: 2),
          ),
          child: const Icon(Icons.lock_rounded, color: AppTheme.primary, size: 40),
        ),
        const SizedBox(height: 20),
        Text(
          _isSettingPin
              ? (_isConfirming ? 'পিন নিশ্চিত করুন' : 'নতুন পিন তৈরি করুন')
              : 'পিন দিয়ে লক খুলুন',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isSettingPin
              ? (_isConfirming ? 'আবার একই ৪-সংখ্যার পিন দিন' : '৪-সংখ্যার একটি পিন তৈরি করুন')
              : 'আপনার ভল্ট পিন দিন',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPinDots() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * (_shakeController.value % 2 == 0 ? 1 : -1), 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < _pin.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? AppTheme.primary : Colors.transparent,
                  border: Border.all(
                    color: _hasError ? AppTheme.danger : AppTheme.primary,
                    width: 2,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['১', '২', '৩'],
      ['৪', '৫', '৬'],
      ['৭', '৮', '৯'],
      ['', '০', '⌫'],
    ];
    final numericMap = {'১':'1','২':'2','৩':'3','৪':'4','৫':'5','৬':'6','৭':'7','৮':'8','৯':'9','০':'0'};

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: keys.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key.isEmpty) return const SizedBox(width: 72, height: 72);
                return GestureDetector(
                  onTap: () => key == '⌫' ? _onDelete() : _onKeyTap(numericMap[key] ?? key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Center(
                      child: key == '⌫'
                          ? const Icon(Icons.backspace_outlined, color: AppTheme.textSecondary, size: 22)
                          : Text(key,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              )),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
