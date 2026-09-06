import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'auth_provider.dart';

enum ApplicationType { coreAxis, furniFlow }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@coreaxis.com');
  final _passwordController = TextEditingController(text: 'password');
  final _tenantController = TextEditingController(text: 'SYSTEM_TENANT');
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  ApplicationType _selectedApp = ApplicationType.coreAxis;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tenantController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.toLowerCase();
      
      // Front-end mock validation for access control
      if (_selectedApp == ApplicationType.coreAxis) {
        if (!email.contains('coreaxis.com')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access Denied: ERP Platform is restricted to CoreAxis ERP members only.'), backgroundColor: Colors.red),
          );
          return;
        }
      } else {
        if (!email.contains('furniflow.com')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access Denied: Furniture Manufacturing App is restricted to FurniFlow admins only.'), backgroundColor: Colors.red),
          );
          return;
        }
      }

      setState(() => _isLoading = true);
      
      try {
        await ref.read(authProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
          _tenantController.text,
        );
        if (mounted) {
          if (_selectedApp == ApplicationType.coreAxis) {
            context.go('/platform/home');
          } else {
            context.go('/dashboard');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              if (isDesktop) _buildLeftPanel(context),
              Expanded(child: _buildRightPanel(context)),
            ],
          ),
          // Environment Badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DEV ENVIRONMENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.amber.shade900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: -1, end: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context) {
    final theme = Theme.of(context);
    final isCoreAxis = _selectedApp == ApplicationType.coreAxis;
    
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isCoreAxis 
              ? [theme.colorScheme.primary, theme.colorScheme.primary.withBlue(150).withRed(100)]
              : [Colors.teal.shade700, Colors.teal.shade900],
          ),
        ),
        child: Stack(
          children: [
            // Background Illustration (Abstract Pattern)
            Positioned(
              right: -100,
              top: -50,
              child: Opacity(
                opacity: 0.1,
                child: Transform.rotate(
                  angle: -math.pi / 8,
                  child: Icon(isCoreAxis ? LucideIcons.boxes : LucideIcons.sofa, size: 400, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              left: -50,
              bottom: -50,
              child: Opacity(
                opacity: 0.05,
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Icon(isCoreAxis ? LucideIcons.barChart2 : LucideIcons.hammer, size: 300, color: Colors.white),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(isCoreAxis ? LucideIcons.boxes : LucideIcons.sofa, size: 40, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isCoreAxis ? 'CoreAxis' : 'FurniFlow',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCoreAxis ? 'Enterprise ERP Platform' : 'Furniture Manufacturing',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ).animate(key: ValueKey('${_selectedApp.name}_title')).fadeIn().slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 24),
                      Text(
                        isCoreAxis 
                          ? 'Streamline your business operations with a comprehensive suite for sales, manufacturing, logistics, and master data management.'
                          : 'Manage your furniture production, custom designs, workshop queues, and delivery pipelines with ease.',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ).animate(key: ValueKey('${_selectedApp.name}_desc')).fadeIn(),
                    ],
                  ),
                  
                  Text(
                    '© 2026 ${isCoreAxis ? 'CoreAxis ERP' : 'FurniFlow'} v2.0',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            elevation: isDesktop ? 8 : 0,
            color: isDesktop ? theme.colorScheme.surface : Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 48.0 : 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isDesktop) ...[
                      Icon(_selectedApp == ApplicationType.coreAxis ? LucideIcons.boxes : LucideIcons.sofa, size: 48, color: theme.colorScheme.primary),
                      const SizedBox(height: 24),
                    ],
                    
                    // App Selector
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _selectedApp = ApplicationType.coreAxis;
                                _emailController.text = 'admin@coreaxis.com';
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedApp == ApplicationType.coreAxis ? theme.colorScheme.surface : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: _selectedApp == ApplicationType.coreAxis ? [
                                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                                  ] : null,
                                ),
                                child: Center(
                                  child: Text('CoreAxis ERP', style: TextStyle(
                                    fontWeight: _selectedApp == ApplicationType.coreAxis ? FontWeight.bold : FontWeight.normal,
                                    color: _selectedApp == ApplicationType.coreAxis ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                                  )),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _selectedApp = ApplicationType.furniFlow;
                                _emailController.text = 'admin@furniflow.com';
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedApp == ApplicationType.furniFlow ? theme.colorScheme.surface : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: _selectedApp == ApplicationType.furniFlow ? [
                                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                                  ] : null,
                                ),
                                child: Center(
                                  child: Text('FurniFlow App', style: TextStyle(
                                    fontWeight: _selectedApp == ApplicationType.furniFlow ? FontWeight.bold : FontWeight.normal,
                                    color: _selectedApp == ApplicationType.furniFlow ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                                  )),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    Text(
                      'Welcome Back',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to access your dashboard',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    TextFormField(
                      controller: _tenantController,
                      decoration: InputDecoration(
                        labelText: 'Tenant ID',
                        prefixIcon: const Icon(LucideIcons.building),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required field' : null,
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 20),
                    
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(LucideIcons.mail),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                        return null;
                      },
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 20),
                    
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(LucideIcons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        if (v.length < 6) return 'Password too short';
                        return null;
                      },
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 16),
                    
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (val) => setState(() => _rememberMe = val ?? false),
                            ),
                            Text('Remember Me', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                        TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: const Text('Forgot Password?'),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms),
                    
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9)),
                    
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Don\'t have an account?', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                        TextButton(onPressed: () {}, child: const Text('Contact IT')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

