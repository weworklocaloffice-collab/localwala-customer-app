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
import 'package:user/app/presentation/pages/modals/food_instructions_modal/bloc/food_instructions_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class FoodInstructionsModalScreen extends StatelessWidget {
  final String instructions;
  const FoodInstructionsModalScreen({super.key, required this.instructions});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FoodInstructionsBloc()..add(FoodInstructionsInitialEvent(instructions: instructions)),
      child: FoodInstructionsModalView(instructions: instructions),
    );
  }
}

class FoodInstructionsModalView extends StatefulWidget {
  final String instructions;
  const FoodInstructionsModalView({super.key, required this.instructions});

  @override
  State<FoodInstructionsModalView> createState() => _FoodInstructionsModalViewState();
}

class _FoodInstructionsModalViewState extends State<FoodInstructionsModalView> {
  final TextEditingController instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    instructionsController.text = widget.instructions;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<FoodInstructionsBloc, FoodInstructionsState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            title: Text(translate.cooking_instructions_for_restaurant),
            actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: instructionsController,
                    maxLines: 3,
                    maxLength: 100,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                    decoration: kAppInputDecoration(context, lblText: translate.instructions, errText: null),
                    style: kAppLblSmallFontMedium(context),
                    onChanged: (value) => context.read<FoodInstructionsBloc>().add(FoodInstructionsChangeEvent(instructions: value)),
                  ),
                  kAppSpacerVertical(height: 10),
                  Text(translate.food_instruction_notice, style: kAppLblTinyFontRegular(context)),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(false),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [Text(translate.clear, style: kAppLblSmallFontBold(context, color: 'canvas'))],
                          ),
                        ),
                      ),
                    ),
                    const Expanded(flex: 1, child: SizedBox(width: double.infinity)),
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(state.instructions),
                        child: Container(
                          width: double.infinity,
                          height: 40.0,
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text(translate.save_btn, style: kAppLblSmallFontBoldCart(context))],
                          ),
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

