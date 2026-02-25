import 'package:flutter/material.dart';

/// Cricket screen - Placeholder for future implementation
class CricketScreen extends StatelessWidget {
  const CricketScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('CRICKET'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7CFC00).withOpacity(0.3),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                Icons.sports_cricket,
                size: 100,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 40),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF7CFC00), Color(0xFF9AFF00)],
              ).createShader(bounds),
              child: Text(
                'COMING SOON',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cricket section is under development',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
