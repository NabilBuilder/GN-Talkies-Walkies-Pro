import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/utilisateur.dart';
import 'home_screen.dart';
import '../l10n/app_localizations.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  RoleUtilisateur _selectedRole = RoleUtilisateur.chefDEquipe;

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _inscription() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final utilisateur = await _authService.inscription(
        nom: _nomController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );

      if (utilisateur != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.accountCreated),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(utilisateur: utilisateur),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Extract user-friendly message from AuthServiceException or fallback
        String message;
        if (e is AuthServiceException) {
          message = e.message;
        } else {
          message = '${AppLocalizations.of(context)!.error}: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getRoleLabel(RoleUtilisateur role) {
    switch (role) {
      case RoleUtilisateur.administrateurGeneral:
        return AppLocalizations.of(context)!.roleAdmin;
      case RoleUtilisateur.superviseur:
        return AppLocalizations.of(context)!.roleSupervisor;
      case RoleUtilisateur.chefDEquipe:
        return AppLocalizations.of(context)!.roleChefEquipe;
    }
  }

  IconData _getRoleIcon(RoleUtilisateur role) {
    switch (role) {
      case RoleUtilisateur.administrateurGeneral:
        return Icons.admin_panel_settings;
      case RoleUtilisateur.superviseur:
        return Icons.supervisor_account;
      case RoleUtilisateur.chefDEquipe:
        return Icons.groups;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createAccountTitle),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.settings_input_component,
                      size: 60,
                      color: Colors.white,
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gardnet - Talkie Walkie Pro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nomController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                    label: AppLocalizations.of(context)!.fullName,
                    icon: Icons.person,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.enterName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                    label: AppLocalizations.of(context)!.email,
                    icon: Icons.email,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.enterEmail;
                    }
                    if (!value.contains('@')) {
                      return AppLocalizations.of(context)!.invalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                    label: AppLocalizations.of(context)!.password,
                    icon: Icons.lock,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.enterPassword;
                    }
                    if (value.length < 6) {
                      return AppLocalizations.of(context)!.passwordTooShortWithMin;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.selectRole,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                RadioGroup<RoleUtilisateur>(
                  groupValue: _selectedRole,
                  onChanged: (value) {
                    setState(() => _selectedRole = value!);
                  },
                  child: Column(
                    children: RoleUtilisateur.values.map((role) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: RadioListTile<RoleUtilisateur>(
                          title: Text(
                            _getRoleLabel(role),
                            style: const TextStyle(color: Colors.white),
                          ),
                          secondary: Icon(
                            _getRoleIcon(role),
                            color: Colors.white70,
                          ),
                          value: role,
                          activeColor: Colors.red,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _inscription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            AppLocalizations.of(context)!.createAccountBtn.toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context)!.alreadyHaveAccount,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
    );
  }
}
