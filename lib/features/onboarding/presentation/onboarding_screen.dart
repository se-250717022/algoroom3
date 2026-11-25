import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/preferences.dart';
import '../../../l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final preferences = ref.watch(preferencesProvider).value!;
    final theme = Theme.of(context);
    final sections = [
      (
        Icons.people_alt_rounded,
        strings.onboardPeople,
        strings.onboardPeopleBody,
      ),
      (Icons.weekend_rounded, strings.onboardRooms, strings.onboardRoomsBody),
      (Icons.forum_rounded, strings.onboardMatch, strings.onboardMatchBody),
    ];
    final last = _page == sections.length - 1;

    void finish() => ref.read(preferencesProvider.notifier).finishOnboarding();

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.brand),
        actions: [
          TextButton(
            onPressed: preferences.saving ? null : finish,
            child: Text(strings.skip),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: sections.length,
                    onPageChanged: (page) => setState(() => _page = page),
                    itemBuilder: (context, index) {
                      final (icon, title, body) = sections[index];
                      return LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: (constraints.maxHeight - 48)
                                      .clamp(0.0, double.infinity)
                                      .toDouble(),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 68,
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      foregroundColor:
                                          theme.colorScheme.onPrimaryContainer,
                                      child: Icon(icon, size: 64),
                                    ),
                                    const SizedBox(height: 32),
                                    Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      body,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LinearProgressIndicator(
                        value: (_page + 1) / sections.length,
                      ),
                      const SizedBox(height: 16),
                      if (preferences.saveFailed) Text(strings.saveError),
                      FilledButton(
                        onPressed: preferences.saving
                            ? null
                            : () {
                                if (last) {
                                  finish();
                                } else if (MediaQuery.disableAnimationsOf(
                                  context,
                                )) {
                                  _pages.jumpToPage(_page + 1);
                                } else {
                                  _pages.nextPage(
                                    duration: const Duration(milliseconds: 240),
                                    curve: Curves.easeOut,
                                  );
                                }
                              },
                        child: Text(last ? strings.begin : strings.next),
                      ),
                    ],
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
