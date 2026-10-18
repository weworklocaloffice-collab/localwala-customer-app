import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:badges/badges.dart' as badges;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:user/app/env.dart';
import 'package:user/app/presentation/pages/home/@core/bloc/home_bloc.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/home_promo_banner_model.dart';
import 'package:user/app/presentation/pages/modals/language_translation_modal/language_translation_modal_view.dart';
import 'package:user/app/presentation/styles/app_localization/app_localization_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

bool isNumbericAddressTitle(String value) {
  if (value.isEmpty) return false;
  return num.tryParse(value) != null;
}

/// The home screen app bar, referred to as the "Silver App Bar" in the design boards.
///
/// [headerTheme] carries the admin supplied configuration. When it is `null`, or when it
/// paints nothing, this widget renders exactly as it did before the feature existed.
/// Media is never painted here - the app bar only ever takes a colour or a gradient.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeState state;
  final HomeAppBarTheme? headerTheme;

  /// Height the banner paints below this app bar.
  ///
  /// Only used to place the boundary between the two gradient slices. Passing the
  /// real height keeps the app bar's ramp in proportion with the banner's instead
  /// of being squeezed into a fallback guess.
  final double? bannerHeight;

  const HomeAppBar({super.key, required this.state, this.headerTheme, this.bannerHeight});

  /// Height of the search bar rendered in [AppBar.bottom].
  static const double searchBarHeight = HomeAppBarTheme.searchBarHeight;

  bool get _showLocation => headerTheme?.showLocation ?? true;
  bool get _showLanguageSelector => headerTheme?.showLanguageSelector ?? true;
  bool get _showNotificationIcon => headerTheme?.showNotificationIcon ?? true;

  /// Height of the pinned toolbar row.
  ///
  /// The admin supplies this as the banner's `collapsedHeight` (64px by default), which
  /// is the "Height (Collapsed)" field on the design board. With no banner configured the
  /// stock [kToolbarHeight] is kept so the screen is byte for byte what it was before the
  /// feature existed.
  double get _toolbarHeight => headerTheme?.collapsedHeight ?? kToolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(_toolbarHeight + searchBarHeight);

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    // Windowed so this box paints the top slice of the header sweep. The banner
    // below paints the remainder, which is what keeps the gradient continuous
    // across the two instead of restarting at their boundary.
    final Decoration? decoration = headerTheme?.windowedDecoration(0, headerTheme?.appBarGradientEnd(bannerHeight: bannerHeight) ?? 1);
    return AppBar(
      scrolledUnderElevation: 0,
      toolbarHeight: _toolbarHeight,
      backgroundColor: decoration == null ? null : Colors.transparent,
      flexibleSpace: decoration == null
          ? null
          : Container(decoration: decoration),
      title: !_showLocation
          ? const SizedBox.shrink()
          : InkWell(
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                AppRouter.locationSearchRoute,
                (Route<dynamic> route) => false,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.locationArrow,
                        size: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                      kAppSpacerHorizontal(width: 5),
                      Text(
                        isNumbericAddressTitle(state.addressTitle)
                            ? kAppAddressTitle(
                                context,
                                int.parse(state.addressTitle),
                              )
                            : state.addressTitle,
                        style: kAppLblMediumFontBold(context),
                      ),
                      kAppSpacerHorizontal(width: 5),
                      const FaIcon(FontAwesomeIcons.chevronDown, size: 12),
                    ],
                  ),
                  Text(
                    kAppTrimWord(state.addressSubTitle, 40),
                    style: kAppLblMediumFontBold(context),
                  ),
                ],
              ),
            ),
      actions: [
        if (_showLanguageSelector &&
            AppSupportedLanguagesModel.languages.isNotEmpty &&
            AppSupportedLanguagesModel.languages.length > 1)
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                isDismissible: false,
                enableDrag: false,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10.0),
                  ),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                builder: (BuildContext context) {
                  return FractionallySizedBox(
                    heightFactor: 0.7,
                    child: LanguageTranslationModalScreen(
                      selected: state.locale,
                    ),
                  );
                },
              ).then((value) {
                if (!context.mounted) return;
                if (value != null) {
                  if (value.toString() != state.locale) {
                    context.read<AppLocalizationBloc>().add(
                      ChangeAppLocalizationEvent(defaultLanguage: value),
                    );
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.bottomTabRoute,
                      (Route<dynamic> route) => false,
                      arguments: [0],
                    );
                  }
                }
              });
            },
            icon: FaIcon(
              FontAwesomeIcons.language,
              size: Theme.of(context).textTheme.titleSmall?.fontSize,
              color: Theme.of(context).iconTheme.color,
            ),
          )
        else
          const SizedBox(),
        if (_showNotificationIcon)
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 0, end: 3),
            showBadge: state.notificationCount > 0 ? true : false,
            badgeStyle: badges.BadgeStyle(
              badgeColor: Theme.of(context).primaryColor,
            ),
            badgeContent: Text(
              "${state.notificationCount}",
              style: kAppLblMediumFontSemiBoldWhite(context),
            ),
            child: IconButton(
              onPressed: () {
                context.read<HomeBloc>().add(HomeNotificationListClickEvent());
                Navigator.of(
                  context,
                ).pushNamed(AppRouter.notificationListRoute);
              },
              icon: const FaIcon(FontAwesomeIcons.bell),
            ),
          ),
      ],
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(searchBarHeight),
        child: Padding(
          padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
          child: InkWell(
            onTap: () => Navigator.of(context).pushNamed(AppRouter.searchRoute),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                  kAppSpacerHorizontal(width: 5),
                  Text(
                    translate.home_search_bar,
                    style: kAppLblMediumFontMediumGrey(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
