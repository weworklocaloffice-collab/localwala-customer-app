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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/pages/account/referral_code/bloc/referral_code_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/unauthorized_widget.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class ReferralCodeScreen extends StatelessWidget {
  const ReferralCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => ReferralCodeBloc()..add(ReferralCodeInitialEvent()), child: const ReferralCodeView());
  }
}

class ReferralCodeView extends StatelessWidget {
  const ReferralCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<ReferralCodeBloc, ReferralCodeState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(translate.referral_code), scrolledUnderElevation: 0),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (state.status.isLoading) ...[
                  const ReferralCodeLoadingView(),
                ] else if (state.status.isFailure) ...[
                  const ReferralCodeErrorView(),
                ] else if (state.status.isUnAuthorizd) ...[
                  const UnauthorizedWidget(),
                ] else ...[
                  Image.asset(AssetsUrl.imageURL.referralCodeIcon, height: MediaQuery.of(context).size.height / 2, width: MediaQuery.of(context).size.width),
                  kAppSpacerVertical(height: 20),
                  Text(state.title, textAlign: TextAlign.center, style: kAppLblMediumFontBold(context)),
                  kAppSpacerVertical(height: 10),
                  Text(state.subTitle, textAlign: TextAlign.center, style: kAppLblTinyFontRegular(context)),
                  kAppSpacerVertical(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.shadow, borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [Text(state.referralCode, style: kAppLblTinyFontBold(context))],
                        ),
                      ),
                      kAppSpacerHorizontal(width: 10),
                      IconButton(
                        onPressed: () async {
                          showSuccessDialog(context, translate.copied);
                          await Clipboard.setData(ClipboardData(text: state.referralCode));
                        },
                        icon: Icon(Icons.copy_outlined, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).iconTheme.color),
                      ),
                    ],
                  ),
                  kAppSpacerVertical(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.read<ReferralCodeBloc>().add(ReferralCodeReferNowEvent()),
                      style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                      child: Text(translate.refer_now),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class ReferralCodeLoadingView extends StatelessWidget {
  const ReferralCodeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLine(
                  style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width / 1.5, borderRadius: BorderRadius.circular(8)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLine(
                  style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 1.5, borderRadius: BorderRadius.circular(8)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLine(style: SkeletonLineStyle(height: 8, width: 64, borderRadius: BorderRadius.circular(8))),
                const SizedBox(width: 5),
                SkeletonLine(style: SkeletonLineStyle(height: 8, width: 64, borderRadius: BorderRadius.circular(8))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLine(
                  style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 1.5, borderRadius: BorderRadius.circular(8)),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
        const SizedBox(height: 20),
        SkeletonLine(
          style: SkeletonLineStyle(height: 50, width: double.infinity, borderRadius: BorderRadius.circular(8)),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(10, (index) {
              return SkeletonAvatar(
                style: SkeletonAvatarStyle(width: 80, height: 30, padding: const EdgeInsets.symmetric(horizontal: 5), borderRadius: BorderRadius.circular(8)),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: List.generate(5, (index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          SkeletonLine(
                            style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(8)),
                          ),
                          const SizedBox(height: 5),
                          SkeletonLine(
                            style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(8)),
                          ),
                          const SizedBox(height: 5),
                          SkeletonLine(
                            style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(8)),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SkeletonLine(style: SkeletonLineStyle(height: 25, width: 25, borderRadius: BorderRadius.circular(8))),
                              const SizedBox(width: 10),
                              SkeletonLine(style: SkeletonLineStyle(height: 25, width: 25, borderRadius: BorderRadius.circular(8))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SkeletonAvatar(style: SkeletonAvatarStyle(width: 80, height: 80, borderRadius: BorderRadius.circular(10))),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class ReferralCodeErrorView extends StatelessWidget {
  const ReferralCodeErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.empty_data_two, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}
// Done //
