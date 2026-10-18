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

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/country_code_modal_response_model.dart';
import 'package:user/app/core/models/localities_by_city_model.dart';
import 'package:user/app/core/models/modal_navigation_back_response_model.dart';
import 'package:user/app/core/models/restaurant_register_request_basic_detail_model.dart';
import 'package:user/app/core/models/translations/restaurant_register_request_form_translation.dart';
import 'package:user/app/env.dart';
import 'package:user/app/presentation/pages/account/restaurant_register_request/@core/bloc/restaurant_register_request_bloc.dart';
import 'package:user/app/presentation/pages/modals/country_modal/country_modal_view.dart';
import 'package:user/app/presentation/pages/modals/select_cuisine_modal/select_cuisine_modal_view.dart';
import 'package:user/app/presentation/pages/modals/select_deliverytime_modal/select_deliverytime_modal_view.dart';
import 'package:user/app/presentation/pages/modals/select_restaurant_facilities_modal/select_restaurant_facilities_modal_view.dart';
import 'package:user/app/presentation/pages/modals/select_restaurant_type_modal/select_restaurant_type_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/loader_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/gen/l10n/app_localizations.dart';

class RestaurantRegisterRequestScreen extends StatelessWidget {
  const RestaurantRegisterRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => RestaurantRegisterRequestBloc()..add(RestaurantRegisterRequestInitialEvent()), child: const RestaurantRegisterRequestView());
  }
}

class RestaurantRegisterRequestView extends StatefulWidget {
  const RestaurantRegisterRequestView({super.key});

  @override
  State<RestaurantRegisterRequestView> createState() => _RestaurantRegisterRequestViewState();
}

class _RestaurantRegisterRequestViewState extends State<RestaurantRegisterRequestView> with TickerProviderStateMixin {
  PageController pageController = PageController(initialPage: 0, viewportFraction: 1);

  final Completer<GoogleMapController> _googleMapController = Completer<GoogleMapController>();

  final ScrollController _scrollSubscriptionPackage = ScrollController();
  double _scrollSubscriptionPackagePercentage = 0;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController shortDescriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cuisineController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController facilitiesController = TextEditingController();
  final TextEditingController minOrderAmountController = TextEditingController();
  final TextEditingController dishForTwoController = TextEditingController();
  final TextEditingController foodLicenseController = TextEditingController();
  final TextEditingController deliveryTimeController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController socialFacebookController = TextEditingController();
  final TextEditingController socialInstagramController = TextEditingController();
  final TextEditingController socialXController = TextEditingController();
  final TextEditingController socialYoutubeController = TextEditingController();
  final TextEditingController socialLinkedInController = TextEditingController();
  final TextEditingController socialPinterestController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _shortDescriptionFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _minOrderAmountFocusNode = FocusNode();
  final _dishForTwoFocusNode = FocusNode();
  final _foodLicenseFocusNode = FocusNode();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _countryCodeFocusNode = FocusNode();
  final _mobileNuberFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _cuisineFocusNode = FocusNode();
  final _typeFocusNode = FocusNode();
  final _facilityFocusNode = FocusNode();

  bool _passwordVisible = false;

  List<RestaurantRegisterRequestFormTranslations> translations = <RestaurantRegisterRequestFormTranslations>[];
  late TabController outletTranslationTabController;

  Future<void> changeCameraPosition(double latitude, double longitude) async {
    if (!mounted) return;
    CameraPosition nepPos = CameraPosition(target: LatLng(latitude, longitude), zoom: 16);
    final GoogleMapController controller = await _googleMapController.future;
    if (!mounted) return;
    await controller.animateCamera(CameraUpdate.newCameraPosition(nepPos));
  }

  XFile? logoImage;
  XFile? coverImage;
  List<FormImageConfigModel> formImages = <FormImageConfigModel>[];

  final ImagePicker picker = ImagePicker();

  XFile getFormImageCore(String uuid) {
    final int indexOfSameUUID = formImages.indexWhere((x) => x.uuid == uuid);
    return indexOfSameUUID != -1 ? formImages[indexOfSameUUID].file! : formImages[0].file!;
  }

