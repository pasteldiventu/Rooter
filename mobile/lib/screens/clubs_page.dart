import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/api_service.dart';
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

  void _reload() {
    setState(() {
      _future = widget.api.fetchClubsByArea(widget.area.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.area.name)),
      body: FutureBuilder<List<ClubSummary>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(snapshot.error.toString(), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _reload,
                      child: const Text('Tentar de novo'),
                    ),
                  ],
                ),
              ),
            );
          }

          final clubs = snapshot.data ?? const [];
          if (clubs.isEmpty) {
            return const Center(child: Text('Nenhum clube nesta área.'));
          }

          return ListView.separated(
            itemCount: clubs.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final club = clubs[index];
              return ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: Text(club.name),
                trailing: const Icon(Icons.chevron_right),
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
          );
        },
      ),
    );
  }
}
