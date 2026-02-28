import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../admin/admin_home_screen.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 16)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    HapticFeedback.lightImpact();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final auth = AuthService();
      final result = await auth.login(
        _usernameCtrl.text.trim(),
        _passwordCtrl.text,
      );

      if (result['success'] == true) {
        final role = result['role'] as String;
        if (!mounted) return;
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        _handleAuthError(result['error']?.toString());
      }
    } catch (e) {
      _handleAuthError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleAuthError(String? message) {
    _passwordCtrl.clear();
    _shakeController.forward(from: 0);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message ?? 'Invalid username or password'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            _buildFloatingCircles(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bottomInset = MediaQuery.of(context).viewInsets.bottom;
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - bottomInset,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLogo(theme),
                          const SizedBox(height: 20),
                          AnimatedBuilder(
                            animation: _shakeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(_shakeAnimation.value - 8, 0),
                                child: child,
                              );
                            },
                            child: _buildCard(theme),
                          ),
                          const SizedBox(height: 16),
                          _credentialsHint(theme),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFF7CFC00), Color(0xFF9AFF00)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7CFC00).withOpacity(0.3),
                blurRadius: 25,
              ),
            ],
          ),
          child: const Icon(Icons.sports_soccer, size: 48, color: Colors.black),
        ),
        const SizedBox(height: 12),
        Text(
          'VIT SPORTS',
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tournament & Team Management',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(ThemeData theme) {
    return Container(
      width: 420,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.lawnGreen.withOpacity(0.3)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            _buildField(
              label: 'USERNAME',
              controller: _usernameCtrl,
              icon: Icons.person_outline,
              obscure: false,
            ),
            const SizedBox(height: 16),
            _buildField(
              label: 'PASSWORD',
              controller: _passwordCtrl,
              icon: Icons.lock_outline,
              obscure: _obscure,
              suffix: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey.shade400,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _loading ? null : _submit,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7CFC00), Color(0xFF9AFF00)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.6,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : Text(
                            'LOGIN',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 1.4,
                color: Colors.grey.shade300,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E0E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.lawnGreen),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey.shade400),
              suffixIcon: suffix,
              hintText: label == 'USERNAME'
                  ? 'Enter username'
                  : 'Enter password',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _credentialsHint(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        'Demo Credentials:\nAdmin: username: admin | password: admin\nUser: username: user | password: user',
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.grey.shade400,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildFloatingCircles() {
    return Stack(
      children: [
        Positioned(
          top: 80,
          left: -30,
          child: _blurCircle(140, Colors.greenAccent.withOpacity(0.12)),
        ),
        Positioned(
          bottom: 120,
          right: -40,
          child: _blurCircle(180, Colors.lightGreenAccent.withOpacity(0.10)),
        ),
      ],
    );
  }

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 60, spreadRadius: 30),
        ],
      ),
    );
  }
}