  Future getLogoImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    if (img != null) {
      setState(() {
        logoImage = img;
      });
    }
  }

  Future getCoverImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    if (img != null) {
      setState(() {
        coverImage = img;
      });
    }
  }

  bool checkFormImageExist(String uuid) {
    final int indexOfSameUUID = formImages.indexWhere((x) => x.uuid == uuid);
    return indexOfSameUUID != -1 ? true : false;
  }

  String getFormImagePath(String uuid) {
    final int indexOfSameUUID = formImages.indexWhere((x) => x.uuid == uuid);
    return indexOfSameUUID != -1 ? formImages[indexOfSameUUID].file!.path : '';
  }

  Future getFormImage(ImageSource media, String uuid) async {
    var img = await picker.pickImage(source: media);
    if (img != null) {
      setState(() {
        final int indexOfSameUUID = formImages.indexWhere((x) => x.uuid == uuid);
        if (indexOfSameUUID != -1) {
          formImages.removeAt(indexOfSameUUID);
        } else {
          FormImageConfigModel param = FormImageConfigModel(file: img, uuid: uuid);
          formImages.add(param);
        }
      });
    }
  }

  Future cleanFormImage(String uuid) async {
    setState(() {
      final int indexOfSameUUID = formImages.indexWhere((x) => x.uuid == uuid);
      if (indexOfSameUUID != -1) {
        formImages.removeAt(indexOfSameUUID);
      }
    });
  }

  Future cleanLogoImage() async {
    setState(() {
      logoImage = null;
    });
  }

  Future cleanCoverImage() async {
    setState(() {
      coverImage = null;
    });
  }

  @override
  void initState() {
    super.initState();
    if (AppSupportedLanguagesModel.languages.length > 1) {
      for (var element in AppSupportedLanguagesModel.languages) {
        RestaurantRegisterRequestFormTranslations keys = RestaurantRegisterRequestFormTranslations(name: element.value, code: element.code, nativeName: element.value, title: '', address: '', shortDescription: '');
        translations.add(keys);
      }
    }
    outletTranslationTabController = TabController(initialIndex: 0, length: translations.length, vsync: this);

    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestNameUnfocusedEvent());
      }
    });

    _shortDescriptionFocusNode.addListener(() {
      if (!_shortDescriptionFocusNode.hasFocus) {
        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestShortDescriptionUnfocusedEvent());
      }
    });

    _addressFocusNode.addListener(() {
      if (!_addressFocusNode.hasFocus) {
        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestAddressUnfocusedEvent());
      }
    });

    _minOrderAmountFocusNode.addListener(() {
      if (!_minOrderAmountFocusNode.hasFocus) {
        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestMinOrderAmountUnfocusedEvent());
      }
    });

    _dishForTwoFocusNode.addListener(() {
      if (!_dishForTwoFocusNode.hasFocus) {
        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestDishForTwoUnfocusedEvent());
      }
    });

    _foodLicenseFocusNode.addListener(() {
      if (!_foodLicenseFocusNode.hasFocus) {
        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestFoodLicenseUnfocusedEvent());
      }
    });

    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestEmailUnfocusedEvent());
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestPasswordUnfocusedEvent());
      }
    });

    _firstNameFocusNode.addListener(() {
      if (!_firstNameFocusNode.hasFocus) {
        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestFirstNameUnfocusedEvent());
      }
    });

    _lastNameFocusNode.addListener(() {
      if (!_lastNameFocusNode.hasFocus) {
        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestLastNameUnfocusedEvent());
      }
    });

    _countryCodeFocusNode.addListener(() {
      if (!_countryCodeFocusNode.hasFocus) {
        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestCountryCodeUnfocusedEvent());
      }
    });

    _mobileNuberFocusNode.addListener(() {
      if (!_mobileNuberFocusNode.hasFocus) {
        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestMobileNumberUnfocusedEvent());
      }
    });

    _cuisineFocusNode.addListener(() {
      if (!_cuisineFocusNode.hasFocus) {
        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestCusineUnfocusedEvent());
      }
    });

    _typeFocusNode.addListener(() {
      if (!_typeFocusNode.hasFocus) {
        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestTypeUnfocusedEvent());
      }
    });

    _facilityFocusNode.addListener(() {
      if (!_facilityFocusNode.hasFocus) {
        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestFacilityUnfocusedEvent());
      }
    });

    _scrollSubscriptionPackage.addListener(() {
      double scrollPercentage = (_scrollSubscriptionPackage.position.pixels / _scrollSubscriptionPackage.position.maxScrollExtent) * 100;
      if (scrollPercentage > 90) {
        setState(() {
          _scrollSubscriptionPackagePercentage = 80;
        });
      } else {
        setState(() {
          _scrollSubscriptionPackagePercentage = scrollPercentage;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    nameController.dispose();
    shortDescriptionController.dispose();
    addressController.dispose();
    cuisineController.dispose();
    typeController.dispose();
    facilitiesController.dispose();
    minOrderAmountController.dispose();
    dishForTwoController.dispose();
    foodLicenseController.dispose();
    deliveryTimeController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    countryCodeController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    socialFacebookController.dispose();
    socialInstagramController.dispose();
    socialXController.dispose();
    socialYoutubeController.dispose();
    socialLinkedInController.dispose();
    socialPinterestController.dispose();

    _nameFocusNode.dispose();
    _shortDescriptionFocusNode.dispose();
    _addressFocusNode.dispose();
    _minOrderAmountFocusNode.dispose();
    _dishForTwoFocusNode.dispose();
    _foodLicenseFocusNode.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _countryCodeFocusNode.dispose();
    _mobileNuberFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _cuisineFocusNode.dispose();
    _typeFocusNode.dispose();
    _facilityFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = context.select((RestaurantRegisterRequestBloc bloc) => bloc.state.isValid);
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<RestaurantRegisterRequestBloc, RestaurantRegisterRequestState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isBasicFetched) {
          countryCodeController.text = '${state.flag} (${state.countryCodeField.value})';
          deliveryTimeController.text = state.deliveryTimeField.value;
          latitudeController.text = state.latitudeField.value;
          longitudeController.text = state.longitudeField.value;
          changeCameraPosition(double.parse(state.latitudeField.value), double.parse(state.longitudeField.value));
        } else if (state.status.isLocationChange) {
          latitudeController.text = state.latitudeField.value;
          longitudeController.text = state.longitudeField.value;
        } else if (state.status.isChangeDetailFromModal) {
          cuisineController.text = state.cuisineNames;
          typeController.text = state.typeName;
          facilitiesController.text = state.facilitiesName;
          deliveryTimeController.text = state.deliveryTimeField.value;
        } else if (state.status.isSubmitSuccess) {
          pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
        } else if (state.status.isUploadFailed) {
          if (state.uploadingImageTag == 'logo') {
            cleanLogoImage();
          } else if (state.uploadingImageTag == 'cover') {
            cleanCoverImage();
          } else if (state.formUploadingImageUUID == 'form') {
            cleanFormImage(state.formUploadingImageUUID);
          }
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isUploadSuccess) {
          showSuccessDialog(context, translate.image_uploaded);
          if (state.uploadingImageTag == 'logo') {
            cleanLogoImage();
          } else if (state.uploadingImageTag == 'cover') {
            cleanCoverImage();
          } else if (state.formUploadingImageUUID == 'form') {
            cleanFormImage(state.formUploadingImageUUID);
          }
        } else if (state.status.isBackPage) {
          pageController.jumpToPage(state.currentPageIndex);
        } else if (state.status.isPaymentSuccess) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.restaurantRegisterRequestSuccessRoute, (Route<dynamic> route) => false);
        } else if (state.status.isMakePayment) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.restaurantRegisterPaymentRoute, (Route<dynamic> route) => false, arguments: [state.paymentURL]);
        } else if (state.status.isLocalityFetching) {
          LoaderService.showLoader(context, msg: translate.please_wait);
        } else if (state.status.isLocalityFetched) {
          LoaderService.hideLoder(context);
          latitudeController.text = state.latitudeField.value;
          longitudeController.text = state.longitudeField.value;
        } else if (state.status.isLocalityFailed) {
          LoaderService.hideLoder(context);
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode).then((value) {});
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(translate.restaurant_register_request_title),
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                if (state.currentPageIndex == 0) {
                  Navigator.of(context).pop();
                } else if (state.currentPageIndex != 0) {
                  context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestOnBackPageEvent());
                }
              },
              icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
            ),
            scrolledUnderElevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: state.status.isLoading || state.status.isFailure
                  ? const SizedBox()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding, vertical: ThemeProvider.scaffoldPadding),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircleAvatar(
                                      backgroundColor: state.currentPageIndex >= 0 ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.surface,
                                      child: Icon(Icons.circle, color: state.currentPageIndex >= 0 ? Theme.of(context).primaryColor : Theme.of(context).canvasColor, size: 5),
                                    ),
                                  ),
                                  kAppSpacerHorizontal(width: 10),
                                  Text(
                                    translate.information,
                                    overflow: TextOverflow.ellipsis,
                                    style: kAppLblMediumFontMedium(context, color: state.currentPageIndex >= 0 ? 'primary' : 'regular'),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: state.currentPageIndex >= 0 ? Theme.of(context).primaryColor : Theme.of(context).canvasColor)),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircleAvatar(
                                      backgroundColor: state.currentPageIndex >= 1 ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.surface,
                                      child: Icon(Icons.circle, color: state.currentPageIndex >= 1 ? Theme.of(context).primaryColor : Theme.of(context).canvasColor, size: 5),
                                    ),
                                  ),
                                  kAppSpacerHorizontal(width: 10),
                                  Text(
                                    translate.business,
                                    overflow: TextOverflow.ellipsis,
                                    style: kAppLblMediumFontMedium(context, color: state.currentPageIndex >= 1 ? 'primary' : 'regular'),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: state.currentPageIndex >= 1 ? Theme.of(context).primaryColor : Theme.of(context).canvasColor)),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircleAvatar(
                                      backgroundColor: state.currentPageIndex >= 2 ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.surface,
                                      child: Icon(Icons.circle, color: state.currentPageIndex >= 2 ? Theme.of(context).primaryColor : Theme.of(context).canvasColor, size: 5),
                                    ),
                                  ),
                                  kAppSpacerHorizontal(width: 10),
                                  Text(
                                    translate.finish,
                                    overflow: TextOverflow.ellipsis,
                                    style: kAppLblMediumFontMedium(context, color: state.currentPageIndex >= 2 ? 'primary' : 'regular'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          body: PageView.builder(
            itemCount: 3,
            controller: pageController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.status.isLoading) ...[
                      const RegisterRequestLoadingView(),
                    ] else if (state.status.isFailure) ...[
                      const RegisterRequestErrorView(),
                    ] else ...[
                      if (state.currentPageIndex == 0) ...[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    state.logoField.value.isNotEmpty
                                        ? Container(
                                            width: 100,
                                            height: 100,
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(color: state.logoField.displayError != null ? ThemeProvider.errorColor : ThemeProvider.greyColorBorder, width: state.logoField.displayError != null ? 2 : 0),
                                              shape: BoxShape.rectangle,
                                            ),
                                            child: CacheNetworkImageWidget(width: 100, height: 100, imageUrl: state.logoField.value),
                                          )
                                        : Container(
                                            width: 100,
                                            height: 100,
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(color: state.logoField.displayError != null ? ThemeProvider.errorColor : ThemeProvider.greyColorBorder, width: state.logoField.displayError != null ? 2 : 0),
                                              shape: BoxShape.rectangle,
                                            ),
                                            child: InkWell(
                                              onTap: logoImage != null
                                                  ? null
                                                  : () {
                                                      showCupertinoModalPopup<void>(
                                                        context: context,
                                                        builder: (_) => CupertinoActionSheet(
                                                          title: Text(translate.choose_from, style: kAppLblMediumFontSemiBold(context)),
                                                          actions: <CupertinoActionSheetAction>[
                                                            CupertinoActionSheetAction(
                                                              child: Text(translate.gallery, style: kAppLblMediumFontRegular(context)),
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                getLogoImage(ImageSource.gallery);
                                                              },
                                                            ),
                                                            CupertinoActionSheetAction(
                                                              child: Text(translate.camera, style: kAppLblMediumFontRegular(context)),
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                getLogoImage(ImageSource.camera);
                                                              },
                                                            ),
                                                            CupertinoActionSheetAction(
                                                              child: Text(translate.cancel_title, style: kAppLblMediumFontRegularError(context)),
                                                              onPressed: () => Navigator.pop(context),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                              child: logoImage != null
                                                  ? Stack(
                                                      children: [
                                                        Image.file(File(logoImage!.path), width: 100, height: 100, fit: BoxFit.cover),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.black.withValues(alpha: 0.9), Colors.black.withValues(alpha: 0.5)]),
                                                          ),
                                                        ),
                                                        state.status.isUploadStarted && state.uploadingImageTag == 'logo'
                                                            ? Align(
                                                                alignment: Alignment.center,
                                                                child: kAppCircularProgress(context, color: 'primary', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0),
                                                              )
                                                            : Align(
                                                                alignment: Alignment.center,
                                                                child: InkWell(
                                                                  onTap: () => context.read<RestaurantRegisterRequestBloc>().add(
                                                                    RestaurantRegisterRequestUploadImageEvent(newImage: logoImage!, formIndex: 0, uploadImageTag: 'logo', formUploadingImageUUID: ''),
                                                                  ),
                                                                  child: Text(translate.upload, style: kAppLblTinyBoldOffer(context)),
                                                                ),
                                                              ),
                                                        Align(
                                                          alignment: Alignment.topRight,
                                                          child: InkWell(
                                                            onTap: () => cleanLogoImage(),
                                                            child: const Icon(Icons.delete_forever_outlined, color: ThemeProvider.errorColor, size: 18),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : CacheNetworkImageWidget(width: 100, height: 100, imageUrl: state.logoField.value),
                                            ),
                                          ),
                                    kAppSpacerVertical(height: 5),
                                    Text("${translate.restaurant_logo} (1:1)", style: kAppLblTinyFontRegular(context)),
                                  ],
                                ),
                              ],
                            ),
                            kAppSpacerVertical(height: 20),
                            Text("${translate.restaurant_cover} (2:1)", style: kAppLblTinyFontRegular(context)),
                            kAppSpacerVertical(height: 5),
                            state.coverField.value.isNotEmpty
                                ? Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 150,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: state.coverField.displayError != null ? ThemeProvider.errorColor : ThemeProvider.greyColorBorder, width: state.coverField.displayError != null ? 2 : 0),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150, imageUrl: state.coverField.value),
                                  )
                                : Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 150,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: state.coverField.displayError != null ? ThemeProvider.errorColor : ThemeProvider.greyColorBorder, width: state.coverField.displayError != null ? 2 : 0),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: InkWell(
                                      onTap: coverImage != null
                                          ? null
                                          : () {
                                              showCupertinoModalPopup<void>(
                                                context: context,
                                                builder: (_) => CupertinoActionSheet(
                                                  title: Text(translate.choose_from, style: kAppLblMediumFontSemiBold(context)),
                                                  actions: <CupertinoActionSheetAction>[
                                                    CupertinoActionSheetAction(
                                                      child: Text(translate.gallery, style: kAppLblMediumFontRegular(context)),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        getCoverImage(ImageSource.gallery);
                                                      },
                                                    ),
                                                    CupertinoActionSheetAction(
                                                      child: Text(translate.camera, style: kAppLblMediumFontRegular(context)),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        getCoverImage(ImageSource.camera);
                                                      },
                                                    ),
                                                    CupertinoActionSheetAction(
                                                      child: Text(translate.cancel_title, style: kAppLblMediumFontRegularError(context)),
                                                      onPressed: () => Navigator.pop(context),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                      child: coverImage != null
                                          ? Stack(
                                              children: [
                                                Image.file(File(coverImage!.path), width: MediaQuery.of(context).size.width, height: 150, fit: BoxFit.cover),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.black.withValues(alpha: 0.9), Colors.black.withValues(alpha: 0.5)]),
                                                  ),
                                                ),
                                                state.status.isUploadStarted && state.uploadingImageTag == 'cover'
                                                    ? Align(
                                                        alignment: Alignment.center,
                                                        child: kAppCircularProgress(context, color: 'primary', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0),
                                                      )
                                                    : Align(
                                                        alignment: Alignment.center,
                                                        child: InkWell(
                                                          onTap: () => context.read<RestaurantRegisterRequestBloc>().add(
                                                            RestaurantRegisterRequestUploadImageEvent(newImage: coverImage!, formIndex: 0, uploadImageTag: 'cover', formUploadingImageUUID: ''),
                                                          ),
                                                          child: Text(translate.upload, style: kAppLblTinyBoldOffer(context)),
                                                        ),
                                                      ),
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: InkWell(
                                                    onTap: () => cleanCoverImage(),
                                                    child: const Icon(Icons.delete_forever_outlined, color: ThemeProvider.errorColor, size: 24),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150, imageUrl: state.coverField.value),
                                    ),
                                  ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              controller: nameController,
                              focusNode: _nameFocusNode,
                              decoration: kAppInputDecoration(context, lblText: translate.restaurant_name, errText: state.nameField.displayError != null ? translate.form_required : null),
                              style: kAppLblLargeFontMedium(context),
                              keyboardType: TextInputType.text,
                              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\w\s]+'))],
                              onChanged: (value) {
                                if (value.startsWith(' ')) {
                                  nameController.text = value.trimLeft();
                                  nameController.selection = TextSelection.collapsed(offset: nameController.text.length);
                                }
                                if (RegExp(r'^[0-9]').hasMatch(value)) {
                                  nameController.text = value.substring(1);
                                  nameController.selection = TextSelection.collapsed(offset: nameController.text.length);
                                }
                                context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestNameChangedEvent(name: nameController.text));
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              controller: shortDescriptionController,
                              focusNode: _shortDescriptionFocusNode,
                              maxLines: 3,
                              decoration: kAppInputDecoration(context, lblText: translate.short_description, errText: state.shortDescriptionField.displayError != null ? translate.form_required : null),
                              style: kAppLblLargeFontMedium(context),
                              keyboardType: TextInputType.text,
                              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\w\s]+'))],
                              onChanged: (value) {
                                if (value.startsWith(' ')) {
                                  shortDescriptionController.text = value.trimLeft();
                                  shortDescriptionController.selection = TextSelection.collapsed(offset: shortDescriptionController.text.length);
                                }
                                context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestShortDescriptionChangedEvent(shortDescription: shortDescriptionController.text));
                              },
                              textInputAction: TextInputAction.done,
                            ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              controller: addressController,
                              focusNode: _addressFocusNode,
                              maxLines: 3,
                              decoration: kAppInputDecoration(context, lblText: translate.address, errText: state.addressField.displayError != null ? translate.form_required : null),
                              style: kAppLblLargeFontMedium(context),
                              keyboardType: TextInputType.text,
                              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\w\s]+'))],
                              onChanged: (value) {
                                if (value.startsWith(' ')) {
                                  addressController.text = value.trimLeft();
                                  addressController.selection = TextSelection.collapsed(offset: addressController.text.length);
                                }
                                context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestAddressChangedEvent(address: addressController.text));
                              },
                              textInputAction: TextInputAction.done,
                            ),
                            kAppSpacerVertical(height: 20),
                            Text(translate.city, style: kAppLblTinyFontRegular(context)),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                              ),
                              child: DropdownButton<RestaurantRegisterRequestCitiesModel>(
                                underline: const SizedBox(),
                                isExpanded: true,
                                value: state.selectedCity,
                                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                                style: kAppLblMediumFontRegular(context),
                                items: state.cityList.map((RestaurantRegisterRequestCitiesModel item) {
                                  return DropdownMenuItem<RestaurantRegisterRequestCitiesModel>(value: item, child: Text(item.name.toString()));
                                }).toList(),
                                onChanged: (newValue) {
                                  context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestCityChangeEvent(city: newValue!));
                                },
                              ),
                            ),
                            state.localityList.isNotEmpty ? kAppSpacerVertical(height: 20) : const SizedBox(),
                            state.localityList.isNotEmpty ? Text(translate.locality, style: kAppLblTinyFontRegular(context)) : const SizedBox(),
                            state.localityList.isNotEmpty
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                                    ),
                                    child: DropdownButton<LocalitiesFromCityModel>(
                                      underline: const SizedBox(),
                                      isExpanded: true,
                                      value: state.selectedLocality,
                                      dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                                      style: kAppLblMediumFontRegular(context),
                                      items: state.localityList.map((LocalitiesFromCityModel item) {
                                        return DropdownMenuItem<LocalitiesFromCityModel>(value: item, child: Text(item.name.toString()));
                                      }).toList(),
                                      onChanged: (newValue) {
                                        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestLocalityChangeEvent(locality: newValue!));
                                      },
                                    ),
                                  )
                                : const SizedBox(),
                            kAppSpacerVertical(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: latitudeController,
                                    readOnly: true,
                                    enabled: false,
                                    decoration: kAppInputDecoration(
                                      context,
                                      prefixIcon: const Icon(Icons.location_on_outlined),
                                      lblText: translate.rest_lat,
                                      errText: state.latitudeField.displayError != null ? translate.form_required : null,
                                    ),
                                    style: kAppLblSmallFontMedium(context),
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                kAppSpacerHorizontal(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: longitudeController,
                                    readOnly: true,
                                    enabled: false,
                                    decoration: kAppInputDecoration(
                                      context,
                                      prefixIcon: const Icon(Icons.location_on_outlined),
                                      lblText: translate.rest_lng,
                                      errText: state.longitudeField.displayError != null ? translate.form_required : null,
                                    ),
                                    style: kAppLblSmallFontMedium(context),
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                              ],
                            ),
                            kAppSpacerVertical(height: 20),
                            SizedBox(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              child: !kIsWeb
                                  ? Stack(
                                      children: [
                                        GoogleMap(
                                          key: GlobalKey(),
                                          onMapCreated: (GoogleMapController controller) async {
                                            if (!_googleMapController.isCompleted) {
                                              _googleMapController.complete(controller);
                                              CameraPosition nepPos = CameraPosition(target: LatLng(double.parse(state.latitudeField.value), double.parse(state.longitudeField.value)), zoom: 10);
                                              await controller.animateCamera(CameraUpdate.newCameraPosition(nepPos));
                                            }
                                          },
                                          initialCameraPosition: CameraPosition(zoom: 10, tilt: 0, bearing: 30, target: LatLng(double.parse(state.latitudeField.value), double.parse(state.longitudeField.value))),
                                          onTap: (LatLng newPosition) {
                                            context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestLocationChangeEvent(latitude: newPosition.latitude, longitude: newPosition.longitude));
                                          },
                                          markers: <Marker>{
                                            Marker(
                                              draggable: true,
                                              markerId: const MarkerId("OutletLocation"),
                                              position: LatLng(double.parse(state.latitudeField.value), double.parse(state.longitudeField.value)),
                                              icon: BitmapDescriptor.defaultMarker,
                                              onDragEnd: ((newPosition) {
                                                context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestLocationChangeEvent(latitude: newPosition.latitude, longitude: newPosition.longitude));
                                              }),
                                            ),
                                          },
                                        ),
                                      ],
                                    )
                                  : Text(translate.google_maps_here, style: kAppLblLargeFontBold(context)),
                            ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              controller: cuisineController,
                              focusNode: _cuisineFocusNode,
                              readOnly: true,
                              decoration: kAppInputDecoration(context, lblText: translate.cuisine, errText: state.cuisineField.displayError != null ? translate.form_required : null),
                              style: kAppLblLargeFontMedium(context),
                              keyboardType: TextInputType.text,
                              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\w\s]+'))],
                              onTap: () {
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return SelectCuisineModalScreen(cuisine: state.cuisineIds.isEmpty ? [] : state.cuisineIds.split(','));
                                        },
                                        fullscreenDialog: true,
                                      ),
                                    )
                                    .then((value) {
                                      if (!context.mounted) return;
                                      if (value != null && value.toString().isNotEmpty) {
                                        ModalNavigationBackResponseModel param = ModalNavigationBackResponseModel.fromJson(value);
                                        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestCuisineChangeEvent(param: param));
                                      }
                                    });
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              controller: typeController,
                              focusNode: _typeFocusNode,
                              readOnly: true,
                              decoration: kAppInputDecoration(context, lblText: translate.rest_type, errText: state.typeField.displayError != null ? translate.form_required : null),
                              style: kAppLblLargeFontMedium(context),
                              keyboardType: TextInputType.text,
                              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\w\s]+'))],
                              onTap: () {
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return SelectRestaurantTypeModalScreen(type: state.typeIds.isEmpty ? [] : state.typeIds.split(','));
                                        },
                                        fullscreenDialog: true,
                                      ),
                                    )
                                    .then((value) {
                                      if (!context.mounted) return;
                                      if (value != null && value.toString().isNotEmpty) {
                                        ModalNavigationBackResponseModel param = ModalNavigationBackResponseModel.fromJson(value);
                                        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestTypeChangeEvent(param: param));
                                      }
                                    });
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              controller: facilitiesController,
                              focusNode: _facilityFocusNode,
                              readOnly: true,
                              decoration: kAppInputDecoration(context, lblText: translate.rest_facilities, errText: state.facilitiesField.displayError != null ? translate.form_required : null),
                              style: kAppLblLargeFontMedium(context),
                              keyboardType: TextInputType.text,
                              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\w\s]+'))],
                              onTap: () {
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return SelectRestaurantFacilitiesModalScreen(facilities: state.facilitiesIds.isEmpty ? [] : state.facilitiesIds.split(','));
                                        },
                                        fullscreenDialog: true,
                                      ),
                                    )
                                    .then((value) {
                                      if (!context.mounted) return;
                                      if (value != null && value.toString().isNotEmpty) {
                                        ModalNavigationBackResponseModel param = ModalNavigationBackResponseModel.fromJson(value);
                                        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestFacilitiesChangeEvent(param: param));
                                      }
                                    });
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            kAppSpacerVertical(height: 20),
                            Text(translate.home_delivery_available, style: kAppLblTinyFontRegular(context)),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                              ),
                              child: DropdownButton<HomeDeliverySupportModel>(
                                underline: const SizedBox(),
                                isExpanded: true,
                                value: state.homeDelivery,
                                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                                style: kAppLblMediumFontRegular(context),
                                items: state.homeDeliveryList.map((HomeDeliverySupportModel item) {
                                  return DropdownMenuItem<HomeDeliverySupportModel>(value: item, child: Text(kAppDDTranslate(context, item.label.toString())));
                                }).toList(),
                                onChanged: (newValue) {
                                  context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestHomeDeliveryChangeEvent(option: newValue!));
                                },
                              ),
                            ),
                            kAppSpacerVertical(height: 20),
                            Text(translate.take_away_available, style: kAppLblTinyFontRegular(context)),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                              ),
                              child: DropdownButton<TakeAwaySupportModel>(
                                underline: const SizedBox(),
                                isExpanded: true,
                                value: state.takeAway,
                                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                                style: kAppLblMediumFontRegular(context),
                                items: state.takeAwayList.map((TakeAwaySupportModel item) {
                                  return DropdownMenuItem<TakeAwaySupportModel>(value: item, child: Text(kAppDDTranslate(context, item.label.toString())));
                                }).toList(),
                                onChanged: (newValue) {
                                  context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestTakeAwayChangeEvent(option: newValue!));
                                },
                              ),
                            ),
                            kAppSpacerVertical(height: 20),
                            Text(translate.schedule_orders, style: kAppLblTinyFontRegular(context)),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                              ),
                              child: DropdownButton<ScheduleOrderSupportModel>(
                                underline: const SizedBox(),
                                isExpanded: true,
                                value: state.scheduleOrder,
                                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                                style: kAppLblMediumFontRegular(context),
                                items: state.scheduleOrderList.map((ScheduleOrderSupportModel item) {
                                  return DropdownMenuItem<ScheduleOrderSupportModel>(value: item, child: Text(kAppDDTranslate(context, item.label.toString())));
                                }).toList(),
                                onChanged: (newValue) {
                                  context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestScheduleOrderChangeEvent(option: newValue!));
                                },
                              ),
                            ),
                            kAppSpacerVertical(height: 20),
                            Text(translate.food_license, style: kAppLblTinyFontRegular(context)),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                              ),
                              child: DropdownButton<RestaurantRegisterRequestLicenseModel>(
                                underline: const SizedBox(),
                                isExpanded: true,
                                value: state.selectedLicense,
                                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                                style: kAppLblMediumFontRegular(context),
                                items: state.licenseList.map((RestaurantRegisterRequestLicenseModel item) {
                                  return DropdownMenuItem<RestaurantRegisterRequestLicenseModel>(value: item, child: Text(item.name.toString()));
                                }).toList(),
                                onChanged: (newValue) {
                                  context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestLicenseChangeEvent(option: newValue!));
                                },
                              ),
                            ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              controller: foodLicenseController,
                              focusNode: _foodLicenseFocusNode,
                              decoration: kAppInputDecoration(context, lblText: translate.food_license, errText: state.licenseField.displayError != null ? translate.form_required : null),
                              style: kAppLblLargeFontMedium(context),
                              keyboardType: TextInputType.text,
                              onChanged: (value) {
                                if (value.startsWith(' ')) {
                                  foodLicenseController.text = value.trimLeft();
                                  foodLicenseController.selection = TextSelection.collapsed(offset: foodLicenseController.text.length);
                                }
                                context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestFoodLicenseChangedEvent(license: foodLicenseController.text));
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              controller: minOrderAmountController,
                              focusNode: _minOrderAmountFocusNode,
                              decoration: kAppInputDecoration(context, lblText: translate.min_order_amount, errText: state.minOrderAmountField.displayError != null ? translate.form_required : null),
                              style: kAppLblLargeFontMedium(context),
                              keyboardType: TextInputType.text,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
                              onChanged: (value) => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestMinOrderAmountChangedEvent(minOrderAmount: value)),
                              textInputAction: TextInputAction.next,
                            ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              controller: dishForTwoController,
                              focusNode: _dishForTwoFocusNode,
                              decoration: kAppInputDecoration(context, lblText: translate.price_for_two, errText: state.dishPriceForTwoField.displayError != null ? translate.form_required : null),
                              style: kAppLblLargeFontMedium(context),
                              keyboardType: TextInputType.text,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
                              onChanged: (value) => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestDishForTwoChangedEvent(dishForTwo: value)),
                              textInputAction: TextInputAction.next,
                            ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              controller: deliveryTimeController,
                              readOnly: true,
                              decoration: kAppInputDecoration(context, lblText: translate.appx_delivery_time, errText: state.deliveryTimeField.displayError != null ? translate.form_required : null),
                              style: kAppLblLargeFontMedium(context),
                              keyboardType: TextInputType.text,
                              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\w\s]+'))],
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  isDismissible: false,
                                  enableDrag: false,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  builder: (BuildContext context) {
                                    return FractionallySizedBox(heightFactor: 0.65, child: SelectDeliverytimeModalScreen(deliveryTime: state.deliveryTimeField.value));
                                  },
                                ).then((value) {
                                  if (!context.mounted) return;
                                  if (value != null && value.toString().isNotEmpty) {
                                    context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestDeliveryTimeChangeEvent(time: value!));
                                  }
                                });
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              controller: socialFacebookController,
                              decoration: kAppInputDecoration(context, lblText: translate.social_fb),
                              style: kAppLblLargeFontMedium(context),
                              keyboardType: TextInputType.text,
                              onChanged: (value) => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestSocialLinkChangeEvent(type: 'facebook', value: value)),
                              textInputAction: TextInputAction.next,
                            ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              controller: socialInstagramController,
                              decoration: kAppInputDecoration(context, lblText: translate.social_insta),
                              style: kAppLblLargeFontMedium(context),
                              keyboardType: TextInputType.text,
                              onChanged: (value) => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestSocialLinkChangeEvent(type: 'instagram', value: value)),
                              textInputAction: TextInputAction.next,
                            ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              controller: socialXController,
                              decoration: kAppInputDecoration(context, lblText: translate.social_x),
                              style: kAppLblLargeFontMedium(context),
                              keyboardType: TextInputType.text,
                              onChanged: (value) => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestSocialLinkChangeEvent(type: 'x', value: value)),
                              textInputAction: TextInputAction.next,
                            ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              controller: socialYoutubeController,
                              decoration: kAppInputDecoration(context, lblText: translate.social_yt),
                              style: kAppLblLargeFontMedium(context),
                              keyboardType: TextInputType.text,
                              onChanged: (value) => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestSocialLinkChangeEvent(type: 'youtube', value: value)),
                              textInputAction: TextInputAction.next,
                            ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              controller: socialLinkedInController,
                              decoration: kAppInputDecoration(context, lblText: translate.social_ll),
                              style: kAppLblLargeFontMedium(context),
                              keyboardType: TextInputType.text,
                              onChanged: (value) => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestSocialLinkChangeEvent(type: 'linkedin', value: value)),
                              textInputAction: TextInputAction.next,
                            ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              controller: socialPinterestController,
                              decoration: kAppInputDecoration(context, lblText: translate.social_pinterest),
                              style: kAppLblLargeFontMedium(context),
                              keyboardType: TextInputType.text,
                              onChanged: (value) => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestSocialLinkChangeEvent(type: 'pinterest', value: value)),
                              textInputAction: TextInputAction.next,
                            ),
                            kAppSpacerVertical(height: 10),
                            state.formField.isNotEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: List.generate(
                                      state.formField.length,
                                      (formIndex) => Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (state.formField[formIndex].type! == 'text') ...[
                                            FormElementTextWidget(
                                              formIndex: formIndex,
                                              fieldName: state.formField[formIndex].title!,
                                              placeholder: state.formField[formIndex].placeholder!,
                                              isRequired: state.formField[formIndex].isRequired!,
                                              isSubmitted: state.isFormSubmitted,
                                              formValue: state.formField[formIndex].value!,
                                            ),
                                          ] else if (state.formField[formIndex].type! == 'number') ...[
                                            FormElementNumberWidget(
                                              formIndex: formIndex,
                                              fieldName: state.formField[formIndex].title!,
                                              placeholder: state.formField[formIndex].placeholder!,
                                              isRequired: state.formField[formIndex].isRequired!,
                                              isSubmitted: state.isFormSubmitted,
                                              formValue: state.formField[formIndex].value!,
                                            ),
                                          ] else if (state.formField[formIndex].type! == 'file') ...[
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(state.formField[formIndex].title!, style: kAppLblTinyFontRegular(context)),
                                                state.formField[formIndex].value!.isNotEmpty
                                                    ? Container(
                                                        width: MediaQuery.of(context).size.width,
                                                        margin: const EdgeInsets.symmetric(vertical: 10),
                                                        height: 150,
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(5),
                                                          border: Border.all(
                                                            color: state.formField[formIndex].isRequired! && state.isFormSubmitted && state.formField[formIndex].value!.isEmpty
                                                                ? ThemeProvider.errorColor
                                                                : ThemeProvider.greyColorBorder,
                                                            width: state.formField[formIndex].isRequired! && state.isFormSubmitted && state.formField[formIndex].value!.isEmpty ? 2 : 0,
                                                          ),
                                                          shape: BoxShape.rectangle,
                                                        ),
                                                        child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150, imageUrl: state.formField[formIndex].value!),
                                                      )
                                                    : Container(
                                                        width: MediaQuery.of(context).size.width,
                                                        margin: const EdgeInsets.symmetric(vertical: 10),
                                                        height: 150,
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(5),
                                                          border: Border.all(
                                                            color: state.formField[formIndex].isRequired! && state.isFormSubmitted && state.formField[formIndex].value!.isEmpty
                                                                ? ThemeProvider.errorColor
                                                                : ThemeProvider.greyColorBorder,
                                                            width: state.formField[formIndex].isRequired! && state.isFormSubmitted && state.formField[formIndex].value!.isEmpty ? 2 : 0,
                                                          ),
                                                          shape: BoxShape.rectangle,
                                                        ),
                                                        child: InkWell(
                                                          onTap: checkFormImageExist(state.formField[formIndex].uuid!) == true
                                                              ? null
                                                              : () {
                                                                  showCupertinoModalPopup<void>(
                                                                    context: context,
                                                                    builder: (_) => CupertinoActionSheet(
                                                                      title: Text(translate.choose_from, style: kAppLblMediumFontSemiBold(context)),
                                                                      actions: <CupertinoActionSheetAction>[
                                                                        CupertinoActionSheetAction(
                                                                          child: Text(translate.gallery, style: kAppLblMediumFontRegular(context)),
                                                                          onPressed: () {
                                                                            Navigator.pop(context);
                                                                            getFormImage(ImageSource.gallery, state.formField[formIndex].uuid!);
                                                                          },
                                                                        ),
                                                                        CupertinoActionSheetAction(
                                                                          child: Text(translate.camera, style: kAppLblMediumFontRegular(context)),
                                                                          onPressed: () {
                                                                            Navigator.pop(context);
                                                                            getFormImage(ImageSource.camera, state.formField[formIndex].uuid!);
                                                                          },
                                                                        ),
                                                                        CupertinoActionSheetAction(
                                                                          child: Text(translate.cancel_title, style: kAppLblMediumFontRegularError(context)),
                                                                          onPressed: () => Navigator.pop(context),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                          child: checkFormImageExist(state.formField[formIndex].uuid!) == true
                                                              ? Stack(
                                                                  children: [
                                                                    Image.file(File(getFormImagePath(state.formField[formIndex].uuid!)), width: MediaQuery.of(context).size.width, height: 150, fit: BoxFit.cover),
                                                                    Container(
                                                                      decoration: BoxDecoration(
                                                                        gradient: LinearGradient(
                                                                          begin: Alignment.topLeft,
                                                                          end: Alignment.bottomRight,
                                                                          colors: [Colors.black.withValues(alpha: 0.9), Colors.black.withValues(alpha: 0.5)],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    state.status.isUploadStarted && state.uploadingImageTag == 'form' && state.formUploadingImageUUID == state.formField[formIndex].uuid!
                                                                        ? Align(
                                                                            alignment: Alignment.center,
                                                                            child: kAppCircularProgress(context, color: 'primary', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0),
                                                                          )
                                                                        : Align(
                                                                            alignment: Alignment.center,
                                                                            child: InkWell(
                                                                              onTap: () => context.read<RestaurantRegisterRequestBloc>().add(
                                                                                RestaurantRegisterRequestUploadImageEvent(
                                                                                  newImage: getFormImageCore(state.formField[formIndex].uuid!),
                                                                                  formIndex: formIndex,
                                                                                  uploadImageTag: 'form',
                                                                                  formUploadingImageUUID: state.formField[formIndex].uuid!,
                                                                                ),
                                                                              ),
                                                                              child: Text(translate.upload, style: kAppLblTinyBoldOffer(context)),
                                                                            ),
                                                                          ),
                                                                    Align(
                                                                      alignment: Alignment.topRight,
                                                                      child: InkWell(
                                                                        onTap: () => cleanFormImage(state.formField[formIndex].uuid!),
                                                                        child: const Icon(Icons.delete_forever_outlined, color: ThemeProvider.errorColor, size: 24),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150, imageUrl: state.formField[formIndex].value!),
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ] else if (state.formField[formIndex].type! == 'choose') ...[
                                            FormElementCheckboxWidget(
                                              formIndex: formIndex,
                                              fieldName: state.formField[formIndex].title!,
                                              placeholder: state.formField[formIndex].placeholder!,
                                              isRequired: state.formField[formIndex].isRequired!,
                                              isSubmitted: state.isFormSubmitted,
                                              formValue: state.formField[formIndex].value!,
                                              items: state.formField[formIndex].items!,
                                            ),
                                          ] else if (state.formField[formIndex].type! == 'date') ...[
                                            FormElementDateWidget(
                                              formIndex: formIndex,
                                              fieldName: state.formField[formIndex].title!,
                                              placeholder: state.formField[formIndex].placeholder!,
                                              isRequired: state.formField[formIndex].isRequired!,
                                              isSubmitted: state.isFormSubmitted,
                                              formValue: state.formField[formIndex].value!,
                                            ),
                                          ] else if (state.formField[formIndex].type! == 'email') ...[
                                            FormElementEmailWidget(
                                              formIndex: formIndex,
                                              fieldName: state.formField[formIndex].title!,
                                              placeholder: state.formField[formIndex].placeholder!,
                                              isRequired: state.formField[formIndex].isRequired!,
                                              isSubmitted: state.isFormSubmitted,
                                              formValue: state.formField[formIndex].value!,
                                            ),
                                          ] else if (state.formField[formIndex].type! == 'phone') ...[
                                            FormElementPhoneWidget(
                                              formIndex: formIndex,
                                              fieldName: state.formField[formIndex].title!,
                                              placeholder: state.formField[formIndex].placeholder!,
                                              isRequired: state.formField[formIndex].isRequired!,
                                              isSubmitted: state.isFormSubmitted,
                                              formValue: state.formField[formIndex].value!,
                                              extraFormValue: state.formField[formIndex].extraValue!,
                                              flag: state.flag,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            state.formField.isNotEmpty ? kAppSpacerVertical(height: 20) : const SizedBox(),
                            TextFormField(
                              focusNode: _emailFocusNode,
                              controller: emailController,
                              decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.email_outlined), lblText: translate.email, errText: state.emailField.displayError != null ? translate.form_required : null),
                              style: kAppLblSmallFontMedium(context),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestEmailChangedEvent(email: value)),
                              textInputAction: TextInputAction.next,
                            ),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              focusNode: _passwordFocusNode,
                              decoration: kAppInputDecoration(
                                context,
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                lblText: translate.password,
                                errText: state.passwordField.displayError != null ? translate.form_required : null,
                                suffixIcon: Icon(_passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                haveSuffixIcon: true,
                                onPressed: () => setState(() {
                                  _passwordVisible = !_passwordVisible;
                                }),
                              ),
                              style: kAppLblSmallFontMedium(context),
                              obscureText: !_passwordVisible,
                              keyboardType: TextInputType.text,
                              onChanged: (value) => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestPasswordChangedEvent(password: value)),
                              textInputAction: TextInputAction.done,
                            ),
                            kAppSpacerVertical(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    focusNode: _firstNameFocusNode,
                                    controller: firstNameController,
                                    decoration: kAppInputDecoration(
                                      context,
                                      prefixIcon: const Icon(Icons.person_outline),
                                      lblText: translate.first_name,
                                      errText: state.firstNameField.displayError != null ? translate.form_required : null,
                                    ),
                                    style: kAppLblSmallFontMedium(context),
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\w\s]+'))],
                                    onChanged: (value) {
                                      if (value.startsWith(' ')) {
                                        firstNameController.text = value.trimLeft();
                                        firstNameController.selection = TextSelection.collapsed(offset: firstNameController.text.length);
                                      }
                                      if (RegExp(r'^[0-9]').hasMatch(value)) {
                                        firstNameController.text = value.substring(1);
                                        firstNameController.selection = TextSelection.collapsed(offset: firstNameController.text.length);
                                      }
                                      context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestFirstNameChangedEvent(firstName: firstNameController.text));
                                    },
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                kAppSpacerHorizontal(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    focusNode: _lastNameFocusNode,
                                    controller: lastNameController,
                                    decoration: kAppInputDecoration(
                                      context,
                                      prefixIcon: const Icon(Icons.person_outline),
                                      lblText: translate.last_name,
                                      errText: state.lastNameField.displayError != null ? translate.form_required : null,
                                    ),
                                    style: kAppLblSmallFontMedium(context),
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\w\s]+'))],
                                    onChanged: (value) {
                                      if (value.startsWith(' ')) {
                                        lastNameController.text = value.trimLeft();
                                        lastNameController.selection = TextSelection.collapsed(offset: lastNameController.text.length);
                                      }
                                      if (RegExp(r'^[0-9]').hasMatch(value)) {
                                        lastNameController.text = value.substring(1);
                                        lastNameController.selection = TextSelection.collapsed(offset: lastNameController.text.length);
                                      }
                                      context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestLastNameChangedEvent(lastName: lastNameController.text));
                                    },
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                              ],
                            ),
                            kAppSpacerVertical(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    controller: countryCodeController,
                                    focusNode: _countryCodeFocusNode,
                                    readOnly: true,
                                    decoration: kAppInputDecoration(context, lblText: translate.code, errText: state.countryCodeField.displayError != null ? translate.form_required : null),
                                    style: kAppLblSmallFontMedium(context),
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) {
                                                return CountryCodeModalScreen(code: state.countryCodeField.value);
                                              },
                                              fullscreenDialog: true,
                                            ),
                                          )
                                          .then((value) {
                                            if (!context.mounted) return;
                                            CountryCodeModalResponseModel countryCodeResponse = CountryCodeModalResponseModel.fromJson(value);
                                            if (countryCodeResponse.action!) {
                                              countryCodeController.text = '${countryCodeResponse.flag} (${countryCodeResponse.dialCode})';
                                              context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestCountryCodeChangedEvent(countryCode: countryCodeResponse.dialCode!));
                                            }
                                          });
                                    },
                                  ),
                                ),
                                kAppSpacerHorizontal(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    focusNode: _mobileNuberFocusNode,
                                    controller: mobileNumberController,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                                    decoration: kAppInputDecoration(
                                      context,
                                      prefixIcon: const Icon(Icons.person_outline),
                                      lblText: translate.mobile,
                                      errText: state.mobileNumberField.displayError != null ? translate.form_required : null,
                                    ),
                                    style: kAppLblSmallFontMedium(context),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestMobileNumberChangedEvent(mobileNumber: value)),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                              ],
                            ),
                            kAppSpacerVertical(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TabBar(
                                  controller: outletTranslationTabController,
                                  physics: const NeverScrollableScrollPhysics(),
                                  tabAlignment: TabAlignment.start,
                                  isScrollable: true,
                                  labelColor: Theme.of(context).primaryColor,
                                  unselectedLabelColor: Theme.of(context).hintColor,
                                  indicatorColor: Theme.of(context).primaryColor,
                                  labelStyle: kAppStyleTabTitleStyle(context),
                                  unselectedLabelStyle: kAppStyleTabTitleStyle(context),
                                  labelPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  tabs: List.generate(translations.length, (index) => Text(translations[index].name!)),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 400,
                              child: TabBarView(
                                controller: outletTranslationTabController,
                                children: List.generate(
                                  translations.length,
                                  (index) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                          initialValue: translations[index].title,
                                          decoration: kAppInputDecoration(context, lblText: '${translate.name} ${translations[index].nativeName}'),
                                          style: kAppLblLargeFontMedium(context),
                                          onChanged: (value) {
                                            setState(() {
                                              translations[index].title = value;
                                            });
                                          },
                                          textInputAction: TextInputAction.done,
                                        ),
                                        kAppSpacerVertical(height: 20),
                                        TextFormField(
                                          initialValue: translations[index].shortDescription,
                                          maxLines: 3,
                                          decoration: kAppInputDecoration(context, lblText: '${translate.short_description} ${translations[index].nativeName}'),
                                          style: kAppLblLargeFontMedium(context),
                                          onChanged: (value) {
                                            setState(() {
                                              translations[index].shortDescription = value;
                                            });
                                          },
                                          textInputAction: TextInputAction.done,
                                        ),
                                        kAppSpacerVertical(height: 20),
                                        TextFormField(
                                          initialValue: translations[index].address,
                                          maxLines: 3,
                                          decoration: kAppInputDecoration(context, lblText: '${translate.address} ${translations[index].nativeName}'),
                                          style: kAppLblLargeFontMedium(context),
                                          onChanged: (value) {
                                            setState(() {
                                              translations[index].address = value;
                                            });
                                          },
                                          textInputAction: TextInputAction.done,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else if (state.currentPageIndex == 1) ...[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            state.model.settings!.commissionBasedSystem!
                                ? InkWell(
                                    onTap: () => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestBusinessModelChangeEvent(businessModel: 'commission')),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: state.businessModel == 'commission' ? Theme.of(context).primaryColor : Theme.of(context).shadowColor),
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(translate.commission_system, style: kAppLblSmallFontBold(context, color: state.businessModel == 'commission' ? 'primary' : '')),
                                              state.businessModel == 'commission' ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 16) : const SizedBox(),
                                            ],
                                          ),
                                          kAppSpacerVertical(height: 10),
                                          Text(translate.commission_system_sub_title, style: kAppLblSmallFontMedium(context)),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            kAppSpacerVertical(height: 20),
                            state.model.subscriptionPackages!.isNotEmpty && state.model.settings!.subscriptionBasedSystem!
                                ? InkWell(
                                    onTap: () => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestBusinessModelChangeEvent(businessModel: 'subscription')),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: state.businessModel == 'subscription' ? Theme.of(context).primaryColor : Theme.of(context).shadowColor),
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(translate.subscription_system, style: kAppLblSmallFontBold(context, color: state.businessModel == 'subscription' ? 'primary' : '')),
                                              state.businessModel == 'subscription' ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 16) : const SizedBox(),
                                            ],
                                          ),
                                          kAppSpacerVertical(height: 10),
                                          Text(translate.subscription_system_sub_title, style: kAppLblSmallFontMedium(context)),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            kAppSpacerVertical(height: 20),
                            state.businessModel == 'subscription'
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(child: Text(translate.choose_subscription_package, style: kAppLblMediumFontBold(context))),
                                      kAppSpacerVertical(height: 20),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: _scrollSubscriptionPackage,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          children: List.generate(
                                            state.model.subscriptionPackages!.length,
                                            (subscriptionIndex) =>
                                                SubscriptionPackageInfoWidget(model: state.model.subscriptionPackages![subscriptionIndex], length: state.model.subscriptionPackages!.length, selectedPackage: state.selectedPackage),
                                          ),
                                        ),
                                      ),
                                      kAppSpacerVertical(height: 20),
                                      state.model.subscriptionPackages!.length > 1
                                          ? Center(
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Container(
                                                    width: 100,
                                                    height: 4,
                                                    decoration: const BoxDecoration(color: ThemeProvider.greyColorBorder, borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                                  ),
                                                  Positioned(
                                                    left: _scrollSubscriptionPackagePercentage,
                                                    child: Container(
                                                      width: 20,
                                                      height: 4,
                                                      decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: const BorderRadius.all(Radius.circular(5.0))),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : const SizedBox(),
                                    ],
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ] else if (state.currentPageIndex == 2) ...[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            state.haveTrial
                                ? GestureDetector(
                                    onTap: () => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestChangePaymentMethodEvent(paymentId: 'trial')),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5.0),
                                        border: Border.all(color: state.paymentId == 'trial' ? Theme.of(context).primaryColor : Theme.of(context).shadowColor),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${translate.enjoy} ${state.haveTrial} ${translate.a} ${state.trialPeriod}-${translate.free_trial_started}',
                                            style: kAppLblSmallFontBold(context, color: state.paymentId == 'trial' ? 'primary' : ''),
                                          ),
                                          state.paymentId == 'trial' ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 18) : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            state.model.payment!.payments!.isNotEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: List.generate(
                                      state.model.payment!.payments!.length,
                                      (paymentIndex) => GestureDetector(
                                        onTap: () => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestChangePaymentMethodEvent(paymentId: state.model.payment!.payments![paymentIndex].id!)),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5.0),
                                            border: Border.all(color: state.paymentId == state.model.payment!.payments![paymentIndex].id! ? Theme.of(context).primaryColor : Theme.of(context).shadowColor),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(5),
                                                    child: CacheNetworkImageWidget(width: 70, height: 45.0, imageUrl: state.model.payment!.payments![paymentIndex].image!),
                                                  ),
                                                  kAppSpacerHorizontal(width: 10),
                                                  Text(
                                                    state.model.payment!.payments![paymentIndex].name!,
                                                    style: kAppLblSmallFontBold(context, color: state.paymentId == state.model.payment!.payments![paymentIndex].id! ? 'primary' : ''),
                                                  ),
                                                ],
                                              ),
                                              state.paymentId == state.model.payment!.payments![paymentIndex].id! ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 18) : const SizedBox(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              );
            },
          ),
          bottomNavigationBar: state.status.isLoading || state.status.isFailure
              ? SafeArea(child: const SizedBox())
              : SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.currentPageIndex == 0) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isValid ? () => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestSubmitEvent(translations: translations)) : null,
                            style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                            child: state.status.isSubmit ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.next),
                          ),
                        ),
                      ] else if (state.currentPageIndex == 1) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestBusinessPlanSelectEvent()),
                            style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                            child: state.status.isPayment
                                ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0)
                                : Text(state.businessModel == 'subscription' ? translate.next : translate.submit),
                          ),
                        ),
                      ] else if (state.currentPageIndex == 2) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestCreateProfileRequestEvent()),
                            style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                            child: state.status.isPayment
                                ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0)
                                : Text(state.haveTrial && state.paymentId == 'trial' ? translate.submit : "${translate.pay} ${kAppPriceFormat(state.payAmount)}"),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class SubscriptionPackageInfoWidget extends StatelessWidget {
  final RestaurantRegisterRequestSubscriptionPackageConfigModel model;
  final int length;
  final String selectedPackage;
  const SubscriptionPackageInfoWidget({super.key, required this.model, required this.length, required this.selectedPackage});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestChangeSubscriptionPackageEvent(subscriptionPackage: model.id!)),
      child: Container(
        width: length > 1 ? MediaQuery.of(context).size.width / 1.5 : MediaQuery.of(context).size.width / 1.1,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: selectedPackage == model.id! ? Theme.of(context).primaryColor : Theme.of(context).shadowColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [ClipOval(child: CacheNetworkImageWidget(width: 50.0, height: 50.0, imageUrl: model.icon!))],
            ),
            kAppSpacerVertical(height: 20),
            Center(
              child: Text(kAppTrimWord(model.name!, 25), style: kAppLblSmallFontBold(context, color: selectedPackage == model.id! ? 'primary' : '')),
            ),
            model.discount! <= 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Text(kAppPriceFormat(model.price!), style: kAppLblTinyMediumFontSemi(context))],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(kAppPriceFormat(model.price!), style: kAppLblTinyStrokeFontRegular(context)),
                      kAppSpacerHorizontal(width: 5),
                      Text(kAppPriceFormat(model.offerPrice!), style: kAppLblTinyMediumFontSemi(context)),
                    ],
                  ),
            kAppSpacerVertical(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(translate.validity, style: kAppLblSmallFontMedium(context)),
                Text("${model.validity!} ${translate.days}", style: kAppLblSmallFontMedium(context)),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(translate.order_limit, style: kAppLblSmallFontMedium(context)),
                Text(model.orderLimit! != -1 ? '${model.orderLimit!} ${translate.per_month}' : translate.unlimited, style: kAppLblSmallFontMedium(context)),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(translate.product_limit, style: kAppLblSmallFontMedium(context)),
                Text(model.productLimit! != -1 ? '${model.productLimit!}' : translate.unlimited, style: kAppLblSmallFontMedium(context)),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(translate.commission, style: kAppLblSmallFontMedium(context)),
                Text("${model.commission} %", style: kAppLblSmallFontMedium(context)),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(translate.pos, style: kAppLblSmallFontMedium(context)),
                Image.asset(model.pos! == true ? AssetsUrl.imageURL.subscriptionPermission : AssetsUrl.imageURL.subscriptionNoPermission, height: 15, width: 15),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(translate.own_deliveryman, style: kAppLblSmallFontMedium(context)),
                Image.asset(model.ownDriver! == true ? AssetsUrl.imageURL.subscriptionPermission : AssetsUrl.imageURL.subscriptionNoPermission, height: 15, width: 15),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(translate.promote_to_system, style: kAppLblSmallFontMedium(context)),
                Image.asset(model.promote! == true ? AssetsUrl.imageURL.subscriptionPermission : AssetsUrl.imageURL.subscriptionNoPermission, height: 15, width: 15),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(translate.custom_category, style: kAppLblSmallFontMedium(context)),
                Image.asset(model.customCategory! == true ? AssetsUrl.imageURL.subscriptionPermission : AssetsUrl.imageURL.subscriptionNoPermission, height: 15, width: 15),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(translate.multi_outlet, style: kAppLblSmallFontMedium(context)),
                Image.asset(model.multiOutlet! == true ? AssetsUrl.imageURL.subscriptionPermission : AssetsUrl.imageURL.subscriptionNoPermission, height: 15, width: 15),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(translate.table_booking, style: kAppLblSmallFontMedium(context)),
                Image.asset(model.preBooking! == true ? AssetsUrl.imageURL.subscriptionPermission : AssetsUrl.imageURL.subscriptionNoPermission, height: 15, width: 15),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(translate.table_order, style: kAppLblSmallFontMedium(context)),
                Image.asset(model.tableOrder! == true ? AssetsUrl.imageURL.subscriptionPermission : AssetsUrl.imageURL.subscriptionNoPermission, height: 15, width: 15),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(translate.tittin_subscription_packages, style: kAppLblSmallFontMedium(context)),
                Image.asset(model.tiffinSubscription! == true ? AssetsUrl.imageURL.subscriptionPermission : AssetsUrl.imageURL.subscriptionNoPermission, height: 15, width: 15),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(translate.waiter_service, style: kAppLblSmallFontMedium(context)),
                Image.asset(model.ownWaiter! == true ? AssetsUrl.imageURL.subscriptionPermission : AssetsUrl.imageURL.subscriptionNoPermission, height: 15, width: 15),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(translate.own_kitchen_owner_permission, style: kAppLblSmallFontMedium(context)),
                Image.asset(model.ownKitchen! == true ? AssetsUrl.imageURL.subscriptionPermission : AssetsUrl.imageURL.subscriptionNoPermission, height: 15, width: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FormElementTextWidget extends StatefulWidget {
  final int formIndex;
  final String fieldName;
  final String placeholder;
  final bool isRequired;
  final bool isSubmitted;
  final String formValue;
  const FormElementTextWidget({super.key, required this.formIndex, required this.fieldName, required this.placeholder, required this.isRequired, required this.isSubmitted, required this.formValue});

  @override
  State<FormElementTextWidget> createState() => _FormElementTextWidgetState();
}

class _FormElementTextWidgetState extends State<FormElementTextWidget> {
  late TextEditingController formTextController;

  @override
  void initState() {
    super.initState();
    formTextController = TextEditingController(text: widget.formValue);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: formTextController,
        decoration: kAppInputDecoration(context, lblText: widget.fieldName, errText: widget.isRequired && widget.isSubmitted && widget.formValue.isEmpty ? translate.form_required : null),
        style: kAppLblLargeFontMedium(context),
        keyboardType: TextInputType.text,
        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\w\s]+'))],
        onChanged: (value) {
          if (value.startsWith(' ')) {
            formTextController.text = value.trimLeft();
            formTextController.selection = TextSelection.collapsed(offset: formTextController.text.length);
          }
          if (RegExp(r'^[0-9]').hasMatch(value)) {
            formTextController.text = value.substring(1);
            formTextController.selection = TextSelection.collapsed(offset: formTextController.text.length);
          }
          context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestFormTextInputChangeEvent(formIndex: widget.formIndex, value: formTextController.text));
        },
        textInputAction: TextInputAction.next,
      ),
    );
  }
}

