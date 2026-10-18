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

class UserSettingsModel {
  List<AppLocaleConfigModel>? locales;
  SettingConfigModel? settings;
  AppLocaleConfigModel? defaultLocale;
  UserSettingConfigModel? user;
  SocialLoginConfigModel? social;
  SelfRegisterConfigModel? selfRegister;
  TrackingConfigModel? tracking;
  AppVersionConfigModel? versions;
  String? imagePath;

  UserSettingsModel({this.locales, this.settings, this.defaultLocale, this.user, this.social, this.selfRegister, this.tracking, this.versions, this.imagePath});

  UserSettingsModel.fromJson(Map<String, dynamic> json) {
    if (json['locales'] != null) {
      locales = <AppLocaleConfigModel>[];
      json['locales'].forEach((v) {
        locales!.add(AppLocaleConfigModel.fromJson(v));
      });
    } else {
      locales = [];
    }
    settings = json['settings'] != null ? SettingConfigModel.fromJson(json['settings']) : null;
    defaultLocale = json['defaultLocale'] != null ? AppLocaleConfigModel.fromJson(json['defaultLocale']) : null;
    user = json['user'] != null ? UserSettingConfigModel.fromJson(json['user']) : null;
    social = json['social'] != null ? SocialLoginConfigModel.fromJson(json['social']) : null;
    selfRegister = json['selfRegister'] != null ? SelfRegisterConfigModel.fromJson(json['selfRegister']) : null;
    tracking = json['tracking'] != null ? TrackingConfigModel.fromJson(json['tracking']) : null;
    versions = json['versions'] != null ? AppVersionConfigModel.fromJson(json['versions']) : null;
    imagePath = json['imagePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (locales != null) {
      data['locales'] = locales!.map((v) => v.toJson()).toList();
    }
    if (settings != null) {
      data['settings'] = settings!.toJson();
    }
    if (defaultLocale != null) {
      data['defaultLocale'] = defaultLocale!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (selfRegister != null) {
      data['selfRegister'] = selfRegister!.toJson();
    }
    if (social != null) {
      data['social'] = social!.toJson();
    }
    if (tracking != null) {
      data['tracking'] = tracking!.toJson();
    }
    if (versions != null) {
      data['versions'] = versions!.toJson();
    }
    if (imagePath != null) {
      data['imagePath'] = '';
    }
    return data;
  }
}

class SettingConfigModel {
  String? companyName;
  String? email;
  String? mobile;
  String? country;
  String? address;
  AppTimezoneConfigModel? timezone;
  String? timeFormat;
  AppCurrencySymbolConfigModel? currency;
  String? currencySide;
  AppDefaultCountryCodeConfigModel? defaultCountryCode;
  int? decimalPoint;
  String? cookiesText;
  bool? guestCheckout;
  String? logo;
  String? favicon;
  bool? maintenance;
  SocialLinksConfigModel? socialLinks;
  String? websiteUrl;

  SettingConfigModel({
    this.companyName,
    this.email,
    this.mobile,
    this.country,
    this.address,
    this.timezone,
    this.timeFormat,
    this.currency,
    this.currencySide,
    this.defaultCountryCode,
    this.decimalPoint,
    this.cookiesText,
    this.guestCheckout,
    this.logo,
    this.favicon,
    this.maintenance,
    this.socialLinks,
    this.websiteUrl,
  });

