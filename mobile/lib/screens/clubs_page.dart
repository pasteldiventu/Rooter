import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/rotary_theme.dart';
import '../widgets/rotary_widgets.dart';
import 'club_detail_page.dart';

class ClubsPage extends StatefulWidget {
  const ClubsPage({super.key, required this.api, required this.area});

  final ApiService api;
  final Area area;

  @override
  State<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  late Future<List<ClubSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.fetchClubsByArea(widget.area.id);
  }

  Future<void> _reload() {
    final future = widget.api.fetchClubsByArea(widget.area.id);
    setState(() {
      _future = future;
    });
    return future;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final governor = widget.area.assistantGovernor;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<ClubSummary>>(
          future: _future,
          builder: (context, snapshot) {
            final loading = snapshot.connectionState != ConnectionState.done;
            final clubs = snapshot.data;

            final header = Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleIconButton(
                        tooltip: 'Voltar',
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      if (clubs != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: RotaryTheme.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            clubs.length == 1
                                ? '1 clube'
                                : '${clubs.length} clubes',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: RotaryTheme.gold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Overline('Clubes da área'),
                  const SizedBox(height: 6),
                  Text(
                    widget.area.name,
                    style: theme.textTheme.headlineMedium,
                  ),
                  if (governor != null && governor.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Gov. Assistente: ${displayName(governor)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: RotaryTheme.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  OfflineBanner(listenable: widget.api.usingOfflineData),
                ],
              ),
            );

            final Widget body;
            if (clubs == null && loading) {
              body = const SliverFillRemaining(
                hasScrollBody: false,
                child: LoadingView(),
              );
            } else if (clubs == null) {
              body = SliverFillRemaining(
                hasScrollBody: false,
                child: MessageView(
                  icon: Icons.wifi_off_rounded,
                  title: 'Não foi possível carregar os clubes',
                  message: snapshot.error?.toString(),
                  onRetry: _reload,
                ),
              );
            } else if (clubs.isEmpty) {
              body = const SliverFillRemaining(
                hasScrollBody: false,
                child: MessageView(
                  icon: Icons.groups_outlined,
                  title: 'Nenhum clube nesta área.',
                ),
              );
            } else {
              body = SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList.separated(
                  itemCount: clubs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final club = clubs[index];
                    return _ClubCard(
                      club: club,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ClubDetailPage(
                              api: widget.api,
                              clubId: club.id,
                              clubName: club.name,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _reload,
              color: RotaryTheme.gold,
              backgroundColor: RotaryTheme.surface,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: header),
                  body,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ClubCard extends StatelessWidget {
  const _ClubCard({required this.club, required this.onTap});

  final ClubSummary club;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const RotaryLogo(size: 60, radius: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Overline('Rotary Club', color: RotaryTheme.textMuted),
                const SizedBox(height: 4),
                Text(
                  club.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
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