class FormElementNumberWidget extends StatefulWidget {
  final int formIndex;
  final String fieldName;
  final String placeholder;
  final bool isRequired;
  final bool isSubmitted;
  final String formValue;
  const FormElementNumberWidget({super.key, required this.formIndex, required this.fieldName, required this.placeholder, required this.isRequired, required this.isSubmitted, required this.formValue});

  @override
  State<FormElementNumberWidget> createState() => _FormElementNumberWidgetState();
}

class _FormElementNumberWidgetState extends State<FormElementNumberWidget> {
  late TextEditingController formNumberController;

  @override
  void initState() {
    super.initState();
    formNumberController = TextEditingController(text: widget.formValue);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: formNumberController,
        decoration: kAppInputDecoration(context, lblText: widget.fieldName, errText: widget.isRequired && widget.isSubmitted && widget.formValue.isEmpty ? translate.form_required : null),
        style: kAppLblLargeFontMedium(context),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
        onChanged: (value) => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestFormTextInputChangeEvent(formIndex: widget.formIndex, value: formNumberController.text)),
        textInputAction: TextInputAction.next,
      ),
    );
  }
}

class FormElementEmailWidget extends StatefulWidget {
  final int formIndex;
  final String fieldName;
  final String placeholder;
  final bool isRequired;
  final bool isSubmitted;
  final String formValue;
  const FormElementEmailWidget({super.key, required this.formIndex, required this.fieldName, required this.placeholder, required this.isRequired, required this.isSubmitted, required this.formValue});

