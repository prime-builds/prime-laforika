import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/features/auth/auth.dart';
import 'package:laforika/features/profile/data/profile_dtos.dart';
import 'package:laforika/features/profile/presentation/profile_controller.dart';
import 'package:laforika/features/profile/presentation/profile_error_mapper.dart';
import 'package:laforika/features/profile/presentation/profile_header.dart';
import 'package:laforika/features/profile/presentation/profile_validation.dart';
import 'package:laforika/features/shell/shell.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

typedef ProfileDockItemsBuilder =
    List<ShellDockItem> Function(AppLocalizations l10n);
typedef ProfileDockSelected =
    void Function(BuildContext context, String dockId);
typedef ProfileHeaderAction = void Function(BuildContext context);

/// Guest-first Profile: direct phone OTP when unauthenticated; editor when signed in.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({
    super.key,
    required this.dockItems,
    required this.onDockSelected,
    required this.onSettings,
    required this.onNotifications,
  });

  final ProfileDockItemsBuilder dockItems;
  final ProfileDockSelected onDockSelected;
  final ProfileHeaderAction onSettings;
  final ProfileHeaderAction onNotifications;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    final authenticated = auth is AuthAuthenticated;

    return AppShellScaffold(
      scaffoldKey: const Key('profile_screen'),
      dockItems: widget.dockItems(l10n),
      dockSelectedId: ShellDockIds.profile,
      onDockSelected: (id) => widget.onDockSelected(context, id),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeader(
            title: l10n.profileTitle,
            settingsTooltip: l10n.profileSettingsTooltip,
            notificationsTooltip: l10n.profileNotificationsTooltip,
            onSettings: () => widget.onSettings(context),
            onNotifications: () => widget.onNotifications(context),
          ),
          Expanded(
            child: authenticated
                ? const _AuthenticatedProfileBody()
                : _GuestProfileBody(l10n: l10n),
          ),
        ],
      ),
    );
  }
}

class _GuestProfileBody extends StatelessWidget {
  const _GuestProfileBody({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        key: const Key('profile_guest_auth'),
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppTokens.spaceLg,
          AppTokens.spaceMd,
          AppTokens.spaceLg,
          AppShellScaffold.dockBottomInset + AppTokens.spaceLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.profileGuestIntro,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppTokens.spaceLg),
            const PhoneAuthPanel(key: Key('profile_phone_auth_panel')),
          ],
        ),
      ),
    );
  }
}

class _AuthenticatedProfileBody extends ConsumerWidget {
  const _AuthenticatedProfileBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncProfile = ref.watch(profileControllerProvider);

    return asyncProfile.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsetsDirectional.all(AppTokens.spaceLg),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) {
        final failure = error is Failure
            ? error
            : const UnknownFailure(message: 'profile_load');
        return ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppTokens.spaceLg,
            AppTokens.spaceLg,
            AppTokens.spaceLg,
            AppShellScaffold.dockBottomInset + AppTokens.spaceLg,
          ),
          children: [
            Text(mapProfileFailure(l10n, failure), textAlign: TextAlign.center),
            const SizedBox(height: AppTokens.spaceMd),
            FilledButton(
              onPressed: () =>
                  ref.read(profileControllerProvider.notifier).reload(),
              child: Text(l10n.profileRetry),
            ),
          ],
        );
      },
      data: (profile) {
        if (profile == null) {
          return const SizedBox.shrink();
        }
        return _ProfileEditor(profile: profile);
      },
    );
  }
}

class _ProfileEditor extends ConsumerStatefulWidget {
  const _ProfileEditor({required this.profile});

  final ProfileDto profile;

