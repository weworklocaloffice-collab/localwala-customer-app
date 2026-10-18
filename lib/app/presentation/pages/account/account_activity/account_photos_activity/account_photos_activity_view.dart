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
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/pages/account/account_activity/account_photos_activity/bloc/account_photos_activity_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class AccountPhotosActivityScreen extends StatelessWidget {
  const AccountPhotosActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => AccountPhotosActivityBloc()..add(AccountPhotosActivityInitialEvent()), child: const AccountPhotosActivityView());
  }
}

class AccountPhotosActivityView extends StatefulWidget {
  const AccountPhotosActivityView({super.key});

  @override
  State<AccountPhotosActivityView> createState() => _AccountPhotosActivityViewState();
}

class _AccountPhotosActivityViewState extends State<AccountPhotosActivityView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<AccountPhotosActivityBloc, AccountPhotosActivityState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.status.isLoading) ...[
                const AccountPhotosActivityLoadingView(),
              ] else if (state.status.isFailure) ...[
                const AccountPhotosActivityErrorView(),
              ] else if (state.status.isEmpty) ...[
                const AccountPhotosActivityEmptyView(),
              ] else ...[
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
                    itemCount: state.model.results!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Theme.of(context).disabledColor, width: 2),
                          shape: BoxShape.rectangle,
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                          child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150, imageUrl: state.model.results![index].path!),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class AccountPhotosActivityLoadingView extends StatelessWidget {
  const AccountPhotosActivityLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        10,
        (index) => Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: SkeletonLine(
                  style: SkeletonLineStyle(height: 150.0, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(8)),
                ),
              ),
              kAppSpacerHorizontal(width: 10),
              Expanded(
                child: SkeletonLine(
                  style: SkeletonLineStyle(height: 150.0, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(8)),
                ),
              ),
              kAppSpacerHorizontal(width: 10),
              Expanded(
                child: SkeletonLine(
                  style: SkeletonLineStyle(height: 150.0, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountPhotosActivityErrorView extends StatelessWidget {
  const AccountPhotosActivityErrorView({super.key});

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

class AccountPhotosActivityEmptyView extends StatelessWidget {
  const AccountPhotosActivityEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.cartEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.matching_record_not_found, textAlign: TextAlign.center, style: kAppLblMediumFontBold(context)),
          kAppSpacerVertical(height: 5),
          Text(translate.no_data_reason_one, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}
// Done //
