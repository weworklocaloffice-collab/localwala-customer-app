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
import 'package:user/app/presentation/pages/modals/dining_booking_request_modal/bloc/dining_booking_request_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class DiningBookingRequestModalScreen extends StatelessWidget {
  final String requestText;
  const DiningBookingRequestModalScreen({super.key, required this.requestText});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiningBookingRequestModalBloc()..add(DiningBookingRequestModalInitialEvent(instructions: requestText)),
      child: DiningBookingRequestModalView(requestText: requestText),
    );
  }
}

class DiningBookingRequestModalView extends StatefulWidget {
  final String requestText;
  const DiningBookingRequestModalView({super.key, required this.requestText});

  @override
  State<DiningBookingRequestModalView> createState() => _DiningBookingRequestModalViewState();
}

class _DiningBookingRequestModalViewState extends State<DiningBookingRequestModalView> {
  final TextEditingController _bookingInstructionController = TextEditingController();

  String requestTextMessage = '';
  String requestWord = '';

  @override
  void initState() {
    super.initState();
    _bookingInstructionController.text = widget.requestText;
    requestTextMessage = widget.requestText;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<DiningBookingRequestModalBloc, DiningBookingRequestModalState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            title: Text(translate.mention_any_special_request),
            actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kAppSpacerVertical(height: 10),
                TextField(
                  controller: _bookingInstructionController,
                  maxLines: 3,
                  maxLength: 100,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  decoration: kAppInputDecoration(context, lblText: translate.instructions, errText: null),
                  style: kAppLblSmallFontMedium(context),
                  onChanged: (value) => context.read<DiningBookingRequestModalBloc>().add(DiningBookingRequestModalInstructionsChangeEvent(instructions: value)),
                ),
                kAppSpacerVertical(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: Text(translate.refund_request_forwarded, maxLines: 3, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                ),
              ],
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
                        child: GestureDetector(
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
                      child: GestureDetector(
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