  @override
  State<FormElementEmailWidget> createState() => _FormElementEmailWidgetState();
}

class _FormElementEmailWidgetState extends State<FormElementEmailWidget> {
  late TextEditingController formEmailController;

  @override
  void initState() {
    super.initState();
    formEmailController = TextEditingController(text: widget.formValue);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: formEmailController,
        decoration: kAppInputDecoration(context, lblText: widget.fieldName, errText: widget.isRequired && widget.isSubmitted && widget.formValue.isEmpty ? translate.form_required : null),
        style: kAppLblLargeFontMedium(context),
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestFormTextInputChangeEvent(formIndex: widget.formIndex, value: formEmailController.text)),
        textInputAction: TextInputAction.next,
      ),
    );
  }
}

class FormElementDateWidget extends StatefulWidget {
  final int formIndex;
  final String fieldName;
  final String placeholder;
  final bool isRequired;
  final bool isSubmitted;
  final String formValue;
  const FormElementDateWidget({super.key, required this.formIndex, required this.fieldName, required this.placeholder, required this.isRequired, required this.isSubmitted, required this.formValue});

  @override
  State<FormElementDateWidget> createState() => _FormElementDateWidgetState();
}

class _FormElementDateWidgetState extends State<FormElementDateWidget> {
  late TextEditingController formDateController;