  @override
  ConsumerState<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends ConsumerState<_ProfileEditor> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  String? _error;
  String? _success;
  bool _saving = false;
  bool _logoutPending = false;
  bool _initializedForAccount = false;
  String? _boundAccountId;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _bindFromProfile(widget.profile);
  }

  @override
  void didUpdateWidget(covariant _ProfileEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.profile;
    if (next.accountId != _boundAccountId) {
      _bindFromProfile(next);
      return;
    }
    // After successful save, sync controllers when not dirty.
    if (!_isDirty && !_saving) {
      _syncControllersIfServerChanged(next);
    }
  }

  void _bindFromProfile(ProfileDto profile) {
    _boundAccountId = profile.accountId;
    _firstNameController.text = profile.firstName ?? '';
    _lastNameController.text = profile.lastName ?? '';
    _emailController.text = profile.email ?? '';
    _initializedForAccount = true;
    _error = null;
    _success = null;
  }

  void _syncControllersIfServerChanged(ProfileDto profile) {
    final first = profile.firstName ?? '';
    final last = profile.lastName ?? '';
    final email = profile.email ?? '';
    if (_firstNameController.text != first) {
      _firstNameController.text = first;
    }
    if (_lastNameController.text != last) {
      _lastNameController.text = last;
    }
    if (_emailController.text != email) {
      _emailController.text = email;
    }
  }

  bool get _isDirty {
    final p = widget.profile;
    return normalizeProfileName(_firstNameController.text) != (p.firstName) ||
        normalizeProfileName(_lastNameController.text) != (p.lastName) ||
        normalizeProfileEmail(_emailController.text) != (p.email);
  }

  bool get _clientValid => isValidProfileDraft(
    firstName: _firstNameController.text,
    lastName: _lastNameController.text,
    email: _emailController.text,
  );

  Future<void> _save() async {
    if (_saving || !_isDirty || !_clientValid) return;
    setState(() {
      _saving = true;
      _error = null;
      _success = null;
    });
    final request = PatchProfileRequest(
      firstName: normalizeProfileName(_firstNameController.text),
      lastName: normalizeProfileName(_lastNameController.text),
      email: normalizeProfileEmail(_emailController.text),
      includeFirstName: true,
      includeLastName: true,
      includeEmail: true,
    );
    final l10n = AppLocalizations.of(context);
    final result = await ref
        .read(profileControllerProvider.notifier)
        .save(request);
    if (!mounted) return;
    result.when(
      success: (_) {
        setState(() {
          _saving = false;
          _success = l10n.profileSaved;
        });
      },
      failure: (failure) {
        setState(() {
          _saving = false;
          _error = mapProfileFailure(l10n, failure);
        });
      },
    );
  }

  Future<void> _logout() async {
    if (_logoutPending) return;
    setState(() => _logoutPending = true);
    try {
      await ref.read(authControllerProvider.notifier).logout();
    } finally {
      if (mounted) {
        setState(() => _logoutPending = false);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final profile = widget.profile;
    final canSave =
        _initializedForAccount &&
        !_saving &&
        !_logoutPending &&
        _isDirty &&
        _clientValid;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppTokens.spaceLg,
          AppTokens.spaceMd,
          AppTokens.spaceLg,
          AppShellScaffold.dockBottomInset + AppTokens.spaceLg,
        ),
        children: [
          Center(
            child: Semantics(
              label: l10n.profileAvatarSemantic,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          TextField(
            key: const Key('profile_first_name'),
            controller: _firstNameController,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
            decoration: InputDecoration(labelText: l10n.profileFirstNameLabel),
            onChanged: (_) => setState(() {
              _success = null;
            }),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          TextField(
            key: const Key('profile_last_name'),
            controller: _lastNameController,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.familyName],
            decoration: InputDecoration(labelText: l10n.profileLastNameLabel),
            onChanged: (_) => setState(() {
              _success = null;
            }),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          InputDecorator(
            key: const Key('profile_phone'),
            decoration: InputDecoration(
              labelText: l10n.profilePhoneLabel,
              enabled: false,
              suffixIcon: profile.phoneVerified
                  ? Icon(
                      Icons.verified,
                      color: theme.colorScheme.primary,
                      semanticLabel: l10n.profilePhoneVerified,
                    )
                  : null,
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                toPersianDigits(profile.phone),
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.end,
              ),
            ),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          TextField(
            key: const Key('profile_email'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: l10n.profileEmailLabel,
              helperText: profile.emailVerified
                  ? l10n.profileEmailVerified
                  : l10n.profileEmailUnverified,
            ),
            onChanged: (_) => setState(() {
              _success = null;
            }),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          FilledButton(
            key: const Key('profile_save'),
            onPressed: canSave ? _save : null,
            child: Text(_saving ? l10n.profileSaving : l10n.profileSave),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppTokens.spaceMd),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          if (_success != null) ...[
            const SizedBox(height: AppTokens.spaceMd),
            Text(_success!, style: TextStyle(color: theme.colorScheme.primary)),
          ],
          const SizedBox(height: AppTokens.spaceXl),
          OutlinedButton(
            key: const Key('profile_account_security'),
            onPressed: (_logoutPending || _saving)
                ? null
                : () => context.go(accountSecurityRoutePath),
            child: Text(l10n.accountSecurityAction),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          TextButton(
            key: const Key('profile_logout'),
            onPressed: (_logoutPending || _saving) ? null : _logout,
            child: Text(l10n.authLogout),
          ),
        ],
      ),
    );
  }
}

String toPersianDigits(String input) {
  const latin = '0123456789';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  final buffer = StringBuffer();
  for (final char in input.split('')) {
    final index = latin.indexOf(char);
    buffer.write(index >= 0 ? persian[index] : char);
  }
  return buffer.toString();
}
