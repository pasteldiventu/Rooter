import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/rotary_theme.dart';
import '../widgets/rotary_widgets.dart';
import 'clubs_page.dart';

class AreasPage extends StatefulWidget {
  const AreasPage({super.key, required this.api});

  final ApiService api;

  @override
  State<AreasPage> createState() => _AreasPageState();
}

class _AreasPageState extends State<AreasPage> {
  late Future<List<Area>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.fetchAreas();
  }

  Future<void> _reload() {
    final future = widget.api.fetchAreas();
    setState(() {
      _future = future;
    });
    return future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Area>>(
        future: _future,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState != ConnectionState.done;
          final Widget child;
          if (!snapshot.hasData && loading) {
            child = const _BrandedLoading(key: ValueKey('loading'));
          } else if (!snapshot.hasData) {
            child = SafeArea(
              key: const ValueKey('error'),
              child: MessageView(
                icon: Icons.wifi_off_rounded,
                title: 'Não foi possível carregar as áreas',
                message: snapshot.error?.toString(),
                onRetry: _reload,
              ),
            );
          } else {
            child = _AreasContent(
              key: const ValueKey('content'),
              api: widget.api,
              areas: snapshot.data!,
              refreshing: loading,
              onRefresh: _reload,
            );
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: child,
          );
        },
      ),
    );
  }
}

class _BrandedLoading extends StatelessWidget {
  const _BrandedLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: RotaryTheme.background,
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            Container(
              width: 220,
              height: 220,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    RotaryTheme.gold.withValues(alpha: 0.16),
                    RotaryTheme.gold.withValues(alpha: 0),
                  ],
                ),
              ),
              child: const RotaryLogo(size: 112, radius: 32),
            ),
            const SizedBox(height: 4),
            Text('Distrito 4440', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              'Mato Grosso',
              style: theme.textTheme.titleMedium?.copyWith(
                color: RotaryTheme.gold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Encontre os clubes Rotary\ndo nosso estado',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: RotaryTheme.textMuted,
              ),
            ),
            const Spacer(flex: 3),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const SizedBox(
                width: 48,
                height: 4,
                child: LinearProgressIndicator(),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _AreasContent extends StatelessWidget {
  const _AreasContent({
    super.key,
    required this.api,
    required this.areas,
    required this.refreshing,
    required this.onRefresh,
  });

  final ApiService api;
  final List<Area> areas;
  final bool refreshing;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: RotaryTheme.gold,
        backgroundColor: RotaryTheme.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      const RotaryLogo(size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Distrito 4440',
                              style: theme.textTheme.titleLarge,
                            ),
                            Text(
                              'Mato Grosso',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: RotaryTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      refreshing
                          ? const SizedBox(
                              width: 44,
                              height: 44,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              ),
                            )
                          : CircleIconButton(
                              tooltip: 'Atualizar',
                              icon: Icons.refresh_rounded,
                              onPressed: onRefresh,
                            ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _HeroCard(areaCount: areas.length),
                  const SizedBox(height: 28),
                  SectionHeader(
                    title: 'Áreas',
                    trailing: '${areas.length} no total',
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            if (areas.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: MessageView(
                  icon: Icons.map_outlined,
                  title: 'Nenhuma área encontrada.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList.separated(
                  itemCount: areas.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final area = areas[index];
                    return _AreaCard(
                      area: area,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ClubsPage(api: api, area: area),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.areaCount});

  final int areaCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RotaryTheme.blue, Color(0xFF0E2A5C)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -40,
            bottom: -40,
            child: RotaryWheelMark(size: 180, opacity: 0.18),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Overline('Distrito · MT'),
                const SizedBox(height: 10),
                Text(
                  'Clubes Rotary de\nMato Grosso',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: Text(
                    'Este app cobre apenas o estado de MT. Escolha uma área para ver os clubes.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: RotaryTheme.gold,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$areaCount áreas',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({required this.area, required this.onTap});

  final Area area;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final governor = area.assistantGovernor;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  RotaryTheme.gold.withValues(alpha: 0.22),
                  RotaryTheme.gold.withValues(alpha: 0.08),
                ],
              ),
            ),
            child: Text(
              area.number.toString().padLeft(2, '0'),
              style: theme.textTheme.titleLarge?.copyWith(
                color: RotaryTheme.gold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(area.name, style: theme.textTheme.titleMedium),
                if (governor != null && governor.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Gov. Assistente',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: RotaryTheme.textMuted,
                    ),
                  ),
                  Text(
                    displayName(governor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: RotaryTheme.textPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          const ChevronBadge(),
        ],
      ),
    );
  }
}