  @override
  void initState() {
    super.initState();
    formDateController = TextEditingController(text: widget.formValue);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: formDateController,
        decoration: kAppInputDecoration(context, lblText: widget.fieldName, errText: widget.isRequired && widget.isSubmitted && widget.formValue.isEmpty ? translate.form_required : null),
        style: kAppLblLargeFontMedium(context),
        readOnly: false,
        keyboardType: TextInputType.number,
        onTap: () async {
          await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime(2100)).then((value) {
            if (!context.mounted) return;
            if (value != null) {
              final String selectedDate = '${value.year}-${value.month}-${value.day}';
              formDateController.text = selectedDate;
              context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestFormTextInputChangeEvent(formIndex: widget.formIndex, value: selectedDate));
            }
          });
        },
        textInputAction: TextInputAction.next,
      ),
    );
  }
}

class FormElementCheckboxWidget extends StatefulWidget {
  final int formIndex;
  final String fieldName;
  final String placeholder;
  final bool isRequired;
  final bool isSubmitted;
  final String formValue;
  final List<FormElementItemConfigModel> items;
  const FormElementCheckboxWidget({super.key, required this.formIndex, required this.fieldName, required this.placeholder, required this.isRequired, required this.isSubmitted, required this.formValue, required this.items});

  @override
  State<FormElementCheckboxWidget> createState() => _FormElementCheckboxWidgetState();
}

