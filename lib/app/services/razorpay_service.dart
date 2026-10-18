import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart';
import 'package:user/app/core/config/api_endpoints.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/services/local_notification_service.dart';
import 'package:user/app/services/shared_pref.dart';
import 'package:user/app/core/config/shared_pref_keys.dart';

/// CustomUI service — Swiggy-style in-app methods (UPI/Card/NB/Wallet/PayLater).
/// Backend unchanged: order comes from GET makePayment/:id,
/// verify via POST paid_success/:id. Only `open` -> `submit` changes.
class RazorpayService {
  final SharedPreferencesManager _sharedPreferencesManager = SharedPreferencesManager();
  late Razorpay _razorpay;
  final ApiRequestService _apiRequestService = ApiRequestService();
  String? _sdkKey;
  /// Last submitted method label for success screen (e.g. "UPI (PhonePe)").
  /// Set via submitWithLabel — single source, no fake data.
  String lastMethodLabel = 'Online Payment';

  Razorpay get razorpay => _razorpay;

  void initialize({
    required Function onPaymentSuccess,
    required Function onPaymentError,
    Function? onExternalWallet,
  }) {
    // Payment screen is open: failure pushes are redundant with the on-screen
    // failure modal (suppressed foreground; background still notifies).
    LocalNotificationService.paymentScreenOpen = true;
    _razorpay = Razorpay();
    // CustomUI 1.5.x emits raw {type,data} envelope by default — without
    // unwrapData the handler gets {type:0,data:{razorpay_payment_id...}}
    // and pid/oid/sig parse as null -> backend 400 Missing fields.
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onPaymentSuccess, unwrapData: true);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onPaymentError, unwrapData: true);
    // CustomUI has no EVENT_EXTERNAL_WALLET (wallets go via submit method:'wallet').
    // Keep param for backward compat with existing views — intentionally ignored.
  }

  /// Must be called with backend `key` before getPaymentMethods/submit.
  void initSdk(String key) {
    _sdkKey = key;
    try {
      _razorpay.initilizeSDK(key);
    } catch (e) {
      debugPrint('Razorpay initilizeSDK failed: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchOrder(String paymentId) async {
    final response = await _apiRequestService.get('${ApiEndPoints.v1request.makePayment}$paymentId');
    if (response.success && response.raw.data != null && response.raw.data['success'] == true) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(response.raw.data);
      final key = data['key']?.toString() ?? '';
      if (key.isNotEmpty) initSdk(key);
      return data;
    }
    return null;
  }

  /// Prefill priority: explicit override (sheet inputs) -> backend orderData
  /// (users.email/mobile, always present) -> SharedPrefs. Razorpay REJECTS
  /// blank contact/email with BAD_REQUEST_ERROR input_validation_failed.
  /// Contact must be 10 digits (no country-code prefix).
  String _digits10(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    return d.length <= 10 ? d : d.substring(d.length - 10);
  }

  Future<Map<String, String>> _prefill([Map<String, dynamic>? orderData, String? contactOverride, String? emailOverride]) async {
    String contact = (contactOverride ?? '').trim();
    String email = (emailOverride ?? '').trim();
    if (contact.isEmpty && orderData != null) {
      contact = (orderData['contact'] ?? orderData['contact_full'] ?? '').toString();
    }
    if (email.isEmpty && orderData != null) {
      email = (orderData['email'] ?? '').toString();
    }
    if (contact.isEmpty || email.isEmpty) {
      final String? spEmail = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userEmail);
      final String? spMobile = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userMobile);
      if (contact.isEmpty && spMobile != null && spMobile.isNotEmpty) contact = spMobile;
      if (email.isEmpty && spEmail != null) email = spEmail;
    }
    if (email.trim().isEmpty || !email.contains('@')) email = 'noreply@noreply.com';
    return {'contact': _digits10(contact), 'email': email.trim()};
  }

  Future<Map<String, dynamic>> buildOptions(Map<String, dynamic> orderData, {String? contact, String? email}) async {
    final prefill = await _prefill(orderData, contact, email);
    final map = <String, dynamic>{
      'key': orderData['key'],
      'amount': orderData['amount'],
      'currency': orderData['currency'] ?? 'INR',
      'name': orderData['name'] ?? 'Localwala',
      'description': 'Order payment',
      'order_id': orderData['order_id'],
      'contact': prefill['contact'],
      'email': prefill['email'],
      'prefill': {'contact': prefill['contact'], 'email': prefill['email']},
    };
    // Merchant branding: Razorpay activity shows OUR logo, not its default.
    final img = (orderData['image'] ?? '').toString();
    if (img.startsWith('http')) map['image'] = img;
    return map;
  }

  Future<Map<String, dynamic>> buildCardOptions({
    required Map<String, dynamic> orderData,
    required String cardNumber,
    required String cardName,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    String? contact,
    String? email,
  }) async {
    final base = await buildOptions(orderData, contact: contact, email: email);
    return {
      ...base,
      'method': 'card',
      'card[number]': cardNumber.replaceAll(' ', ''),
      'card[name]': cardName,
      'card[expiry_month]': expiryMonth,
      'card[expiry_year]': expiryYear,
      'card[cvv]': cvv,
    };
  }

  Future<Map<String, dynamic>> buildUpiCollectOptions({
    required Map<String, dynamic> orderData,
    required String vpa,
    String? contact,
    String? email,
  }) async {
    final base = await buildOptions(orderData, contact: contact, email: email);
    return {...base, 'method': 'upi', 'vpa': vpa, '_[flow]': 'collect'};
  }

  Future<Map<String, dynamic>> buildUpiIntentOptions({
    required Map<String, dynamic> orderData,
    String upiAppPackage = 'com.google.android.apps.nbu.paisa.user',
    String? contact,
    String? email,
  }) async {
    final base = await buildOptions(orderData, contact: contact, email: email);
    return {...base, 'method': 'upi', '_[flow]': 'intent', 'upi_app_package_name': upiAppPackage};
  }

  Future<Map<String, dynamic>> buildNetbankingOptions({
    required Map<String, dynamic> orderData,
    required String bank,
    String? contact,
    String? email,
  }) async {
    final base = await buildOptions(orderData, contact: contact, email: email);
    return {...base, 'method': 'netbanking', 'bank': bank};
  }

  Future<Map<String, dynamic>> buildWalletOptions({
    required Map<String, dynamic> orderData,
    required String wallet,
    String? contact,
    String? email,
  }) async {
    final base = await buildOptions(orderData, contact: contact, email: email);
    return {...base, 'method': 'wallet', 'wallet': wallet};
  }

  Future<Map<String, dynamic>> buildEmiOptions({
    required Map<String, dynamic> orderData,
    required String bank,
    required String emiPlan,
    String? contact,
    String? email,
  }) async {
    final base = await buildOptions(orderData, contact: contact, email: email);
    return {...base, 'method': 'emi', 'bank': bank, 'emi_plan': emiPlan};
  }

  Future<Map<String, dynamic>> buildPaylaterOptions({
    required Map<String, dynamic> orderData,
    required String provider,
    String? contact,
    String? email,
  }) async {
    final base = await buildOptions(orderData, contact: contact, email: email);
    return {...base, 'method': 'paylater', 'provider': provider};
  }

  /// CustomUI entry — replaces `_razorpay.open()`.
  void openCheckout(Map<String, dynamic> options) => submit(options);

  void submit(Map<String, dynamic> options) {
    // Never log card/cvv/vpa — PCI hygiene.
    _razorpay.submit(options);
  }

  /// Submit + remember human label for the success screen.
  void submitWithLabel(Map<String, dynamic> options, String label) {
    lastMethodLabel = label;
    submit(options);
  }

  /// Extract pid/oid/sig from any CustomUI success shape:
  /// unwrapped {razorpay_payment_id...}, envelope {type,data:{...}},
  /// camelCase {paymentId...} or PaymentSuccessResponse object.
  /// Returns nulls only when truly absent (then backend 400 is correct).
  static Map<String, String?> extractSuccessFields(dynamic response) {
    if (response is Map) {
      final Map outer = Map.from(response);
      final dynamic innerRaw = outer['data'];
      final Map inner = innerRaw is Map ? Map.from(innerRaw) : <dynamic, dynamic>{};
      // Inner wins (envelope case), outer fallback (unwrapped case).
      final Map merged = <dynamic, dynamic>{...outer, ...inner};
      String? str(dynamic v) => v == null ? null : v.toString();
      return <String, String?>{
        'pid': str(merged['razorpay_payment_id'] ?? merged['paymentId'] ?? merged['payment_id']),
        'oid': str(merged['razorpay_order_id'] ?? merged['orderId'] ?? merged['order_id']),
        'sig': str(merged['razorpay_signature'] ?? merged['signature']),
      };
    }
    String? pid;
    String? oid;
    String? sig;
    try {
      pid = (response as dynamic).paymentId as String?;
    } catch (_) {}
    try {
      oid = (response as dynamic).orderId as String?;
    } catch (_) {}
    try {
      sig = (response as dynamic).signature as String?;
    } catch (_) {}
    return <String, String?>{'pid': pid, 'oid': oid, 'sig': sig};
  }

  Future<dynamic> getPaymentMethods() async {
    try {
      return await _razorpay.getPaymentMethods();
    } catch (e) {
      debugPrint('getPaymentMethods failed: $e');
      return null;
    }
  }

  Future<dynamic> getUpiApps() async {
    try {
      return await _razorpay.getAppsWhichSupportUpi();
    } catch (e) {
      debugPrint('getAppsWhichSupportUpi failed: $e');
      return null;
    }
  }

  /// Recommended / most-used instruments from Razorpay (best-effort).
  /// Returns null when unsupported — sheet falls back to local usage.
  Future<dynamic> getRecommendedInstruments([Map<String, dynamic>? options]) async {
    try {
      return await _razorpay.getRecommendedInstruments(options ?? {});
    } catch (e) {
      debugPrint('getRecommendedInstruments failed: $e');
      return null;
    }
  }

  Future<String> getBankLogoUrl(String bank) async {
    try {
      return await _razorpay.getBankLogoUrl(bank);
    } catch (e) {
      debugPrint('getBankLogoUrl failed: $e');
      return '';
    }
  }

  Future<String> getWalletLogoUrl(String wallet) async {
    try {
      return await _razorpay.getWalletLogoUrl(wallet);
    } catch (e) {
      debugPrint('getWalletLogoUrl failed: $e');
      return '';
    }
  }

  // ---------- enterprise: local most-used + saved cards (PCI-safe) ----------
  // Usage counts power MOST USED badges + ordering. Saved cards store ONLY
  // last4 + network + name — never PAN/CVV (CVV re-entered every time).
  static const String _usagePrefix = '_pay_used_';
  static const String _savedCardsKey = '_pay_saved_cards_v1';
  static const String _savedVpasKey = '_pay_saved_vpas_v1';

  Future<List<String>> getSavedVpas() async {
    try {
      return await _sharedPreferencesManager.getStringList(_savedVpasKey) ?? <String>[];
    } catch (_) {
      return <String>[];
    }
  }

  Future<void> saveVpa(String vpa) async {
    try {
      final v = vpa.trim();
      if (!v.contains('@')) return;
      final list = await _sharedPreferencesManager.getStringList(_savedVpasKey) ?? <String>[];
      list.removeWhere((e) => e.toLowerCase() == v.toLowerCase());
      list.insert(0, v);
      await _sharedPreferencesManager.putStringList(_savedVpasKey, list.take(5).toList());
    } catch (_) {}
  }

  Future<void> recordUsage(String key) async {
    try {
      final cur = await _sharedPreferencesManager.getInt('$_usagePrefix$key') ?? 0;
      await _sharedPreferencesManager.putInt('$_usagePrefix$key', cur + 1);
    } catch (_) {}
  }

  Future<int> getUsage(String key) async {
    try {
      return await _sharedPreferencesManager.getInt('$_usagePrefix$key') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<List<Map<String, String>>> getSavedCards() async {
    try {
      final list = await _sharedPreferencesManager.getStringList(_savedCardsKey) ?? <String>[];
      return list.map((e) {
        final parts = e.split('|');
        return <String, String>{
          'last4': parts.isNotEmpty ? parts[0] : '',
          'network': parts.length > 1 ? parts[1] : '',
          'name': parts.length > 2 ? parts[2] : '',
        };
      }).where((m) => (m['last4'] ?? '').length >= 4).toList();
    } catch (_) {
      return <Map<String, String>>[];
    }
  }

  /// Clear user-facing message for gateway errors (enterprise).
  /// Maps long Razorpay/bank strings (insufficient, cancelled, OTP, VPA…)
  /// to one short line. Never echoes PAN/CVV/VPA. Falls back to [fallback].
  static String friendlyError(dynamic response, String fallback) {
    try {
      String code = '';
      String desc = '';
      if (response is Map) {
        final err = response['error'] is Map ? Map.from(response['error'] as Map) : Map.from(response);
        // Envelope {code,message} shape from _handleResult error path.
        final inner = err['data'] is Map ? Map.from(err['data']) : null;
        final src = inner ?? err;
        code = (src['code'] ?? src['reason'] ?? '').toString();
        desc = (src['description'] ?? src['message'] ?? src['reason'] ?? src['field'] ?? '').toString();
        if (desc.isEmpty) desc = (err['message'] ?? '').toString();
      } else {
        desc = response?.toString() ?? '';
      }
      final d = desc.toLowerCase();
      bool has(List<String> keys) => keys.any((k) => d.contains(k));
      if (has(['insufficient', 'insufficent', 'low balance', 'not enough balance', 'no balance', 'limit exceeded', 'exceeds'])) {
        return 'Insufficient balance. Top up or try another method.';
      }
      if (has(['cancelled by user', 'canceled', 'cancelled', 'user cancelled', 'payment processing cancelled'])) {
        return 'Payment cancelled. No money was charged.';
      }
      if (has(['timed out', 'timeout', 'session expired', 'expired'])) {
        return 'Payment timed out. No money was charged. Try again.';
      }
      if (has(['network', 'no internet', 'connection', 'socket', 'tls'])) {
        return 'Network issue. Check connection and retry.';
      }
      if (has(['otp', 'incorrect', 'wrong otp', 'invalid otp'])) {
        return 'Incorrect or expired OTP. Try again.';
      }
      if (has(['vpa', 'upi']) && has(['invalid', 'incorrect', 'wrong', 'failed', 'not found'])) {
        return 'Invalid UPI ID. Check and retry.';
      }
      if (has(['declined', 'decline', 'blocked', 'denied', 'not supported', 'not allowed'])) {
        return 'Card/bank declined. Try another method.';
      }
      if (has(['invalid', 'validation', 'bad_request', 'bad request', 'mandatory', 'required'])) {
        return 'Payment details invalid. Check and retry.';
      }
      if (desc.trim().isNotEmpty && desc.length <= 90) return desc.trim();
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  /// True when a gateway error deserves a local retry nudge (real failure,
  /// not user-cancel/timeout where the user already knows they backed out).
  static bool shouldNotifyGatewayError(dynamic response) {
    try {
      String desc = '';
      if (response is Map) {
        final err = response['error'] is Map ? Map.from(response['error'] as Map) : Map.from(response);
        final inner = err['data'] is Map ? Map.from(err['data']) : null;
        final src = inner ?? err;
        desc = (src['description'] ?? src['message'] ?? src['reason'] ?? '').toString().toLowerCase();
        if (desc.isEmpty) desc = (err['message'] ?? '').toString().toLowerCase();
      } else {
        desc = response?.toString().toLowerCase() ?? '';
      }
      if (desc.contains('cancelled') || desc.contains('canceled') || desc.contains('timed out') || desc.contains('timeout')) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> saveMaskedCard({required String pan, required String name}) async {
    try {
      final digits = pan.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 12) return;
      final last4 = digits.substring(digits.length - 4);
      final network = _cardNetwork(digits);
      final entry = '$last4|$network|${name.trim()}';
      final list = await _sharedPreferencesManager.getStringList(_savedCardsKey) ?? <String>[];
      list.removeWhere((e) => e.startsWith('$last4|'));
      list.insert(0, entry);
      await _sharedPreferencesManager.putStringList(_savedCardsKey, list.take(5).toList());
    } catch (_) {}
  }

  Future<void> removeSavedCard(String last4) async {
    try {
      final list = await _sharedPreferencesManager.getStringList(_savedCardsKey) ?? <String>[];
      list.removeWhere((e) => e.startsWith('$last4|'));
      await _sharedPreferencesManager.putStringList(_savedCardsKey, list);
    } catch (_) {}
  }

  static String _cardNetwork(String digits) {
    if (digits.startsWith('4')) return 'Visa';
    if (RegExp(r'^5[1-5]').hasMatch(digits)) return 'Mastercard';
    if (digits.startsWith('6')) return 'RuPay';
    if (RegExp(r'^3[47]').hasMatch(digits)) return 'Amex';
    return 'Card';
  }

  void clear() {
    LocalNotificationService.paymentScreenOpen = false;
    try {
      _razorpay.clear();
    } catch (_) {}
  }
}
