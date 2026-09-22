import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../services/api_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.clubName)),
      body: FutureBuilder<ClubDetail>(
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

          final club = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                club.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 20),
              if (club.hasMeeting) ...[
                _SectionTitle(title: 'Reuniões'),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule),
                  title: Text(club.meetingSchedule!),
                ),
                const SizedBox(height: 8),
              ],
              if (club.hasLocation) ...[
                _SectionTitle(title: 'Endereço'),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.place_outlined),
                  title: Text(club.address ?? 'Ver no mapa'),
                  subtitle: const Text('Toque para abrir no Google Maps'),
                  trailing: const Icon(Icons.map_outlined),
                  onTap: () => _openMaps(club),
                ),
                const SizedBox(height: 8),
              ],
              _SectionTitle(title: 'Presidente'),
              if (club.presidentName != null &&
                  club.presidentName!.trim().isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline),
                  title: Text(club.presidentName!),
                ),
              if (club.presidentPhone != null &&
                  club.presidentPhone!.trim().isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.phone_outlined),
                  title: Text(club.presidentPhone!),
                  subtitle: const Text('Toque para ligar'),
                  onTap: () {
                    final digits = club.presidentPhone!
                        .replaceAll(RegExp(r'[^\d+]'), '');
                    _launch(
                      Uri(scheme: 'tel', path: digits),
                      'Não foi possível abrir o discador.',
                    );
                  },
                ),
              if (club.presidentEmail != null &&
                  club.presidentEmail!.trim().isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.email_outlined),
                  title: Text(club.presidentEmail!),
                  subtitle: const Text('Toque para enviar e-mail'),
                  onTap: () {
                    _launch(
                      Uri(
                        scheme: 'mailto',
                        path: club.presidentEmail!.trim(),
                      ),
                      'Não foi possível abrir o e-mail.',
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