class _FormElementCheckboxWidgetState extends State<FormElementCheckboxWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.fieldName, style: kAppLblTinyFontRegular(context)),
        kAppSpacerVertical(height: 5),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            widget.items.length,
            (checkboxIndex) => GestureDetector(
              onTap: () => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestFormCheckboxChangeEvent(formIndex: widget.formIndex, checkboxIndex: checkboxIndex)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.items[checkboxIndex].name!, style: kAppLblTinyFontRegular(context)),
                    Icon(widget.items[checkboxIndex].value! == true ? Icons.check_box : Icons.check_box_outline_blank_outlined, size: 12, color: Theme.of(context).primaryColor),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FormElementPhoneWidget extends StatefulWidget {
  final int formIndex;
  final String fieldName;
  final String placeholder;
  final bool isRequired;
  final bool isSubmitted;
  final String formValue;
  final String extraFormValue;
  final String flag;
  const FormElementPhoneWidget({
    super.key,
    required this.formIndex,
    required this.fieldName,
    required this.placeholder,
    required this.isRequired,
    required this.isSubmitted,
    required this.formValue,
    required this.extraFormValue,
    required this.flag,
  });

  @override
  State<FormElementPhoneWidget> createState() => _FormElementPhoneWidgetState();
}

class _FormElementPhoneWidgetState extends State<FormElementPhoneWidget> {
  late TextEditingController formCountryCodeController;
  late TextEditingController formMobileController;