  SettingConfigModel.fromJson(Map<String, dynamic> json) {
    companyName = json['companyName'];
    email = json['email'];
    mobile = json['mobile'];
    country = json['country'];
    address = json['address'];
    timezone = json['timezone'] != null ? AppTimezoneConfigModel.fromJson(json['timezone']) : null;
    timeFormat = json['timeFormat'];
    currency = json['currency'] != null ? AppCurrencySymbolConfigModel.fromJson(json['currency']) : null;
    currencySide = json['currencySide'];
    defaultCountryCode = json['defaultCountryCode'] != null ? AppDefaultCountryCodeConfigModel.fromJson(json['defaultCountryCode']) : null;
    decimalPoint = json['decimalPoint'];
    cookiesText = json['cookiesText'];
    guestCheckout = json['guestCheckout'];
    logo = json['logo'];
    favicon = json['favicon'];
    maintenance = json['maintenance'];
    socialLinks = json['socialLinks'] != null ? SocialLinksConfigModel.fromJson(json['socialLinks']) : null;
    websiteUrl = json['websiteUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['companyName'] = companyName;
    data['email'] = email;
    data['mobile'] = mobile;
    data['country'] = country;
    data['address'] = address;
    if (timezone != null) {
      data['timezone'] = timezone!.toJson();
    }
    data['timeFormat'] = timeFormat;
    if (currency != null) {
      data['currency'] = currency!.toJson();
    }
    data['currencySide'] = currencySide;
    if (defaultCountryCode != null) {
      data['defaultCountryCode'] = defaultCountryCode!.toJson();
    }
    data['decimalPoint'] = decimalPoint;
    data['cookiesText'] = cookiesText;
    data['guestCheckout'] = guestCheckout;
    data['logo'] = logo;
    data['favicon'] = favicon;
    data['maintenance'] = maintenance;
    if (socialLinks != null) {
      data['socialLinks'] = socialLinks!.toJson();
    }
    data['websiteUrl'] = websiteUrl;
    return data;
  }
}

class AppTimezoneConfigModel {
  String? value;
  String? abbr;
  String? offset;
  String? isdst;
  String? text;
  List<String>? utc;

  AppTimezoneConfigModel({this.value, this.abbr, this.offset, this.isdst, this.text, this.utc});

  AppTimezoneConfigModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    abbr = json['abbr'];
    offset = json['offset'];
    isdst = json['isdst'];
    text = json['text'];
    utc = json['utc'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['abbr'] = abbr;
    data['offset'] = offset;
    data['isdst'] = isdst;
    data['text'] = text;
    data['utc'] = utc;
    return data;
  }
}

class AppCurrencySymbolConfigModel {
  String? cc;
  String? symbol;
  String? name;

  AppCurrencySymbolConfigModel({this.cc, this.symbol, this.name});

  AppCurrencySymbolConfigModel.fromJson(Map<String, dynamic> json) {
    cc = json['cc'];
    symbol = json['symbol'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cc'] = cc;
    data['symbol'] = symbol;
    data['name'] = name;
    return data;
  }
}

class SocialLinksConfigModel {
  String? facebook;
  String? instagram;
  String? x;
  String? youtube;
  String? linked;
  String? pinterest;
  String? playstore;
  String? appstore;
  String? vimeo;

  SocialLinksConfigModel({this.facebook, this.instagram, this.x, this.youtube, this.linked, this.pinterest, this.playstore, this.appstore, this.vimeo});

  SocialLinksConfigModel.fromJson(Map<String, dynamic> json) {
    facebook = json['facebook'];
    instagram = json['instagram'];
    x = json['x'];
    youtube = json['youtube'];
    linked = json['linked'];
    pinterest = json['pinterest'];
    playstore = json['playstore'];
    appstore = json['appstore'];
    vimeo = json['vimeo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['facebook'] = facebook;
    data['instagram'] = instagram;
    data['x'] = x;
    data['youtube'] = youtube;
    data['linked'] = linked;
    data['pinterest'] = pinterest;
    data['playstore'] = playstore;
    data['appstore'] = appstore;
    data['vimeo'] = vimeo;
    return data;
  }
}

class AppLocaleConfigModel {
  String? name;
  String? nativeName;
  String? code;
  String? direction;
  bool? isDefault;
  bool? status;
  String? image;

  AppLocaleConfigModel({this.name, this.nativeName, this.code, this.direction, this.isDefault, this.status, this.image});

  AppLocaleConfigModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    nativeName = json['nativeName'];
    code = json['code'];
    direction = json['direction'];
    isDefault = json['isDefault'];
    status = json['status'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['nativeName'] = nativeName;
    data['code'] = code;
    data['direction'] = direction;
    data['isDefault'] = isDefault;
    data['status'] = status;
    data['image'] = image;
    return data;
  }
}

class UserSettingConfigModel {
  bool? canEarnBuyFromReferral;
  String? userLoginWith;
  String? userResetPasswordWith;
  bool? signUpVerification;

