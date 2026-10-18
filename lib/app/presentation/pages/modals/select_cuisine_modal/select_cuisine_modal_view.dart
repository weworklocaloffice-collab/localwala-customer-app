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
import 'package:user/app/presentation/pages/modals/select_cuisine_modal/bloc/select_cuisine_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class SelectCuisineModalScreen extends StatelessWidget {
  final List<String> cuisine;
  const SelectCuisineModalScreen({super.key, required this.cuisine});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectCuisineModalBloc()..add(SelectCuisineModalInitialEvent(cuisine: cuisine)),
      child: const SelectCuisineModalView(),
    );
  }
}

class SelectCuisineModalView extends StatelessWidget {
  const SelectCuisineModalView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<SelectCuisineModalBloc, SelectCuisineModalState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isSaved) {
          Navigator.of(context, rootNavigator: true).pop({'action': true, 'ids': state.cuisineIds.join(','), 'names': state.cuisineNames.join(',')});
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(translate.select_cuisine),
            scrolledUnderElevation: 0,
            actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const SelectCuisineModalLoadingView(),
                ] else if (state.status.isFailure) ...[
                  const SelectCuisineModalErrorView(),
                ] else if (state.status.isEmpty) ...[
                  const SelectCuisineModalEmptyView(),
                ] else ...[
                  Column(
                    children: List.generate(
                      state.model.cuisine!.length,
                      (index) => GestureDetector(
                        onTap: () => context.read<SelectCuisineModalBloc>().add(SelectCuisineModalSelectEvent(id: state.model.cuisine![index].id!)),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          decoration: BoxDecoration(border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(state.model.cuisine![index].name!, style: kAppLblTinyFontBold(context)),
                              Icon(state.cuisineIds.contains(state.model.cuisine![index].id!) ? Icons.check_box : Icons.check_box_outline_blank_outlined, size: 12, color: Theme.of(context).primaryColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          bottomNavigationBar: state.status.isEmpty || state.status.isLoading || state.status.isFailure
              ? SafeArea(child: const SizedBox())
              : SafeArea(
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
                                onPressed: state.cuisineIds.isNotEmpty ? () => context.read<SelectCuisineModalBloc>().add(SelectCuisineModalSaveEvent()) : null,
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

class SelectCuisineModalLoadingView extends StatelessWidget {
  const SelectCuisineModalLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        10,
        (index) => Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          decoration: BoxDecoration(border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SkeletonLine(
                style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 1.3, borderRadius: BorderRadius.circular(8)),
              ),
              SkeletonLine(style: SkeletonLineStyle(height: 10, width: 20, borderRadius: BorderRadius.circular(8))),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectCuisineModalErrorView extends StatelessWidget {
  const SelectCuisineModalErrorView({super.key});

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

class SelectCuisineModalEmptyView extends StatelessWidget {
  const SelectCuisineModalEmptyView({super.key});

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
