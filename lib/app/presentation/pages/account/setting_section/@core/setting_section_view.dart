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
 * WeWorkLocal is a technology platform that connects
 * customers, vendors, service providers, and delivery
 * partners through a unified digital ecosystem.
 *
 * Core features include local commerce, food delivery,
 * service bookings, referral programs, wallet management,
 * real-time tracking, digital payments, and business
 * management solutions.
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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:user/app/presentation/pages/account/setting_section/@core/bloc/setting_section_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class SettingSectionScreen extends StatelessWidget {
  const SettingSectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SettingSectionBloc()..add(SettingSectionInitialEvent()),
      child: const SettingSectionView(),
    );
  }
}

class SettingSectionView extends StatelessWidget {
  const SettingSectionView({super.key});

  void openAppSettingsPage() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<SettingSectionBloc, SettingSectionState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(scrolledUnderElevation: 0),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeProvider.scaffoldPadding,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(translate.settings, style: kAppLblMediumFontBold(context)),
                Text(
                  "v${state.currentVersion}",
                  style: kAppLblTinyFontRegular(context),
                ),
                kAppSpacerVertical(height: 20),
                GestureDetector(
                  onTap: () => state.isAuthorized
                      ? Navigator.of(
                          context,
                        ).pushNamed(AppRouter.editProfileRoute)
                      : Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRouter.loginRoute,
                          (Route<dynamic> route) => false,
                        ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).disabledColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translate.profile_info,
                              style: kAppLblMediumFontBold(context),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Text(
                                translate.profile_info_sub_title,
                                style: kAppLblTinyFontRegular(context),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 13,
                          color: Theme.of(context).canvasColor,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => state.isAuthorized
                      ? Navigator.of(
                          context,
                        ).pushNamed(AppRouter.accountSettingAlertSettingRoute)
                      : Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRouter.loginRoute,
                          (Route<dynamic> route) => false,
                        ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).disabledColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translate.alert_pref,
                              style: kAppLblMediumFontBold(context),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Text(
                                translate.alert_pref_sub_title,
                                style: kAppLblTinyFontRegular(context),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 13,
                          color: Theme.of(context).canvasColor,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => state.isAuthorized
                      ? Navigator.of(
                          context,
                        ).pushNamed(AppRouter.appSettingRoute)
                      : Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRouter.loginRoute,
                          (Route<dynamic> route) => false,
                        ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).disabledColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translate.user_account,
                              style: kAppLblMediumFontBold(context),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Text(
                                translate.user_account_sub_title,
                                style: kAppLblTinyFontRegular(context),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 13,
                          color: Theme.of(context).canvasColor,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => state.isAuthorized
                      ? Navigator.of(
                          context,
                        ).pushNamed(AppRouter.socialPrivacyRoute)
                      : Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRouter.loginRoute,
                          (Route<dynamic> route) => false,
                        ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).disabledColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translate.contacts,
                              style: kAppLblMediumFontBold(context),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Text(
                                translate.contacts_sub_title,
                                style: kAppLblTinyFontRegular(context),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 13,
                          color: Theme.of(context).canvasColor,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    openAppSettingsPage();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).disabledColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translate.device_access,
                              style: kAppLblMediumFontBold(context),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Text(
                                translate.device_access_sub_title,
                                style: kAppLblTinyFontRegular(context),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 13,
                          color: Theme.of(context).canvasColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Done //