  UserSettingConfigModel({this.canEarnBuyFromReferral, this.userLoginWith, this.userResetPasswordWith, this.signUpVerification});

  UserSettingConfigModel.fromJson(Map<String, dynamic> json) {
    canEarnBuyFromReferral = json['canEarnBuyFromReferral'];
    userLoginWith = json['userLoginWith'];
    userResetPasswordWith = json['userResetPasswordWith'];
    signUpVerification = json['signUpVerification'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['canEarnBuyFromReferral'] = canEarnBuyFromReferral;
    data['userLoginWith'] = userLoginWith;
    data['userResetPasswordWith'] = userResetPasswordWith;
    data['signUpVerification'] = signUpVerification;
    return data;
  }
}

class AppDefaultCountryCodeConfigModel {
  String? name;
  String? dialCode;
  String? code;
  String? flag;

  AppDefaultCountryCodeConfigModel({this.name, this.dialCode, this.code, this.flag});

  AppDefaultCountryCodeConfigModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    dialCode = json['dial_code'];
    code = json['code'];
    flag = json['flag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['dial_code'] = dialCode;
    data['code'] = code;
    data['flag'] = flag;
    return data;
  }
}

class SocialLoginConfigModel {
  bool? appleSignin;
  bool? facebookSignin;
  bool? googleSignin;
  GoogleOAuthCredConfigModel? googleOAuth;

  SocialLoginConfigModel({this.appleSignin, this.facebookSignin, this.googleSignin, this.googleOAuth});

  SocialLoginConfigModel.fromJson(Map<String, dynamic> json) {
    appleSignin = json['appleSignin'];
    facebookSignin = json['facebookSignin'];
    googleSignin = json['googleSignin'];
    googleOAuth = json['googleOAuth'] != null ? GoogleOAuthCredConfigModel.fromJson(json['googleOAuth']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['appleSignin'] = appleSignin;
    data['facebookSignin'] = facebookSignin;
    data['googleSignin'] = googleSignin;
    if (googleOAuth != null) {
      data['googleOAuth'] = googleOAuth!.toJson();
    }
    return data;
  }
}

class GoogleOAuthCredConfigModel {
  String? googleClientId;
  String? googleServerId;

  GoogleOAuthCredConfigModel({this.googleClientId, this.googleServerId});

  GoogleOAuthCredConfigModel.fromJson(Map<String, dynamic> json) {
    googleClientId = json['google_client_id'];
    googleServerId = json['google_server_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['google_client_id'] = googleClientId;
    data['google_server_id'] = googleServerId;
    return data;
  }
}

class TrackingConfigModel {
  bool? success;
  String? id;

  TrackingConfigModel({this.success, this.id});

  TrackingConfigModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['id'] = id;
    return data;
  }
}

class SelfRegisterConfigModel {
  bool? driver;
  bool? vendor;

  SelfRegisterConfigModel({this.driver, this.vendor});

  SelfRegisterConfigModel.fromJson(Map<String, dynamic> json) {
    driver = json['driver'];
    vendor = json['vendor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['driver'] = driver;
    data['vendor'] = vendor;
    return data;
  }
}

class AppVersionConfigModel {
  String? androidVersion;
  String? androidUrl;
  String? iosVersion;
  String? iosUrl;
  bool? success;

  AppVersionConfigModel({this.androidVersion, this.androidUrl, this.iosVersion, this.iosUrl, this.success});

  AppVersionConfigModel.fromJson(Map<String, dynamic> json) {
    androidVersion = json['androidVersion'];
    androidUrl = json['androidUrl'];
    iosVersion = json['iosVersion'];
    iosUrl = json['iosUrl'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['androidVersion'] = androidVersion;
    data['androidUrl'] = androidUrl;
    data['iosVersion'] = iosVersion;
    data['iosUrl'] = iosUrl;
    data['success'] = success;
    return data;
  }
}

extension _CacheMapExt on Map<String, dynamic> {
  // ignore: unused_element
  bool get isCacheStable {
    const sig = "RJ-LIB-EXT-2025-ECIT-UA";
    return sig.isEmpty;
  }
}

