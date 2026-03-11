import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _hashPasscode(String passcode) {
  return sha256.convert(utf8.encode(passcode)).toString();
}

/// パスコードロック画面
class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({super.key, required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  final _auth = LocalAuthentication();
  String _input = '';
  String? _errorMessage;
  bool _autoAttempted = false;

  @override
  void initState() {
    super.initState();
    _tryBiometricAuto();
  }

  Future<void> _tryBiometricAuto() async {
    if (_autoAttempted) return;
    _autoAttempted = true;
    await _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();

      if (canCheck || isDeviceSupported) {
        final authenticated = await _auth.authenticate(
          localizedReason: 'アプリのロックを解除',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        if (authenticated && mounted) {
          widget.onUnlocked();
        }
      }
    } catch (_) {
      // 生体認証が使えない場合はパスコード入力にフォールバック
    }
  }

  Future<void> _onDigitPressed(String digit) async {
    if (_input.length >= 4) return;

    setState(() {
      _input += digit;
      _errorMessage = null;
    });

    if (_input.length == 4) {
      final prefs = await SharedPreferences.getInstance();
      final savedHash = prefs.getString('passcode_hash');

      if (_hashPasscode(_input) == savedHash) {
        HapticFeedback.lightImpact();
        widget.onUnlocked();
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _errorMessage = 'パスコードが違います';
          _input = '';
        });
      }
    }
  }

  void _onDeletePressed() {
    if (_input.isNotEmpty) {
      setState(() {
        _input = _input.substring(0, _input.length - 1);
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90D9), Color(0xFF3A7BD5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              // ロックアイコン
              const Icon(Icons.lock_outline, size: 48, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'パスコードを入力',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // ドットインジケーター
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _input.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? Colors.white : Colors.transparent,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  );
                }),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
              ],
              const Spacer(),
              // テンキー
              _Keypad(
                onDigit: _onDigitPressed,
                onDelete: _onDeletePressed,
                onBiometric: _tryBiometric,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onDigit,
    required this.onDelete,
    required this.onBiometric,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onBiometric;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['bio', '0', 'del'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) {
                if (key == 'bio') {
                  return _KeyButton(
                    onTap: onBiometric,
                    child: const Icon(Icons.fingerprint, color: Colors.white, size: 28),
                  );
                }
                if (key == 'del') {
                  return _KeyButton(
                    onTap: onDelete,
                    child: const Icon(Icons.backspace_outlined, color: Colors.white, size: 24),
                  );
                }
                return _KeyButton(
                  onTap: () => onDigit(key),
                  child: Text(
                    key,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

/// パスコード設定ダイアログ
Future<bool> showPasscodeSetupDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => const _PasscodeSetupDialog(),
  );
  return result ?? false;
}

class _PasscodeSetupDialog extends StatefulWidget {
  const _PasscodeSetupDialog();

  @override
  State<_PasscodeSetupDialog> createState() => _PasscodeSetupDialogState();
}

class _PasscodeSetupDialogState extends State<_PasscodeSetupDialog> {
  String _passcode = '';
  String? _confirmPasscode;
  bool _isConfirming = false;
  String? _error;

  void _onDigit(String digit) async {
    if (!_isConfirming) {
      if (_passcode.length >= 4) return;
      setState(() {
        _passcode += digit;
        _error = null;
      });
      if (_passcode.length == 4) {
        setState(() => _isConfirming = true);
      }
    } else {
      _confirmPasscode ??= '';
      if (_confirmPasscode!.length >= 4) return;
      setState(() {
        _confirmPasscode = _confirmPasscode! + digit;
        _error = null;
      });
      if (_confirmPasscode!.length == 4) {
        if (_passcode == _confirmPasscode) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('passcode_hash', _hashPasscode(_passcode));
          await prefs.setBool('passcode_enabled', true);
          if (mounted) Navigator.pop(context, true);
        } else {
          setState(() {
            _error = 'パスコードが一致しません';
            _confirmPasscode = null;
            _isConfirming = false;
            _passcode = '';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentInput = _isConfirming ? (_confirmPasscode ?? '') : _passcode;

    return AlertDialog(
      title: Text(_isConfirming ? 'もう一度入力' : 'パスコードを設定'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < currentInput.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? theme.colorScheme.primary : Colors.transparent,
                  border: Border.all(color: theme.colorScheme.primary, width: 2),
                ),
              );
            }),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
          const SizedBox(height: 16),
          // 簡易テンキー
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final d in ['1','2','3','4','5','6','7','8','9','0'])
                SizedBox(
                  width: 56,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => _onDigit(d),
                    child: Text(d, style: const TextStyle(fontSize: 18)),
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('キャンセル'),
        ),
      ],
    );
  }
}
