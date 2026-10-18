/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Website: https://localwala.tech
 * Email: weworklocal1@gmail.com
 *
 * Proprietary and Confidential.
 *
 * This source code, including all associated assets,
 * APIs, databases, business logic, designs, and
 * documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution,
 * publication, resale, reverse engineering, or use of
 * this software without prior written authorization is
 * strictly prohibited.
 */

import 'package:flutter/material.dart';
import 'package:user/app/features/social/contact_sync_controller.dart';
import 'package:user/gen/l10n/app_localizations.dart';
import 'package:user/app/features/social/services/contacts_service.dart';

// TODO(l10n): move chrome strings below into app_*.arb.
//
// Standalone Settings → Privacy → Contacts screen. Mount it from the settings
// section; it owns its own state and needs nothing from the host page.
class SocialPrivacyView extends StatefulWidget {
  const SocialPrivacyView({super.key});

  @override
  State<SocialPrivacyView> createState() => _SocialPrivacyViewState();
}

class _SocialPrivacyViewState extends State<SocialPrivacyView> {
  final ContactSyncController _controller = ContactSyncController();
  bool? _findFriends;
  bool? _showActivity;
  String? _lastSyncText;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final privacy = await _controller.getPrivacy();
    final last = await _controller.lastSyncAt();
    if (!mounted) return;
    setState(() {
      _findFriends = (privacy?['findFriendsEnabled'] as bool?) ?? true;
      _showActivity = (privacy?['showActivityToContacts'] as bool?) ?? true;
      _lastSyncText = last?.toLocal().toString().split('.').first;
    });
  }

  Future<void> _setBusy(Future<void> Function() work) async {
    setState(() => _busy = true);
    try {
      await work();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(translate.contacts)),
      body: _findFriends == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: Text(translate.privacy_find_friends),
                  subtitle: Text(translate.privacy_find_friends_sub),
                  value: _findFriends!,
                  onChanged: _busy
                      ? null
                      : (value) => _setBusy(() async {
                          final ok = await _controller.updatePrivacy(
                            findFriendsEnabled: value,
                          );
                          if (!ok) return;
                          if (value) {
                            // Fresh opt-in syncs immediately instead of waiting 7 days.
                            await _controller.syncIfDue(force: true);
                          }
                          await _load();
                        }),
                ),
                SwitchListTile(
                  title: Text(translate.privacy_show_activity),
                  subtitle: Text(translate.privacy_show_activity_sub),
                  value: _showActivity!,
                  onChanged: _busy
                      ? null
                      : (value) => _setBusy(() async {
                          final ok = await _controller.updatePrivacy(
                            showActivityToContacts: value,
                          );
                          if (ok) await _load();
                        }),
                ),
                ListTile(
                  title: Text(translate.privacy_refresh),
                  subtitle: Text(
                    _lastSyncText == null
                        ? translate.privacy_never_synced
                        : translate.privacy_last_synced(_lastSyncText!),
                  ),
                  trailing: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  onTap: _busy
                      ? null
                      : () {
                          final messenger = ScaffoldMessenger.of(context);
                          _setBusy(() async {
                            final result = await _controller.syncIfDue(
                              force: true,
                            );
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  result.permission !=
                                          ContactsPermission.granted
                                      ? translate.privacy_permission_required
                                      : result.synced
                                      ? translate.privacy_found(
                                          result.matchedCount,
                                        )
                                      : translate.privacy_up_to_date,
                                ),
                              ),
                            );
                            await _load();
                          });
                        },
                ),
              ],
            ),
    );
  }
}
