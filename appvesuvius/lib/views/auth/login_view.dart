import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_view_model.dart';

class _Constants {
    static const double maxCardWidth = 420.0;
    static const double maxRegisterWidth = 480.0;
    static const double cardElevation = 0.3;
    static const double cardPadding = 24.0;
    static const double spacingSmall = 8.0;
    static const double spacingMedium = 12.0;
    static const double spacingLarge = 16.0;
    static const double progressIndicatorSize = 18.0;
    static const double progressStrokeWidth = 2.0;
    static const double titleFontSize = 24.0;
    static const int minPasswordLength = 4;

    static const String appTitle = 'Vesuvivus';
    static const String emailLabel = 'Email';
    static const String passwordLabel = 'Kode';
    static const String nameLabel = 'Navn';
    static const String loginButton = 'Log ind';
    static const String registerButton = 'Opret konto';
    static const String createAccountLink = 'Opret en konto';
    static const String registerTitle = 'Registrer';
    static const String requiredError = 'Påkrævet';
    static const String passwordMinError = 'Min 8 tegn';
    static const String homeRoute = '/home';
}

class LoginView extends StatefulWidget {
    const LoginView({super.key});

    @override
    State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    @override
    void dispose() {
        _emailController.dispose();
        _passwordController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        final authViewModel = context.watch<AuthViewModel>();

        return Scaffold(
            body: SafeArea(
                child: SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                        ),
                        child: Center(
                            child: Padding(
                                padding: const EdgeInsets.all(_Constants.spacingLarge),
                                child: _buildLoginCard(authViewModel),
                            ),
                        ),
                    ),
                ),
            ),
        );
    }

    Widget _buildLoginCard(AuthViewModel authViewModel) {
        return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _Constants.maxCardWidth),
            child: Card(
                elevation: _Constants.cardElevation,
                child: Padding(
                    padding: const EdgeInsets.all(_Constants.cardPadding),
                    child: _buildLoginForm(authViewModel),
                ),
            ),
        );
    }

    Widget _buildLoginForm(AuthViewModel authViewModel) {
        return Form(
            key: _formKey,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    _buildTitle(),
                    const SizedBox(height: _Constants.spacingMedium),
                    _buildEmailField(),
                    const SizedBox(height: _Constants.spacingMedium),
                    _buildPasswordField(),
                    const SizedBox(height: _Constants.spacingLarge),
                    if (authViewModel.error != null) _buildErrorMessage(authViewModel.error!),
                    if (authViewModel.error != null) const SizedBox(height: _Constants.spacingSmall),
                    _buildLoginButton(authViewModel),
                    _buildRegisterLink(),
                ],
            ),
        );
    }

    Widget _buildTitle() {
        return const Text(
            _Constants.appTitle,
            style: TextStyle(
                fontSize: _Constants.titleFontSize,
                fontWeight: FontWeight.bold,
            ),
        );
    }

    Widget _buildEmailField() {
        return TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
                labelText: _Constants.emailLabel,
                border: OutlineInputBorder(),
            ),
            validator: _validateEmail,
        );
    }

    Widget _buildPasswordField() {
        return TextFormField(
            controller: _passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
                labelText: _Constants.passwordLabel,
                border: OutlineInputBorder(),
            ),
            validator: _validatePassword,
            onFieldSubmitted: (_) => _handleLogin(context.read<AuthViewModel>()),
        );
    }

    Widget _buildErrorMessage(String error) {
        return Text(
            error,
            style: TextStyle(
                color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
        );
    }

    Widget _buildLoginButton(AuthViewModel authViewModel) {
        return SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: authViewModel.busy ? null : () => _handleLogin(authViewModel),
                child: authViewModel.busy
                    ? const SizedBox(
                        height: _Constants.progressIndicatorSize,
                        width: _Constants.progressIndicatorSize,
                        child: CircularProgressIndicator(
                            strokeWidth: _Constants.progressStrokeWidth,
                        ),
                    )
                    : const Text(_Constants.loginButton),
            ),
        );
    }

    Widget _buildRegisterLink() {
        return TextButton(
            onPressed: () => _navigateToRegister(),
            child: const Text(_Constants.createAccountLink),
        );
    }

    String? _validateEmail(String? value) {
        if (value == null || value.trim().isEmpty) {
            return _Constants.requiredError;
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
            return 'Venligst indtast en gyldig email';
        }
        return null;
    }

    String? _validatePassword(String? value) {
        if (value == null || value.length < _Constants.minPasswordLength) {
            return _Constants.passwordMinError;
        }
        return null;
    }

    Future<void> _handleLogin(AuthViewModel authViewModel) async {
        if (!_formKey.currentState!.validate()) return;

        final success = await authViewModel.login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
        );

        if (success && mounted) {
            Navigator.of(context).pushReplacementNamed(_Constants.homeRoute);
        }
    }

    void _navigateToRegister() {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const _RegisterView()),
        );
    }
}

