import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/security_service.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';

class VaultLockScreen extends StatefulWidget {
  const VaultLockScreen({super.key});

  @override
  State<VaultLockScreen> createState() => _VaultLockScreenState();
}

class _VaultLockScreenState extends State<VaultLockScreen> with SingleTickerProviderStateMixin {
  final _security = SecurityService();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _isSetup = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
    _checkSetup();
  }

  Future<void> _checkSetup() async {
    final hasPassword = await _security.hasMasterPassword();
    setState(() => _isSetup = !hasPassword);
    if (hasPassword) {
      _tryBiometric();
    }
  }

  Future<void> _tryBiometric() async {
    final biometricEnabled = await _security.isBiometricEnabled();
    if (!biometricEnabled) return;
    final canUse = await _security.canUseBiometric();
    if (!canUse) return;

    final authenticated = await _security.authenticateWithBiometric();
    if (authenticated && mounted) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _handleSetup() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 6) {
      setState(() => _error = '密码至少需要6个字符');
      return;
    }
    if (password != confirm) {
      setState(() => _error = '两次输入的密码不一致');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    await _security.setMasterPassword(password);
    _security.unlock();
    _navigateToHome();
  }

  Future<void> _handleUnlock() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _error = '请输入密码');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await _security.verifyMasterPassword(password);
    if (success) {
      _navigateToHome();
    } else {
      setState(() {
        _isLoading = false;
        if (_security.isLockedOut) {
          final remaining = _security.lockoutRemaining;
          _error = '密码错误次数过多，请${remaining?.inMinutes ?? 5}分钟后重试';
        } else {
          _error = '密码错误，还剩${_security.remainingAttempts}次机会';
        }
      });
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF11111B), const Color(0xFF1E1E2E)]
                : [AppColors.primary.withOpacity(0.05), Colors.white],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      'Personal Vault',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSetup ? '设置主密码以保护您的数据' : '输入主密码解锁',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Password field
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofocus: !_isSetup,
                      decoration: InputDecoration(
                        labelText: '主密码',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      onSubmitted: (_) => _isSetup ? null : _handleUnlock(),
                    ),
                    if (_isSetup) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          labelText: '确认密码',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        onSubmitted: (_) => _handleSetup(),
                      ),
                    ],
                    // Error message
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, size: 16, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(color: AppColors.error, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : _isSetup
                                ? _handleSetup
                                : _handleUnlock,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(_isSetup ? '创建密码' : '解锁'),
                      ),
                    ),
                    // Biometric button
                    if (!_isSetup) ...[
                      const SizedBox(height: 16),
                      FutureBuilder<bool>(
                        future: _security.canUseBiometric(),
                        builder: (context, snapshot) {
                          if (snapshot.data != true) return const SizedBox();
                          return TextButton.icon(
                            onPressed: _tryBiometric,
                            icon: const Icon(Icons.fingerprint, size: 24),
                            label: const Text('生物识别解锁'),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _animController.dispose();
    super.dispose();
  }
}
