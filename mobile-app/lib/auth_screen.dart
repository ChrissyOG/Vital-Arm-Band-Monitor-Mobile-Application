import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'user_profile.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({required this.onAuthenticated, super.key});

  final ValueChanged<UserProfile> onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showSignUp = false;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 220),
    child: _showSignUp
        ? SignUpScreen(
            key: const ValueKey('sign-up'),
            onBack: () => setState(() => _showSignUp = false),
            onAuthenticated: widget.onAuthenticated,
          )
        : SignInScreen(
            key: const ValueKey('sign-in'),
            onSignUp: () => setState(() => _showSignUp = true),
            onAuthenticated: widget.onAuthenticated,
          ),
  );
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    required this.onSignUp,
    required this.onAuthenticated,
    super.key,
  });

  final VoidCallback onSignUp;
  final ValueChanged<UserProfile> onAuthenticated;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  UserRole _role = UserRole.caregiver;
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;
    widget.onAuthenticated(
      UserProfile(
        name: 'Alex Morgan',
        email: _email.text.trim(),
        role: _role,
        monitoredName: 'Miriam Bandure',
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
            children: [
              const BrandMark(),
              const SizedBox(height: 44),
              const Text(
                'WELCOME BACK',
                style: TextStyle(
                  color: forest,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Health, in\ncloser view.',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontSize: 38),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sign in to check your band and the people who matter.',
                style: TextStyle(color: mutedInk, fontSize: 15),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Email address'),
                    TextFormField(
                      key: const Key('signin-email'),
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'you@example.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: (value) => value != null && value.contains('@')
                          ? null
                          : 'Enter a valid email address',
                    ),
                    const SizedBox(height: 18),
                    const FieldLabel('Password'),
                    TextFormField(
                      key: const Key('signin-password'),
                      controller: _password,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        hintText: 'Your password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _hidePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => value != null && value.isNotEmpty
                          ? null
                          : 'Enter your password',
                    ),
                    const SizedBox(height: 18),
                    const FieldLabel('Signing in as'),
                    DropdownButtonFormField<UserRole>(
                      initialValue: _role,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.people_outline_rounded),
                      ),
                      items: UserRole.values
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(role.title),
                            ),
                          )
                          .toList(),
                      onChanged: (role) {
                        if (role != null) setState(() => _role = role);
                      },
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset password'),
                      content: const Text(
                        'Password recovery will be available when account services are connected.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Got it'),
                        ),
                      ],
                    ),
                  ),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(label: 'Sign in', onPressed: _signIn),
              const SizedBox(height: 20),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'New to Vital Band? ',
                      style: TextStyle(color: mutedInk),
                    ),
                    TextButton(
                      onPressed: widget.onSignUp,
                      child: const Text('Create account'),
                    ),
                  ],
                ),
              ),
              const DemoNote(),
            ],
          ),
        ),
      ),
    ),
  );
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    required this.onBack,
    required this.onAuthenticated,
    super.key,
  });

  final VoidCallback onBack;
  final ValueChanged<UserProfile> onAuthenticated;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _monitoredName = TextEditingController();
  final _deviceCode = TextEditingController();
  UserRole? _role;
  int _step = 0;
  bool _hidePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _monitoredName.dispose();
    _deviceCode.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0) {
      if (_role != null) setState(() => _step = 1);
    } else if (_step == 1) {
      if (_formKey.currentState!.validate()) setState(() => _step = 2);
    } else {
      final role = _role!;
      widget.onAuthenticated(
        UserProfile(
          name: _name.text.trim(),
          email: _email.text.trim(),
          role: role,
          monitoredName: role.monitorsSomeone
              ? (_monitoredName.text.trim().isEmpty
                    ? 'Monitored person'
                    : _monitoredName.text.trim())
              : _name.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_step) {
      0 => 'How will you use Vital Band?',
      1 => 'Create your account',
      _ =>
        _role!.monitorsSomeone
            ? 'Who are you looking after?'
            : 'Pair your band',
    };
    final subtitle = switch (_step) {
      0 => 'Choose the view that fits you. You can change this later.',
      1 => 'A few details to get your account ready.',
      _ =>
        _role!.monitorsSomeone
            ? 'Add the person and connect their upper-arm band.'
            : 'Connect your upper-arm band to start tracking.',
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 24, 8),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: _step == 0
                            ? 'Back to sign in'
                            : 'Previous step',
                        onPressed: _step == 0
                            ? widget.onBack
                            : () => setState(() => _step--),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const BrandMark(compact: true),
                      const Spacer(),
                      Text(
                        '${_step + 1} of 3',
                        style: const TextStyle(
                          color: mutedInk,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                          decoration: BoxDecoration(
                            color: index <= _step ? forest : line,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontSize: 27),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: const TextStyle(color: mutedInk, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      if (_step == 0) _buildRoles(),
                      if (_step == 1) _buildAccountForm(),
                      if (_step == 2) _buildPairingForm(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
                  child: Column(
                    children: [
                      PrimaryButton(
                        label: _step == 2 ? 'Enter demo app' : 'Continue',
                        onPressed: _step == 0 && _role == null ? null : _next,
                      ),
                      if (_step == 2)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: DemoNote(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoles() => Column(
    children: UserRole.values.map((role) {
      final selected = _role == role;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          key: Key('role-${role.name}'),
          onTap: () => setState(() => _role = role),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFEAF2E7) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? forest : line,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected ? forest : canvas,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    role.icon,
                    color: selected ? Colors.white : forest,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        role.description,
                        style: const TextStyle(color: mutedInk, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? forest : mutedInk,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList(),
  );

  Widget _buildAccountForm() => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Your name'),
        TextFormField(
          key: const Key('signup-name'),
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Name'),
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter your name' : null,
        ),
        const SizedBox(height: 17),
        const FieldLabel('Email address'),
        TextFormField(
          key: const Key('signup-email'),
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'you@example.com'),
          validator: (value) => value != null && value.contains('@')
              ? null
              : 'Enter a valid email address',
        ),
        const SizedBox(height: 17),
        const FieldLabel('Password'),
        TextFormField(
          key: const Key('signup-password'),
          controller: _password,
          obscureText: _hidePassword,
          decoration: InputDecoration(
            hintText: 'At least 8 characters',
            suffixIcon: IconButton(
              tooltip: _hidePassword ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
              icon: Icon(
                _hidePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          validator: (value) => value != null && value.length >= 8
              ? null
              : 'Use at least 8 characters',
        ),
      ],
    ),
  );

  Widget _buildPairingForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (_role!.monitorsSomeone) ...[
        const FieldLabel('Person to monitor'),
        TextField(
          key: const Key('monitored-name'),
          controller: _monitoredName,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Their name',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 18),
      ],
      const FieldLabel('Band pairing code'),
      TextField(
        key: const Key('device-code'),
        controller: _deviceCode,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(
          hintText: 'e.g. VB-2048',
          prefixIcon: Icon(Icons.watch_outlined),
        ),
      ),
      const SizedBox(height: 15),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2E7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: forest, size: 19),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'You can finish setup without a code and pair a device later. This prototype does not connect to a physical band.',
                style: TextStyle(color: ink, fontSize: 12.5, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class BrandMark extends StatelessWidget {
  const BrandMark({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: compact ? 36 : 44,
        height: compact ? 36 : 44,
        decoration: BoxDecoration(
          color: forest,
          borderRadius: BorderRadius.circular(compact ? 11 : 14),
        ),
        child: Icon(
          Icons.monitor_heart_rounded,
          color: lime,
          size: compact ? 21 : 25,
        ),
      ),
      const SizedBox(width: 10),
      Text(
        'vital band',
        style: TextStyle(
          color: ink,
          fontSize: compact ? 18 : 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label,
      style: const TextStyle(
        color: ink,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: forest,
        foregroundColor: Colors.white,
        disabledBackgroundColor: forest.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class DemoNote extends StatelessWidget {
  const DemoNote({super.key});

  @override
  Widget build(BuildContext context) => const Text(
    'DEMO MODE | Sample readings, no medical use',
    textAlign: TextAlign.center,
    style: TextStyle(
      color: mutedInk,
      fontSize: 10.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.35,
    ),
  );
}
