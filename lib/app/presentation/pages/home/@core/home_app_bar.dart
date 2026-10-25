import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:badges/badges.dart' as badges;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:user/app/env.dart';
import 'package:user/app/presentation/pages/home/@core/bloc/home_bloc.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/header_media_canvas.dart';
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
///
/// The media window, when there is one, is stacked BEHIND this app bar rather than inside
/// it. [AppBar.flexibleSpace] is laid out as `Positioned.fill(bottom: bottomPreferredSize
/// .height)`, so with the 55px search bar it only ever receives a 64px box - it can never
/// carry the toolbar row AND the search bar at once. Hosting the canvas there meant the
/// banner, which does get its full height, was sampling canvas rows the app bar never drew,
/// and 55px of artwork was skipped between the two surfaces.
///
/// Nothing about the layout below is altered by that: this [AppBar] is constructed exactly
/// as it always was, with the same toolbar height, the same `primary`, the same `bottom`
/// and the same title and actions, so the address, the bell and the language selector sit
/// in precisely the position they have always occupied.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeState state;
  final HomeAppBarTheme? headerTheme;

  /// Height the banner paints below this app bar.
  ///
  /// Only used to place the boundary between the two gradient slices. Passing the
  /// real height keeps the app bar's ramp in proportion with the banner's instead
  /// of being squeezed into a fallback guess.
  final double? bannerHeight;

  /// The banner whose media continues into this app bar, if any.
  final HomePromoBannerSpec? spec;

  /// The shared media canvas, or null when this bar paints no media.
  ///
  /// Computed by the caller and passed in, so this surface and the banner cannot disagree
  /// about the geometry.
  final HeaderMediaLayout? mediaLayout;
  /// Playback shared by both halves of a header, so the two windows show one frame.
  final AnimationController? mediaController;
  final ValueListenable<double>? parallax;

  /// Scroll offset driving the app bar's own translation.
  ///
  /// Read in `build` rather than held as a plain value so the bar follows the scroll
  /// without `home_view` having to rebuild around the whole `Scaffold` on every frame.
  final ValueListenable<double>? scrollOffset;

  const HomeAppBar({
    super.key,
    required this.state,
    this.headerTheme,
    this.bannerHeight,
    this.spec,
    this.mediaLayout,
    this.mediaController,
    this.parallax,
    this.scrollOffset,
  });

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

  /// Full height this app bar paints: the pinned toolbar row, and nothing else.
  ///
  /// The search bar no longer lives here. It was the only part of this bar that ever
  /// changed size, and because both it and the media canvas had to be re-measured every
  /// frame to stay in step, a single frame of disagreement opened a hole along the seam.
  /// A bar that never resizes cannot disagree with anything.
  ///
  /// `Scaffold` adds the status-bar inset on top of this, so the value here is the bar's
  /// content, not its slot.
  static double resolveRegionHeight(HomeAppBarTheme? theme) =>
      theme?.collapsedHeight ?? kToolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(_toolbarHeight);

  /// Whether the shared media is actually being painted behind this bar.
  bool get _sharesMedia => mediaLayout != null && (spec?.hasMedia ?? false);

  /// How strongly the configured background tints the media behind it.
  ///
  /// Deliberately small. The app bar's background is a LIGHT colour, so anything heavier
  /// stops being a tint and becomes a white sheet over the artwork - at 0.45 the media was
  /// barely visible and read as a milky layer rather than a picture. A light touch keeps
  /// the operator's colour perceptible as a hint without displacing the media, which is
  /// what they turned the media on to see.
  static const double mediaTintOpacity = 0.16;

  /// Scrim that keeps the address, the bell and the language selector readable.
  ///
  /// Built from the theme rather than fixed to black: this bar's content is themed, so it
  /// is dark in a light theme, and a black scrim under a light theme buried all three
  /// controls in the darkened artwork.

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    // Windowed so this box paints the top slice of the header sweep. The banner
    // below paints the remainder, which is what keeps the gradient continuous
    // across the two instead of restarting at their boundary.
    final Decoration? decoration = headerTheme?.windowedDecoration(0, headerTheme?.appBarGradientEnd(bannerHeight: bannerHeight) ?? 1);
    // When the media is behind this bar it IS the surface, so the bar goes transparent
    // and its colour/gradient decoration is dropped rather than stacked over it.
    final bool sharesMedia = _sharesMedia;
    final Widget appBar = AppBar(
      scrolledUnderElevation: 0,
      toolbarHeight: _toolbarHeight,
      backgroundColor: sharesMedia || decoration != null
          ? Colors.transparent
          : null,
      // When the media is behind this bar it IS the surface, so the decoration is NOT
      // painted here. `flexibleSpace` sits UNDER the title and actions but ABOVE the
      // media that now sits behind the whole bar, so an opaque gradient dropped in here
      // simply buried the media again - which is what made clearing the gradient look
      // like it "did nothing". The decoration is painted as an overlay in the stack below
      // instead, where the operator can actually see and tune it.
      flexibleSpace: sharesMedia || decoration == null
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
    );

    if (!sharesMedia) return appBar;

    // Behind the bar, never inside it. `Positioned.fill` sizes this to the slot the
    // `Scaffold` reserved, which is the full canvas slice the banner samples the other
    // end of.
    final Widget bar = Stack(
      children: [
// Identical layering to `HomePromoBanner`: the configured colour or gradient is the
              // BACKGROUND, painted behind the media, and the media covers it.
              //
              // It used to be an `Opacity` layer over the artwork instead, tinted towards
              // the operator's colour. That produced a milky white sheet rather than a
              // picture: the app bar's background is a light colour, so any opacity
              // meaningful enough to see it also washes the media out. The banner never
              // had that problem because it was always painted behind, and matching it is
              // both correct and what makes the two surfaces look like one header.
              Positioned.fill(
                child: decoration == null
                    ? const SizedBox.shrink()
                    : Container(decoration: decoration),
              ),
              Positioned.fill(
                child: HeaderMediaCanvasWindow(
                  spec: spec!,
                  layout: mediaLayout!,
                  window: HeaderMediaWindow.top,
                  // From the LAYOUT, so this window is exactly the slice the banner's window
                  // is measured against and the two cannot drift apart.
                  width: mediaLayout!.width,
                  height: mediaLayout!.appBarHeight,
                  mediaController: mediaController,
                  parallax: parallax,
                ),
              ),
        appBar,
      ],
    );

    // Leave with the page.
    //
    // `Scaffold` pins its app bar slot at `Offset.zero` in every scroll position, so this
    // is what makes the bar scroll away instead of standing still.
    //
    // It is the SAME offset the banner is scrolling by, which is what preserves the shared
    // media: at offset N the bar shows canvas rows [N, N + slotHeight] where it used to
    // show [0, slotHeight], and the banner's window starts at N + appBarHeight. The two
    // still meet exactly where they did. Moving the bar by any other amount - or moving
    // only the artwork - would pull them apart.
    final double slotHeight =
        preferredSize.height + MediaQuery.paddingOf(context).top;
    final double hidden =
        (scrollOffset?.value ?? 0).clamp(0.0, slotHeight).toDouble();
    if (hidden <= 0) return sharesMedia ? bar : appBar;
    return Transform.translate(
      offset: Offset(0, -hidden),
      child: sharesMedia ? bar : appBar,
    );
  }
}
