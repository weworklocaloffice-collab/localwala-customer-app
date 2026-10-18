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
import 'package:user/app/presentation/pages/modals/language_translation_modal/bloc/language_translation_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';

class LanguageTranslationModalScreen extends StatelessWidget {
  final String selected;
  const LanguageTranslationModalScreen({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LanguageTranslationModalBloc()..add(LanguageTranslationModalInitialEvent(selected: selected)),
      child: const LanguageTranslationModalView(),
    );
  }
}

class LanguageTranslationModalView extends StatelessWidget {
  const LanguageTranslationModalView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LanguageTranslationModalBloc, LanguageTranslationModalState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            title: Text(state.title),
            actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: state.languages
                  .map(
                    (item) => Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => context.read<LanguageTranslationModalBloc>().add(LanguageTranslationModalChangeEvent(code: item.code)),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.shadow,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(item.code == state.selected ? Icons.radio_button_checked_sharp : Icons.radio_button_off, color: Theme.of(context).primaryColor, size: 13),
                                    kAppSpacerHorizontal(width: 5),
                                    Text(item.value, style: item.code == state.selected ? kAppLblMediumFontBold(context) : kAppLblMediumFontRegular(context, color: 'regular')),
                                  ],
                                ),
                                Image.asset(item.code == state.selected ? item.activeImage : item.deactiveImage, width: 100, height: 50.0, fit: BoxFit.fill),
                              ],
                            ),
                          ),
                        ),
                        item.code == state.selected
                            ? Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(item.description, style: kAppLblTinyFontRegular(context)),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  )
                  .toList(),
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
                          onPressed: () {
                            context.read<LanguageTranslationModalBloc>().add(LanguageTranslationModalSubmitEvent());
                            Navigator.of(context).pop(state.selected);
                          },
                          style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50),
                          child: Text(state.selectText),
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
