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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/env.dart';
import 'package:user/app/presentation/pages/modals/language_translation_modal/language_translation_modal_view.dart';
import 'package:user/app/presentation/pages/welcome/bloc/welcome_bloc.dart';
import 'package:user/app/presentation/styles/app_localization/app_localization_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/theme_bloc/theme_bloc.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => WelcomeBloc()..add(WelcomeInitialEvent()), child: const WelcomeView());
  }
}

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  PageController pageController = PageController(initialPage: 0, viewportFraction: 1);
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<WelcomeBloc, WelcomeState>(
      listener: (context, state) {
        if (state.status.isAppLocale) {
          context.read<AppLocalizationBloc>().add(ChangeAppLocalizationEvent(defaultLanguage: state.locale));
        } else if (state.status.isUnAuthorized) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (Route<dynamic> route) => false);
        } else if (state.status.isHome) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [0]);
        } else if (state.status.isLocation) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.initialLocationRoute, (Route<dynamic> route) => false);
        } else if (state.status.isFailure) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.serverErrorRoute, (Route<dynamic> route) => false);
        } else if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.read<ThemeBloc>().add(ChangeThemeEvent()),
              icon: Icon(Icons.light_mode, color: Theme.of(context).iconTheme.color),
            ),
            scrolledUnderElevation: 0,
            actions: <Widget>[
              AppSupportedLanguagesModel.languages.isNotEmpty && AppSupportedLanguagesModel.languages.length > 1
                  ? IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          isDismissible: false,
                          enableDrag: false,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          builder: (BuildContext context) {
                            return FractionallySizedBox(heightFactor: 0.7, child: LanguageTranslationModalScreen(selected: state.locale));
                          },
                        ).then((value) {
                          if (!context.mounted) return;
                          if (value != null) {
                            if (value.toString() != state.locale) {
                              context.read<AppLocalizationBloc>().add(ChangeAppLocalizationEvent(defaultLanguage: value));
                              context.read<WelcomeBloc>().add(WelcomeLanguageChangeEvent(locale: value));
                            }
                          }
                        });
                      },
                      icon: FaIcon(FontAwesomeIcons.language, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).iconTheme.color),
                    )
                  : const SizedBox.shrink(),
              currentPageIndex != 4
                  ? TextButton(
                      onPressed: () => context.read<WelcomeBloc>().add(WelcomeSubmitEvent()),
                      child: Text(translate.skip, style: kAppLblMediumFontBold(context)),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PageDotsIndicator(currentIndex: currentPageIndex, total: 5),
              kAppSpacerVertical(height: 12),
              CircleNextButton(
                progress: (currentPageIndex + 1) / 5,
                onTap: () {
                  if (currentPageIndex < 4) {
                    pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  } else {
                    context.read<WelcomeBloc>().add(WelcomeSubmitEvent());
                  }
                },
              ),
            ],
          ),
          body: PageView.builder(
            itemCount: 5,
            controller: pageController,
            scrollDirection: Axis.horizontal,
            onPageChanged: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (currentPageIndex == 0) ...[
                      Image.asset(AssetsUrl.imageURL.welcomeOne, height: 230),
                      kAppSpacerVertical(height: 20),
                      Text(translate.welcome_title_one, textAlign: TextAlign.center, style: kAppLblLargeFontBold(context)),
                      kAppSpacerVertical(height: 5),
                      Text(translate.welcome_subtitle_one, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
                    ] else if (currentPageIndex == 1) ...[
                      Image.asset(AssetsUrl.imageURL.welcomeTwo, height: 230),
                      kAppSpacerVertical(height: 20),
                      Text(translate.welcome_title_two, textAlign: TextAlign.center, style: kAppLblLargeFontBold(context)),
                      kAppSpacerVertical(height: 5),
                      Text(translate.welcome_subtitle_two, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
                    ] else if (currentPageIndex == 2) ...[
                      Image.asset(AssetsUrl.imageURL.welcomeThree, height: 230),
                      kAppSpacerVertical(height: 20),
                      Text(translate.welcome_title_three, textAlign: TextAlign.center, style: kAppLblLargeFontBold(context)),
                      kAppSpacerVertical(height: 5),
                      Text(translate.welcome_subtitle_three, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
                    ] else if (currentPageIndex == 3) ...[
                      Image.asset(AssetsUrl.imageURL.welcomeFour, height: 230),
                      kAppSpacerVertical(height: 20),
                      Text(translate.welcome_title_four, textAlign: TextAlign.center, style: kAppLblLargeFontBold(context)),
                      kAppSpacerVertical(height: 5),
                      Text(translate.welcome_subtitle_four, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
                    ] else if (currentPageIndex == 4) ...[
                      Image.asset(AssetsUrl.imageURL.welcomeFive, height: 230),
                      kAppSpacerVertical(height: 20),
                      Text(translate.welcome_title_five, textAlign: TextAlign.center, style: kAppLblLargeFontBold(context)),
                      kAppSpacerVertical(height: 5),
                      Text(translate.welcome_subtitle_five, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class CircleNextButton extends StatelessWidget {
  final VoidCallback onTap;
  final double progress;

  const CircleNextButton({super.key, required this.onTap, required this.progress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 52,
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(end: progress),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              builder: (context, value, _) {
                return SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(value: value, strokeWidth: 4, backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2), valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor)),
                );
              },
            ),

            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
              child: Icon(progress >= 1 ? Icons.check_rounded : Icons.arrow_forward_ios_rounded, color: Theme.of(context).scaffoldBackgroundColor, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class PageDotsIndicator extends StatelessWidget {
  final int currentIndex;
  final int total;

  const PageDotsIndicator({super.key, required this.currentIndex, required this.total});

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Theme.of(context).primaryColor;
    final Color inactiveColor = activeColor.withValues(alpha: 0.3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final bool isActive = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 10 : 6,
          height: isActive ? 10 : 6,
          decoration: BoxDecoration(color: isActive ? activeColor : inactiveColor, shape: BoxShape.circle),
        );
      }),
    );
  }
}