  @override
  void initState() {
    super.initState();
    formCountryCodeController = TextEditingController(text: '${widget.flag} ${widget.extraFormValue}');
    formMobileController = TextEditingController(text: widget.formValue);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: TextFormField(
              controller: formCountryCodeController,
              readOnly: true,
              decoration: kAppInputDecoration(context, lblText: translate.country_code, errText: widget.isRequired && widget.isSubmitted && widget.formValue.isEmpty ? translate.form_required : null),
              style: kAppLblSmallFontMedium(context),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              onTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return CountryCodeModalScreen(code: widget.extraFormValue);
                        },
                        fullscreenDialog: true,
                      ),
                    )
                    .then((value) {
                      if (!context.mounted) return;
                      CountryCodeModalResponseModel countryCodeResponse = CountryCodeModalResponseModel.fromJson(value);
                      if (countryCodeResponse.action!) {
                        formCountryCodeController.text = '${countryCodeResponse.flag} (${countryCodeResponse.dialCode})';
                        context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestFormCountryCodeChangeEvent(formIndex: widget.formIndex, value: countryCodeResponse.dialCode!));
                      }
                    });
              },
            ),
          ),
        ),
        kAppSpacerHorizontal(width: 10),
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: TextFormField(
              controller: formMobileController,
              decoration: kAppInputDecoration(context, lblText: widget.fieldName, errText: widget.isRequired && widget.isSubmitted && widget.formValue.isEmpty ? translate.form_required : null),
              style: kAppLblLargeFontMedium(context),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
              onChanged: (value) => context.read<RestaurantRegisterRequestBloc>().add(RestaurantRegisterRequestFormTextInputChangeEvent(formIndex: widget.formIndex, value: formMobileController.text)),
              textInputAction: TextInputAction.next,
            ),
          ),
        ),
      ],
    );
  }
}

class RegisterRequestLoadingView extends StatelessWidget {
  const RegisterRequestLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLine(
          style: SkeletonLineStyle(height: 100.0, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(5.0)),
        ),
        kAppSpacerVertical(height: 20),
        SkeletonLine(
          style: SkeletonLineStyle(height: 100.0, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(5.0)),
        ),
        kAppSpacerVertical(height: 20),
        SkeletonLine(
          style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(5)),
        ),
        kAppSpacerVertical(height: 10),
        SkeletonLine(
          style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(5)),
        ),
        kAppSpacerVertical(height: 10),
        SkeletonLine(
          style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(5)),
        ),
        kAppSpacerVertical(height: 10),
        SkeletonLine(
          style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(5)),
        ),
      ],
    );
  }
}

class RegisterRequestErrorView extends StatelessWidget {
  const RegisterRequestErrorView({super.key});

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

class FormImageConfigModel {
  String? uuid;
  XFile? file;

  FormImageConfigModel({this.uuid, this.file});

  FormImageConfigModel.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    file = json['file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['file'] = file;
    return data;
  }
}

