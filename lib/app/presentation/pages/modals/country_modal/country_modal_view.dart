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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:user/app/presentation/pages/modals/country_modal/bloc/country_code_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class CountryCodeModalScreen extends StatelessWidget {
  final String code;
  const CountryCodeModalScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CountryCodeModalBloc()..add(CountryCodeModalInitialEvent(code: code)),
      child: CountryCodeModalView(code: code),
    );
  }
}

class CountryCodeModalView extends StatelessWidget {
  final String code;
  const CountryCodeModalView({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<CountryCodeModalBloc, CountryCodeModalState>(
      listener: (context, state) {
        if (state.status.isSelected) {
          Navigator.of(context).pop({'action': true, 'flag': state.info.flag, 'dialCode': state.info.dialCode});
        } else if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: CupertinoSearchTextField(
              placeholder: translate.search_country,
              style: kAppLblMediumFontRegular(context),
              placeholderStyle: kAppLblMediumFontRegular(context),
              onChanged: (String value) {
                context.read<CountryCodeModalBloc>().add(CountryCodeModalSearchEvent(searchText: value));
              },
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () => Navigator.of(context).pop({'action': false, 'flag': state.info.flag, 'dialCode': state.info.dialCode}),
                icon: Icon(Icons.close_outlined, color: Theme.of(context).iconTheme.color),
              ),
            ],
          ),
          body: state.status.isLoading
              ? SkeletonListView(itemCount: 5)
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        state.countries.length,
                        (index) => InkWell(
                          onTap: () => context.read<CountryCodeModalBloc>().add(CountryCodeModalSelectEvent(selected: state.countries[index])),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [Text("${state.countries[index].flag} (${state.countries[index].dialCode}) ${state.countries[index].name}", style: kAppLblMediumFontMedium(context))],
                                ),
                                Icon(state.selectedCountries == state.countries[index].dialCode ? Icons.radio_button_checked_outlined : Icons.circle_outlined),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          bottomNavigationBar: SafeArea(
            child: SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop({'action': false, 'id': '', 'name': ''}),
                          style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).scaffoldBackgroundColor, foreColor: Theme.of(context).canvasColor, height: 50.0),
                          child: Text(translate.cancel_title),
                        ),
                      ),
                    ),
                    kAppSpacerHorizontal(width: 10),
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.selectedCountries.isNotEmpty ? () => context.read<CountryCodeModalBloc>().add(CountryCodeModalSaveEvent()) : null,
                          style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50),
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
// Done //
