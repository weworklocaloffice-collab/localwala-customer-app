import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/app/core/config/api_endpoints.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/home_response_model.dart';
import 'package:user/app/presentation/pages/home/@core/bloc/header_banner_bloc.dart';
import 'package:user/app/presentation/pages/home/@core/bloc/home_bloc.dart';
import 'package:user/app/presentation/pages/home/@core/business_verticals.dart';
import 'package:user/app/presentation/pages/home/@core/home_app_bar.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/business_vertical_strip.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/home_promo_banner.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/home_promo_banner_model.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/split_refresh.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class VerticalHeaderScaffold extends StatefulWidget {
  const VerticalHeaderScaffold({
    super.key,
    required this.vertical,
    required this.onRefresh,
    required this.slivers,
    this.extraActions,
    this.leading,
    this.drawer,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
  });

  final String vertical;
  final Future<void> Function() onRefresh;
  final List<Widget> slivers;
  final List<Widget>? extraActions;
  final Widget? leading;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  @override
  State<VerticalHeaderScaffold> createState() => _VerticalHeaderScaffoldState();
}

class _VerticalHeaderScaffoldState extends State<VerticalHeaderScaffold>
    with SingleTickerProviderStateMixin {
  late final HeaderBannerBloc _headerBannerBloc;
  late final HomeBloc _homeBloc;
  late final ScrollController _scrollController;

  StreamSubscription<HomeState>? _homeSubscription;
  AnimationController? _headerMediaController;
  final ValueNotifier<double> _headerParallax = ValueNotifier<double>(0);

  double _headerParallaxRange = 0;
  double _headerParallaxBase = 0;
  static const double _parallaxRate = 0.35;
  static const double _parallaxFallbackRange = 0.18;

  String? _cityId;
  bool _headerFallbackRequested = false;
  int _headerRequestId = 0;

  @override
  void initState() {
    super.initState();
    _headerBannerBloc = HeaderBannerBloc();
    _homeBloc = HomeBloc();
    _scrollController = ScrollController();
    _homeSubscription = _homeBloc.stream.listen(_onHomeState);
    _homeBloc.add(HomeInitialEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _homeSubscription?.cancel();
    _scrollController.dispose();
    _headerMediaController?.dispose();
    _headerParallax.dispose();
    _headerBannerBloc.close();
    _homeBloc.close();
    super.dispose();
  }

  void _onHomeState(HomeState state) {
    final String? cityId = state.homeData.city?.id;
    if (cityId == null || cityId.isEmpty) {
      if (!_headerFallbackRequested &&
          (state.status.isSuccess ||
              state.status.isEmpty ||
              state.status.isFailure)) {
        _headerFallbackRequested = true;
        _loadHeaderBanner();
      }
      return;
    }
    if (cityId == _cityId) return;
    _cityId = cityId;
    _loadHeaderBanner(cityId);
  }

  Future<void> _loadHeaderBanner([String? cityId]) async {
    final int requestId = ++_headerRequestId;
    final String? effectiveCityId = cityId ?? _cityId;
    try {
      final String cityQuery =
          effectiveCityId == null || effectiveCityId.isEmpty
          ? ''
          : '&city=${Uri.encodeQueryComponent(effectiveCityId)}';
      final response = await ApiRequestService().get(
        '${ApiEndPoints.v1request.headerBannerResolve}'
        '?vertical=${Uri.encodeQueryComponent(widget.vertical)}$cityQuery',
      );
      if (!mounted || requestId != _headerRequestId) return;
      if (!response.success) return;
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return;
      final dynamic banner = decoded['banner'];
      final HeaderBannerModel? model = banner is Map<String, dynamic>
          ? HeaderBannerModel.fromJson(banner, 'en')
          : null;
      _headerBannerBloc.add(HeaderBannerUpdatedEvent(headerBanner: model));
    } catch (_) {}
  }

  void _onScroll() {
    if (_headerParallaxRange <= 0) return;
    final double offset = _scrollController.hasClients
        ? _scrollController.offset
        : 0;
    _headerParallax.value =
        _headerParallaxBase +
        (offset * _parallaxRate).clamp(
          -_headerParallaxRange,
          _headerParallaxRange,
        );
  }

  Future<void> _refresh() async {
    _homeBloc.add(HomePullRefreshEvent());
    await widget.onRefresh();
    await _loadHeaderBanner(_cityId);
  }

  void _onVerticalSelected(BusinessVertical vertical) {
    switch (vertical.id) {
      case BusinessVerticalId.stores:
        Navigator.of(context).pushNamed(AppRouter.storesHomeRoute);
        break;
      case BusinessVerticalId.services:
        Navigator.of(context).pushNamed(AppRouter.localServicesHomeRoute);
        break;
      case BusinessVerticalId.meat:
        Navigator.of(context).pushNamed(AppRouter.jhatkaHomeRoute);
        break;
      case BusinessVerticalId.realEstate:
        Navigator.of(context).pushNamed(AppRouter.reHomeRoute);
        break;
      case BusinessVerticalId.dairy:
        Navigator.of(context).pushNamed(AppRouter.dairyHomeRoute);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<HomeBloc>.value(value: _homeBloc),
        BlocProvider<HeaderBannerBloc>.value(value: _headerBannerBloc),
      ],
      child: BlocBuilder<HomeBloc, HomeState>(
        bloc: _homeBloc,
        builder: (BuildContext context, HomeState homeState) {
          return BlocBuilder<HeaderBannerBloc, HeaderBannerState>(
            bloc: _headerBannerBloc,
            builder: (BuildContext context, HeaderBannerState headerState) {
              final double screenWidth = MediaQuery.sizeOf(context).width;
              final HomePromoBannerSpec? headerSpec = headerState.specs.isEmpty
                  ? null
                  : headerState.specs.first;
              final double bannerHeight = headerSpec == null
                  ? HomePromoBannerSpec.defaultHeight
                  : headerSpec.resolveHeight(screenWidth);
              final double topInset = MediaQuery.paddingOf(context).top;
              final double appBarSlotHeight =
                  HomeAppBar.resolveRegionHeight(headerState.headerTheme) +
                  topInset;
              final HeaderMediaLayout? mediaLayout =
                  (headerSpec?.showMediaInAppBar ?? false)
                  ? HeaderMediaLayout(
                      appBarHeight: appBarSlotHeight,
                      bannerHeight: headerSpec!.resolveHeight(screenWidth),
                      width: screenWidth,
                      parallaxFactor: headerSpec.parallaxEnabled
                          ? headerSpec.parallaxIntensity
                          : 0,
                    )
                  : null;
              final bool parallaxOn = headerSpec?.parallaxEnabled ?? false;
              _headerParallaxRange =
                  mediaLayout?.overscan ??
                  (headerSpec?.resolveHeight(screenWidth) ?? 0) *
                      _parallaxFallbackRange;
              _headerParallaxBase = mediaLayout?.overscan ?? 0;
              final AnimationController? mediaController = mediaLayout == null
                  ? null
                  : (_headerMediaController ??= AnimationController(
                      vsync: this,
                      duration: const Duration(seconds: 1),
                    ));
              final Widget? leading =
                  widget.leading ??
                  (Navigator.of(context).canPop() ? const BackButton() : null);
              final AppLocalizations? translate = AppLocalizations.of(context);
              final List<BusinessVertical> verticals = translate == null
                  ? const <BusinessVertical>[]
                  : buildBusinessVerticals(translate);
              return Scaffold(
                backgroundColor: widget.backgroundColor,
                resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
                drawer: widget.drawer,
                bottomNavigationBar: widget.bottomNavigationBar,
                appBar: HomeAppBar(
                  state: homeState,
                  headerTheme: headerState.headerTheme,
                  spec: headerSpec,
                  bannerHeight: bannerHeight,
                  mediaLayout: mediaLayout,
                  mediaController: mediaController,
                  parallax: _headerParallax,
                  extraActions: widget.extraActions,
                  leading: leading,
                ),
                body: SplitRefresh(
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: HomePromoBannerSlot(
                          specs: headerState.specs,
                          backgroundTheme: headerState.headerTheme,
                          mediaLayout: mediaLayout,
                          mediaController: mediaController,
                          parallax: parallaxOn ? _headerParallax : null,
                        ),
                      ),
                      if (verticals.isNotEmpty)
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _VerticalStripDelegate(
                            child: BusinessVerticalStrip(
                              verticals: verticals,
                              onSelected: _onVerticalSelected,
                            ),
                          ),
                        ),
                      ...widget.slivers,
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VerticalStripDelegate extends SliverPersistentHeaderDelegate {
  const _VerticalStripDelegate({required this.child});

  final Widget child;

  static const double _height = 64;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _VerticalStripDelegate oldDelegate) =>
      oldDelegate.child != child;
}