class _RegisterView extends StatefulWidget {
    const _RegisterView();

    @override
    State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    @override
    void dispose() {
        _nameController.dispose();
        _emailController.dispose();
        _passwordController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        final authViewModel = context.watch<AuthViewModel>();

        return Scaffold(
            appBar: AppBar(title: const Text(_Constants.registerTitle)),
            body: SafeArea(
                child: SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height - 
                                AppBar().preferredSize.height - 
                                MediaQuery.of(context).padding.top - 
                                MediaQuery.of(context).padding.bottom,
                        ),
                        child: Center(
                            child: Padding(
                                padding: const EdgeInsets.all(_Constants.cardPadding),
                                child: _buildRegisterForm(authViewModel),
                            ),
                        ),
                    ),
                ),
            ),
        );
    }

    Widget _buildRegisterForm(AuthViewModel authViewModel) {
        return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _Constants.maxRegisterWidth),
            child: Form(
                key: _formKey,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        _buildNameField(),
                        const SizedBox(height: _Constants.spacingMedium),
                        _buildEmailField(),
                        const SizedBox(height: _Constants.spacingMedium),
                        _buildPasswordField(),
                        const SizedBox(height: _Constants.spacingLarge),
                        if (authViewModel.error != null) _buildErrorMessage(authViewModel.error!),
                        if (authViewModel.error != null) const SizedBox(height: _Constants.spacingSmall),
                        _buildRegisterButton(authViewModel),
                    ],
                ),
            ),
        );
    }

    Widget _buildNameField() {
        return TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
                labelText: _Constants.nameLabel,
                border: OutlineInputBorder(),
            ),
            validator: _validateName,
        );
    }

    Widget _buildEmailField() {
        return TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
                labelText: _Constants.emailLabel,
                border: OutlineInputBorder(),
            ),
            validator: _validateEmail,
        );
    }

    Widget _buildPasswordField() {
        return TextFormField(
            controller: _passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
                labelText: _Constants.passwordLabel,
                border: OutlineInputBorder(),
            ),
            validator: _validatePassword,
            onFieldSubmitted: (_) => _handleRegister(context.read<AuthViewModel>()),
        );
    }

    Widget _buildErrorMessage(String error) {
        return Text(
            error,
            style: TextStyle(
                color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
        );
    }

    Widget _buildRegisterButton(AuthViewModel authViewModel) {
        return SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: authViewModel.busy ? null : () => _handleRegister(authViewModel),
                child: authViewModel.busy
                    ? const SizedBox(
                        height: _Constants.progressIndicatorSize,
                        width: _Constants.progressIndicatorSize,
                        child: CircularProgressIndicator(
                            strokeWidth: _Constants.progressStrokeWidth,
                        ),
                    )
                    : const Text(_Constants.registerButton),
            ),
        );
    }

    String? _validateName(String? value) {
        if (value == null || value.trim().isEmpty) {
            return _Constants.requiredError;
        }
        return null;
    }

    String? _validateEmail(String? value) {
        if (value == null || value.trim().isEmpty) {
            return _Constants.requiredError;
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
            return 'Venligst indtast en gyldig email';
        }
        return null;
    }

    String? _validatePassword(String? value) {
        if (value == null || value.length < _Constants.minPasswordLength) {
            return _Constants.passwordMinError;
        }
        return null;
    }

    Future<void> _handleRegister(AuthViewModel authViewModel) async {
        if (!_formKey.currentState!.validate()) return;

        final success = await authViewModel.register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text.trim(),
        );

        if (success && mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                _Constants.homeRoute,
                (route) => false,
            );
        }
    }
}