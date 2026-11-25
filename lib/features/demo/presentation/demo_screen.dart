import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../core/settings/preferences.dart';
import '../../../core/widgets/status_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../authentication/data/firebase_auth_repository.dart';
import '../data/mock_repository.dart';
import '../domain/demo_repository.dart';

final demoRepositoryProvider = Provider<DemoRepository>(
  (ref) => const MockRepository(),
);
final demoCatalogProvider = FutureProvider(
  (ref) => ref.watch(demoRepositoryProvider).load(),
);

class DemoScreen extends ConsumerStatefulWidget {
  const DemoScreen({super.key, this.authenticated = false});

  final bool authenticated;

  @override
  ConsumerState<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends ConsumerState<DemoScreen> {
  final _saved = <String>{};
  int _tab = 0;
  String? _region;
  bool _signingOut = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final catalog = ref.watch(demoCatalogProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.brand),
        actions: [
          IconButton(
            tooltip: widget.authenticated ? strings.signOut : strings.signIn,
            icon: Icon(widget.authenticated ? Icons.logout : Icons.login),
            onPressed: _signingOut
                ? null
                : widget.authenticated
                ? () => _signOut(strings)
                : () => context.go('/login'),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: Chip(label: Text(strings.demo)),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _tab == 3
                ? const _Settings()
                : catalog.when(
                    data: (data) => _catalog(context, data, strings),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => StatusView(
                      icon: Icons.cloud_off_outlined,
                      title: strings.loadError,
                      action: FilledButton(
                        onPressed: () => ref.invalidate(demoCatalogProvider),
                        child: Text(strings.retry),
                      ),
                    ),
                  ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            label: strings.discover,
          ),
          NavigationDestination(
            icon: const Icon(Icons.meeting_room_outlined),
            label: strings.rooms,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_border),
            label: strings.favorites,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: strings.settings,
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(AppLocalizations strings) async {
    setState(() => _signingOut = true);
    try {
      final repository = await ref.read(authRepositoryProvider.future);
      await repository?.signOut();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.signOutFailed)));
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  Widget _catalog(
    BuildContext context,
    DemoCatalog data,
    AppLocalizations strings,
  ) {
    final theme = Theme.of(context);
    final profiles = data.profiles
        .where((row) => _region == null || row.region == _region)
        .toList();
    final rooms = data.rooms.where((row) {
      if (_tab == 2) return _saved.contains(row.id);
      return _region == null || row.region == _region;
    }).toList();
    final price = NumberFormat.currency(
      locale: strings.localeName,
      name: 'TRY',
      symbol: '₺',
      decimalDigits: 0,
    );
    final count = _tab == 0 ? profiles.length : rooms.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Text(strings.demoNotice, style: theme.textTheme.bodyMedium),
        ),
        if (_tab != 2)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: DropdownButtonFormField<String>(
              initialValue: _region ?? '',
              isExpanded: true,
              items: [
                DropdownMenuItem(value: '', child: Text(strings.allRegions)),
                for (final region in MockRepository.regions)
                  DropdownMenuItem(value: region, child: Text(region)),
              ],
              onChanged: (value) =>
                  setState(() => _region = value == '' ? null : value),
            ),
          ),
        Expanded(
          child: count == 0
              ? StatusView(icon: Icons.search_off, title: strings.empty)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: count,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (_tab == 0) {
                      final row = profiles[index];
                      final intent = switch (row.intent) {
                        UserIntent.hasRoom => strings.hasRoom,
                        UserIntent.needsRoom => strings.needsRoom,
                        UserIntent.findTogether => strings.findTogether,
                      };
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(row.name.substring(0, 1)),
                          ),
                          title: Text('${row.name}, ${row.age}'),
                          subtitle: Text('$intent\n${row.region}'),
                          isThreeLine: true,
                        ),
                      );
                    }
                    final room = rooms[index];
                    final saved = _saved.contains(room.id);
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.weekend_outlined),
                        ),
                        title: Text(
                          room.shared
                              ? strings.sharedRoom
                              : strings.privateRoom,
                        ),
                        subtitle: Text(
                          '${room.region}\n${price.format(room.rent)} · ${strings.monthly}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          tooltip: saved
                              ? strings.unsaveRoom
                              : strings.saveRoom,
                          icon: Icon(
                            saved ? Icons.bookmark : Icons.bookmark_border,
                          ),
                          onPressed: () => setState(() {
                            if (saved) {
                              _saved.remove(room.id);
                            } else {
                              _saved.add(room.id);
                            }
                          }),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _Settings extends ConsumerWidget {
  const _Settings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final state = ref.watch(preferencesProvider);
    final settings = state.value;
    final controller = ref.read(preferencesProvider.notifier);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (settings?.saveFailed == true) Text(strings.saveError),
        if (settings?.saving == true) const LinearProgressIndicator(),
        DropdownButtonFormField<bool>(
          key: ValueKey(settings?.english),
          decoration: InputDecoration(labelText: strings.language),
          initialValue: settings?.english ?? false,
          items: const [
            DropdownMenuItem(value: false, child: Text('Türkçe')),
            DropdownMenuItem(value: true, child: Text('English')),
          ],
          onChanged: settings?.saving == true
              ? null
              : (value) {
                  if (value != null) controller.setLanguage(value);
                },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ThemeMode>(
          key: ValueKey(settings?.theme),
          decoration: InputDecoration(labelText: strings.theme),
          initialValue: settings?.theme ?? ThemeMode.system,
          items: [
            DropdownMenuItem(
              value: ThemeMode.system,
              child: Text(strings.system),
            ),
            DropdownMenuItem(
              value: ThemeMode.light,
              child: Text(strings.light),
            ),
            DropdownMenuItem(value: ThemeMode.dark, child: Text(strings.dark)),
          ],
          onChanged: settings?.saving == true
              ? null
              : (value) {
                  if (value != null) controller.setTheme(value);
                },
        ),
      ],
    );
  }
}
