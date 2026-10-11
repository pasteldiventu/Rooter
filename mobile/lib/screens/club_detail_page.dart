import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/rotary_theme.dart';
import '../widgets/rotary_widgets.dart';

class ClubDetailPage extends StatefulWidget {
  const ClubDetailPage({
    super.key,
    required this.api,
    required this.clubId,
    required this.clubName,
  });

  final ApiService api;
  final String clubId;
  final String clubName;

  @override
  State<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailPageState extends State<ClubDetailPage> {
  static const double _heroHeight = 260;

  late Future<ClubDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.fetchClub(widget.clubId);
  }

  void _reload() {
    setState(() {
      _future = widget.api.fetchClub(widget.clubId);
    });
  }

  Future<void> _openMaps(ClubDetail club) async {
    final Uri uri;
    if (club.latitude != null && club.longitude != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${club.latitude},${club.longitude}',
      );
    } else if (club.address != null && club.address!.trim().isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(club.address!)}',
      );
    } else {
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o Google Maps.')),
      );
    }
  }

  Future<void> _launch(Uri uri, String errorMessage) async {
    final ok = await launchUrl(uri);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  void _call(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
    _launch(
      Uri(scheme: 'tel', path: digits),
      'Não foi possível abrir o discador.',
    );
  }

  void _email(String email) {
    _launch(
      Uri(scheme: 'mailto', path: email.trim()),
      'Não foi possível abrir o e-mail.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ClubDetail>(
        future: _future,
        builder: (context, snapshot) {
          final Widget content;
          if (snapshot.connectionState != ConnectionState.done) {
            content = const SliverFillRemaining(
              hasScrollBody: false,
              child: LoadingView(),
            );
          } else if (snapshot.hasError) {
            content = SliverFillRemaining(
              hasScrollBody: false,
              child: MessageView(
                icon: Icons.wifi_off_rounded,
                title: 'Não foi possível carregar o clube',
                message: snapshot.error.toString(),
                onRetry: _reload,
              ),
            );
          } else {
            content = SliverPadding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                32 + MediaQuery.paddingOf(context).bottom,
              ),
              sliver: SliverList.list(
                children: _buildDetails(context, snapshot.data!),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              _HeroAppBar(title: widget.clubName, height: _heroHeight),
              content,
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildDetails(BuildContext context, ClubDetail club) {
    final theme = Theme.of(context);
    final phone = _nonEmpty(club.presidentPhone);
    final email = _nonEmpty(club.presidentEmail);
    final president = _nonEmpty(club.presidentName);
    final hasActions = phone != null || email != null || club.hasLocation;

    return [
      const Overline('Rotary Club'),
      const SizedBox(height: 6),
      Text(club.name, style: theme.textTheme.headlineMedium),
      const SizedBox(height: 20),
      if (hasActions) ...[
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _QuickAction(
                  icon: Icons.call_rounded,
                  label: 'Ligar',
                  onTap: phone == null ? null : () => _call(phone),
                ),
                const VerticalDivider(width: 1),
                _QuickAction(
                  icon: Icons.mail_rounded,
                  label: 'E-mail',
                  onTap: email == null ? null : () => _email(email),
                ),
                const VerticalDivider(width: 1),
                _QuickAction(
                  icon: Icons.map_rounded,
                  label: 'Mapa',
                  onTap: club.hasLocation ? () => _openMaps(club) : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
      if (club.hasMeeting) ...[
        AppCard(
          child: _InfoRow(
            icon: Icons.schedule_rounded,
            label: 'Reuniões',
            value: club.meetingSchedule!,
          ),
        ),
        const SizedBox(height: 16),
      ],
      if (club.hasLocation) ...[
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoRow(
                icon: Icons.place_rounded,
                label: 'Endereço',
                value: club.address ?? 'Localização disponível no mapa',
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _openMaps(club),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Ver no mapa'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
      AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: RotaryTheme.blue,
                    foregroundColor: Colors.white,
                    child: president == null
                        ? const Icon(Icons.person_rounded)
                        : Text(
                            initials(president),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Overline(
                          'Presidente',
                          color: RotaryTheme.textMuted,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          president == null
                              ? 'Não informado'
                              : displayName(president),
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (phone != null) ...[
              const Divider(height: 1),
              _ContactRow(
                icon: Icons.phone_outlined,
                value: phone,
                hint: 'Toque para ligar',
                onTap: () => _call(phone),
              ),
            ],
            if (email != null) ...[
              const Divider(height: 1),
              _ContactRow(
                icon: Icons.email_outlined,
                value: email,
                hint: 'Toque para enviar e-mail',
                onTap: () => _email(email),
              ),
            ],
          ],
        ),
      ),
    ];
  }

  static String? _nonEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}

class _HeroAppBar extends StatelessWidget {
  const _HeroAppBar({required this.title, required this.height});

  final String title;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      pinned: true,
      expandedHeight: height,
      backgroundColor: RotaryTheme.background,
      automaticallyImplyLeading: false,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: CircleIconButton(
            tooltip: 'Voltar',
            icon: Icons.arrow_back_rounded,
            background: RotaryTheme.background.withValues(alpha: 0.6),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = MediaQuery.paddingOf(context).top;
          final minExtent = top + kToolbarHeight;
          final maxExtent = top + height;
          final expanded = ((constraints.maxHeight - minExtent) /
                  (maxExtent - minExtent))
              .clamp(0.0, 1.0);
          final heroOpacity = ((expanded - 0.3) / 0.7).clamp(0.0, 1.0);
          final titleOpacity = ((0.45 - expanded) / 0.3).clamp(0.0, 1.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: heroOpacity,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [RotaryTheme.blue, RotaryTheme.background],
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Positioned(
                        right: -60,
                        top: -20,
                        child: RotaryWheelMark(size: 240, opacity: 0.08),
                      ),
                      Align(
                        alignment: const Alignment(0, 0.35),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(34),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const RotaryLogo(size: 120, radius: 34),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 72,
                right: 72,
                top: top,
                height: kToolbarHeight,
                child: Opacity(
                  opacity: titleOpacity,
                  child: Center(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = enabled ? RotaryTheme.gold : RotaryTheme.textMuted;
    return Expanded(
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: RotaryTheme.textPrimary,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconBadge(icon: icon),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Overline(label, color: RotaryTheme.textMuted),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.value,
    required this.hint,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            IconBadge(icon: icon, size: 40),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: RotaryTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const ChevronBadge(),
          ],
        ),
      ),
    );
  }
}
