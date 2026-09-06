import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum RuntimeStateType {
  suspended,
  unauthorized,
  noSolution,
  error
}

class RuntimeStateScreen extends StatelessWidget {
  final RuntimeStateType stateType;
  final String? message;

  const RuntimeStateScreen({
    Key? key, 
    required this.stateType,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title;
    String description;
    IconData icon;
    Color color;

    switch (stateType) {
      case RuntimeStateType.suspended:
        title = 'Solution Suspended';
        description = message ?? 'Your Customer Solution is currently suspended. Please contact platform administration.';
        icon = Icons.block;
        color = Colors.orange;
        break;
      case RuntimeStateType.unauthorized:
        title = 'Access Denied';
        description = message ?? 'You do not have permission to access this module or route.';
        icon = Icons.security;
        color = Colors.red;
        break;
      case RuntimeStateType.noSolution:
        title = 'No Active Solution';
        description = message ?? 'We could not find an active Customer Solution for your account.';
        icon = Icons.search_off;
        color = Colors.grey;
        break;
      case RuntimeStateType.error:
        title = 'Runtime Error';
        description = message ?? 'An unexpected error occurred in the workspace runtime.';
        icon = Icons.error_outline;
        color = Colors.red;
        break;
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 64, color: color),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      if (stateType == RuntimeStateType.unauthorized) {
                        context.go('/');
                      } else {
                        // For no solution/suspended, they might need to go to platform home or logout
                        context.go('/login');
                      }
                    },
                    child: Text(stateType == RuntimeStateType.unauthorized ? 'Return Home' : 'Back to Login'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
