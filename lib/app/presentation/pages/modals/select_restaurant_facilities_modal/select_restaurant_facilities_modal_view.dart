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
import 'package:user/app/presentation/pages/modals/select_restaurant_facilities_modal/bloc/select_restaurant_facilities_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class SelectRestaurantFacilitiesModalScreen extends StatelessWidget {
  final List<String> facilities;
  const SelectRestaurantFacilitiesModalScreen({super.key, required this.facilities});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectRestaurantFacilitiesModalBloc()..add(SelectRestaurantFacilitiesModalInitialEvent(facilities: facilities)),
      child: const SelectRestaurantFacilitiesModalView(),
    );
  }
}

class SelectRestaurantFacilitiesModalView extends StatelessWidget {
  const SelectRestaurantFacilitiesModalView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<SelectRestaurantFacilitiesModalBloc, SelectRestaurantFacilitiesModalState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isSaved) {
          Navigator.of(context, rootNavigator: true).pop({'action': true, 'ids': state.facilityIds.join(','), 'names': state.facilityNames.join(',')});
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            title: Text(translate.select_restaurant_facilities),
            actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const SelectRestaurantFacilitiesModalLoadingView(),
                ] else if (state.status.isFailure) ...[
                  const SelectRestaurantFacilitiesModalErrorView(),
                ] else if (state.status.isEmpty) ...[
                  const SelectRestaurantFacilitiesModalEmptyView(),
                ] else ...[
                  Column(
                    children: List.generate(
                      state.model.facility!.length,
                      (index) => GestureDetector(
                        onTap: () => context.read<SelectRestaurantFacilitiesModalBloc>().add(SelectRestaurantFacilitiesModalSelectEvent(id: state.model.facility![index].id!)),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          decoration: BoxDecoration(border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(state.model.facility![index].name!, style: kAppLblTinyFontBold(context)),
                              Icon(state.facilityIds.contains(state.model.facility![index].id!) ? Icons.check_box : Icons.check_box_outline_blank_outlined, size: 12, color: Theme.of(context).primaryColor),
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
                                onPressed: state.facilityIds.isNotEmpty ? () => context.read<SelectRestaurantFacilitiesModalBloc>().add(SelectRestaurantFacilitiesModalSaveEvent()) : null,
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

class SelectRestaurantFacilitiesModalLoadingView extends StatelessWidget {
  const SelectRestaurantFacilitiesModalLoadingView({super.key});

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

class SelectRestaurantFacilitiesModalErrorView extends StatelessWidget {
  const SelectRestaurantFacilitiesModalErrorView({super.key});

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

class SelectRestaurantFacilitiesModalEmptyView extends StatelessWidget {
  const SelectRestaurantFacilitiesModalEmptyView({super.key});

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
