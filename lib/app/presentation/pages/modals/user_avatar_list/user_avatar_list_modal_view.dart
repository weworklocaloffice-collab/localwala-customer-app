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
import 'package:user/app/presentation/pages/modals/user_avatar_list/bloc/user_avatar_list_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class UserAvatarListModalScreen extends StatelessWidget {
  const UserAvatarListModalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => UserAvatarListModalBloc()..add(UserAvatarListModalInitialEvent()), child: const UserAvatarListModalView());
  }
}

class UserAvatarListModalView extends StatelessWidget {
  const UserAvatarListModalView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<UserAvatarListModalBloc, UserAvatarListModalState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            title: Text(translate.choose_avatar),
            actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const UserAvatarListModalLoadingView(),
                ] else if (state.status.isFailure) ...[
                  const UserAvatarListModalErrorView(),
                ] else if (state.status.isEmpty) ...[
                  const UserAvatarListModalEmptyView(),
                ] else ...[
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
                      itemCount: state.model.avatar!.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => context.read<UserAvatarListModalBloc>().add(UserAvatarListModalSelectEvent(avatar: state.model.avatar![index].avatar!)),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 150,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              border: Border.all(color: state.selected == state.model.avatar![index].avatar! ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: 2),
                              shape: BoxShape.rectangle,
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                              child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150, imageUrl: state.model.avatar![index].avatar!),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: SizedBox(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).scaffoldBackgroundColor, foreColor: Theme.of(context).canvasColor, height: 40.0),
                          child: Text(translate.cancel_title),
                        ),
                      ),
                    ),
                    kAppSpacerHorizontal(width: 10),
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.selected.isNotEmpty ? () => Navigator.of(context).pop(state.selected) : null,
                          style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 40),
                          child: Text(translate.save_btn),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class UserAvatarListModalLoadingView extends StatelessWidget {
  const UserAvatarListModalLoadingView({super.key});

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

class UserAvatarListModalErrorView extends StatelessWidget {
  const UserAvatarListModalErrorView({super.key});

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

class UserAvatarListModalEmptyView extends StatelessWidget {
  const UserAvatarListModalEmptyView({super.key});

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
