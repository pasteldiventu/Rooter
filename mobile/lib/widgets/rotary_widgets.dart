import 'package:flutter/material.dart';

import '../theme/rotary_theme.dart';

const _lowercaseWords = {'de', 'da', 'do', 'das', 'dos', 'e'};

/// Converte nomes em CAIXA ALTA para "Nome Próprio"; outros ficam como estão.
String displayName(String value) {
  final clean = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (clean != clean.toUpperCase()) return clean;
  final words = clean.toLowerCase().split(' ');
  return [
    for (var i = 0; i < words.length; i++)
      if (i > 0 && _lowercaseWords.contains(words[i]))
        words[i]
      else if (words[i].isEmpty)
        words[i]
      else
        words[i][0].toUpperCase() + words[i].substring(1),
  ].join(' ');
}

String initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty && !_lowercaseWords.contains(p.toLowerCase()))
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

class RotaryLogo extends StatelessWidget {
  const RotaryLogo({super.key, this.size = 48, this.radius});

  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? size * 0.28),
      child: Image.asset(
        'assets/images/rotary_logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

/// Apenas a roda dourada da logo, sem o fundo azul (útil como marca d'água).
class RotaryWheelMark extends StatelessWidget {
  const RotaryWheelMark({super.key, this.size = 120, this.opacity = 1});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final r = (RotaryTheme.gold.r * 255).roundToDouble();
    final g = (RotaryTheme.gold.g * 255).roundToDouble();
    final b = (RotaryTheme.gold.b * 255).roundToDouble();
    return Opacity(
      opacity: opacity,
      child: ColorFiltered(
        // Alfa derivado do canal vermelho: dourado fica opaco, azul some.
        colorFilter: ColorFilter.matrix([
          0, 0, 0, 0, r, //
          0, 0, 0, 0, g, //
          0, 0, 0, 0, b, //
          2.2, 0, 0, 0, -90, //
        ]),
        child: Image.asset(
          'assets/images/rotary_logo.png',
          width: size,
          height: size,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(RotaryTheme.radius),
      side: const BorderSide(color: RotaryTheme.outline),
    );
    return Material(
      color: RotaryTheme.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.background = RotaryTheme.surface,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: background,
        foregroundColor: RotaryTheme.textPrimary,
        fixedSize: const Size(44, 44),
        side: const BorderSide(color: RotaryTheme.outline),
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.size = 44,
    this.color = RotaryTheme.gold,
  });

  final IconData icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

class ChevronBadge extends StatelessWidget {
  const ChevronBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: RotaryTheme.surfaceHigh,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.chevron_right_rounded,
        color: RotaryTheme.textMuted,
        size: 20,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: RotaryTheme.textMuted,
            ),
          ),
      ],
    );
  }
}

class Overline extends StatelessWidget {
  const Overline(this.text, {super.key, this.color = RotaryTheme.gold});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }
}

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBadge(icon: icon, size: 64),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: RotaryTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar de novo'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
