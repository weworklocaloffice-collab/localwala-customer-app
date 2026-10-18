import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:lottie/lottie.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/cart_repository.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/app/services/local_notification_service.dart';
import 'package:user/app/services/razorpay_service.dart';
import 'package:user/gen/l10n/app_localizations.dart';

enum CustomPayMethod { upi, card, netbanking, wallet, paylater, emi, cod }

/// Reference-style payment flow (layout from mock, ALL data live):
/// Step "methods"  = Select Payment Method (UPI quick tiles + radio rows + Pay amount)
/// Step "upi"      = UPI Payment (6-app grid + VPA + Pay with X)
/// Step "card"/"nb"/"wallet" = inline forms. submit() -> parent listeners
/// verify -> success modal. isSubmitting renders Processing steps.
class CustomPaymentSheetScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final RazorpayService razorpayService;
  final String paymentId;
  final String codPaymentId;
  final VoidCallback? onCodSuccess;
  const CustomPaymentSheetScreen({
    super.key,
    required this.orderData,
    required this.razorpayService,
    this.paymentId = '',
    this.codPaymentId = '',
    this.onCodSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaymentSheetView(
      orderData: orderData,
      razorpayService: razorpayService,
      paymentId: paymentId,
      codPaymentId: codPaymentId,
      onCodSuccess: onCodSuccess,
    );
  }
}

class _UpiApp {
  final String id;
  final String label;
  final String pkg;
  const _UpiApp(this.id, this.label, this.pkg);
}

const List<_UpiApp> _kUpiApps = [
  _UpiApp('phonepe', 'PhonePe', 'com.phonepe.app'),
  _UpiApp('gpay', 'Google Pay', 'com.google.android.apps.nbu.paisa.user'),
  _UpiApp('paytm', 'Paytm', 'net.one97.paytm'),
  _UpiApp('bhim', 'BHIM', 'in.org.npci.upiapp'),
  _UpiApp('amazon', 'Amazon Pay', 'in.amazon.mShop.android.shopping'),
  _UpiApp('whatsapp', 'WhatsApp Pay', 'com.whatsapp'),
];

class _CustomPaymentSheetViewState extends State<CustomPaymentSheetView> {
  String _step = 'methods';
  CustomPayMethod selected = CustomPayMethod.upi;
  String selectedUpiApp = 'phonepe';
  bool isSubmitting = false;
  int processingStep = 0;
  Timer? _procTimer;
  Timer? _watchdogTimer;
  Map? methods;
  List<String> banks = [];
  List<String> wallets = [];
  List<dynamic> upiApps = [];
  Set<String> installedUpi = {};
  // Enterprise: most-used ordering + saved cards + PayLater/EMI picks.
  Map<String, int> _usage = {};
  List<Map<String, String>> _savedCards = [];
  List<String> _savedVpas = [];
  String? _mostUsedMethod;
  String? selectedEmiBank;
  String selectedEmiPlan = '6 months';
  String? selectedPaylater;
  bool _saveCard = false;
  bool _obscureCvv = true;

  // Card formatters: 4-4-4-4 spacing + MM/YY slash. PCI: display only.
  static final TextInputFormatter _cardNumberFormatter = TextInputFormatter.withFunction((oldV, newV) {
    final digits = newV.text.replaceAll(RegExp(r'\D'), '');
    final truncated = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buf = StringBuffer();
    for (int i = 0; i < truncated.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(truncated[i]);
    }
    return TextEditingValue(text: buf.toString(), selection: TextSelection.collapsed(offset: buf.length));
  });

  static final TextInputFormatter _expiryFormatter = TextInputFormatter.withFunction((oldV, newV) {
    var digits = newV.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    if (digits.length >= 3) {
      return TextEditingValue(
          text: '${digits.substring(0, 2)}/${digits.substring(2)}',
          selection: TextSelection.collapsed(offset: digits.length + 1));
    }
    return newV;
  });

  String get _cardNetworkLive {
    final digits = cardNumberCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('4')) return 'Visa';
    if (RegExp(r'^5[1-5]').hasMatch(digits)) return 'Mastercard';
    if (digits.startsWith('6')) return 'RuPay';
    if (RegExp(r'^3[47]').hasMatch(digits)) return 'Amex';
    return '';
  }

  final TextEditingController vpaCtrl = TextEditingController();
  final TextEditingController cardNumberCtrl = TextEditingController();
  final TextEditingController cardNameCtrl = TextEditingController();
  final TextEditingController expiryCtrl = TextEditingController();
  final TextEditingController cvvCtrl = TextEditingController();
  final TextEditingController contactCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  String? selectedBank;
  String? selectedWallet;
  bool _needsIdentity = false;

  String get _amountStr {
    final amount = widget.orderData['amount'];
    if (amount is int) return (amount / 100).toStringAsFixed(2);
    return '$amount';
  }

  // ---------- #2 amount rules (enterprise) ----------
  // EMI needs ticket size; PayLater has credit cap; COD has collection cap.
  // Tune thresholds here (single source) — backend still re-validates.
  static const double _emiMinRupees = 3000;
  static const double _paylaterMaxRupees = 100000;
  static const double _codMaxRupees = 50000;

  double get _amountRupees {
    final a = widget.orderData['amount'];
    if (a is int) return a / 100.0;
    if (a is double) return a;
    return double.tryParse('$a') ?? 0;
  }

  bool get _emiAvailable => _amountRupees >= _emiMinRupees;
  String get _emiReason => _emiAvailable ? '' : 'Available on ₹${_emiMinRupees.toStringAsFixed(0)} and above';
  bool get _paylaterAvailable => _amountRupees > 0 && _amountRupees <= _paylaterMaxRupees;
  String get _paylaterReason => _paylaterAvailable ? '' : 'Available up to ₹${_paylaterMaxRupees.toStringAsFixed(0)}';
  bool get _codAllowed => widget.codPaymentId.isNotEmpty && _amountRupees <= _codMaxRupees;
  String get _codReason => widget.codPaymentId.isEmpty ? '' : 'Available up to ₹${_codMaxRupees.toStringAsFixed(0)}';

  String _upiLabel(String id) {
    for (final a in _kUpiApps) {
      if (a.id == id) return a.label;
    }
    return 'UPI';
  }

  @override
  void initState() {
    super.initState();
    contactCtrl.text = (widget.orderData['contact'] ?? '').toString();
    emailCtrl.text = (widget.orderData['email'] ?? '').toString();
    _needsIdentity = !_identityValid();
    _loadMethods();
    _resolveIdentitySilently();
  }

  bool _identityValid() {
    final digits = contactCtrl.text.replaceAll(RegExp(r'\D'), '');
    final email = emailCtrl.text.trim();
    return digits.length == 10 && email.contains('@') && email.contains('.');
  }

  Future<void> _resolveIdentitySilently() async {
    if (_identityValid()) return;
    try {
      final authRepo = AuthRepository();
      final pEmail = (await authRepo.userEmail()).trim();
      final pMobile = (await authRepo.userMobile()).trim();
      if (contactCtrl.text.replaceAll(RegExp(r'\D'), '').length != 10 && pMobile.replaceAll(RegExp(r'\D'), '').length >= 10) {
        contactCtrl.text = pMobile;
      }
      if ((!emailCtrl.text.contains('@')) && pEmail.contains('@')) {
        emailCtrl.text = pEmail;
      }
      if (mounted) setState(() => _needsIdentity = !_identityValid());
    } catch (_) {}
  }

  bool _validateContactEmail() {
    if (_identityValid()) return true;
    setState(() => _needsIdentity = true);
    final t = AppLocalizations.of(context)!;
    final digits = contactCtrl.text.replaceAll(RegExp(r'\D'), '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(digits.length != 10 ? t.pay_enter_mobile : t.pay_enter_email)),
    );
    return false;
  }

  Future<void> _loadMethods() async {
    final m = await widget.razorpayService.getPaymentMethods();
    if (m is Map && mounted) {
      final nb = m['netbanking'];
      final wl = m['wallet'];
      List<String> nbBanks = [];
      List<String> wlWallets = [];
      if (nb is Map) nbBanks = nb.keys.map((e) => e.toString()).toList();
      if (wl is Map) {
        wlWallets = wl.entries.where((e) => e.value == true).map((e) => e.key.toString()).toList();
      }
      // Order banks/wallets by local most-used (enterprise) before display.
      final usage = <String, int>{};
      for (final b in nbBanks) {
        usage['nb_$b'] = await widget.razorpayService.getUsage('nb_$b');
      }
      for (final w in wlWallets) {
        usage['wallet_$w'] = await widget.razorpayService.getUsage('wallet_$w');
      }
      for (final id in ['phonepe', 'gpay', 'paytm', 'bhim', 'amazon', 'whatsapp']) {
        usage['upi_$id'] = await widget.razorpayService.getUsage('upi_$id');
      }
      for (final k in ['upi', 'card', 'netbanking', 'wallet', 'paylater', 'emi', 'cod']) {
        usage['method_$k'] = await widget.razorpayService.getUsage('method_$k');
      }
      nbBanks.sort((a, b) => (usage['nb_$b'] ?? 0).compareTo(usage['nb_$a'] ?? 0));
      wlWallets.sort((a, b) => (usage['wallet_$b'] ?? 0).compareTo(usage['wallet_$a'] ?? 0));
      // Most-used top-level method drives default selection + badge.
      String top = 'upi';
      int topN = -1;
      usage.forEach((k, v) {
        if (k.startsWith('method_') && v > topN) {
          topN = v;
          top = k.replaceFirst('method_', '');
        }
      });
      final saved = await widget.razorpayService.getSavedCards();
      final vpas = await widget.razorpayService.getSavedVpas();
      if (!mounted) return;
      setState(() {
        methods = m;
        banks = nbBanks;
        wallets = wlWallets;
        _usage = usage;
        _savedCards = saved;
        _savedVpas = vpas;
        if (banks.isNotEmpty) {
          selectedBank = banks.first;
          selectedEmiBank = banks.first;
        }
        if (wallets.isNotEmpty) selectedWallet = wallets.first;
        // Recommended instruments (best-effort): prefer Razorpay's signal
        // when it names a usable method, else keep local most-used.
        _mostUsedMethod = topN > 0 ? top : null;
        if (_mostUsedMethod != null) {
          selected = _methodFromId(_mostUsedMethod!);
          if (selected == CustomPayMethod.upi) {
            selectedUpiApp = _topUpiApp();
          }
        }
      });
      // Fire-and-forget: refresh with Razorpay recommended instruments.
      try {
        final rec = await widget.razorpayService.getRecommendedInstruments({'amount': widget.orderData['amount']});
        if (rec != null && mounted) setState(() {});
      } catch (_) {}
    }
    final apps = await widget.razorpayService.getUpiApps();
    if (mounted && apps is List) {
      setState(() {
        upiApps = apps;
        installedUpi = apps.map((a) {
          if (a is String) return a.toLowerCase();
          if (a is Map) {
            final p = a['packageName'] ?? a['package_name'] ?? a['package'] ?? a['appName'] ?? a['name'] ?? '';
            return p.toString().toLowerCase();
          }
          return a.toString().toLowerCase();
        }).where((s) => s.isNotEmpty).toSet();
      });
    }
  }

  CustomPayMethod _methodFromId(String id) {
    switch (id) {
      case 'card':
        return CustomPayMethod.card;
      case 'netbanking':
        return CustomPayMethod.netbanking;
      case 'wallet':
        return CustomPayMethod.wallet;
      case 'paylater':
        return CustomPayMethod.paylater;
      case 'emi':
        return CustomPayMethod.emi;
      case 'cod':
        return CustomPayMethod.cod;
      default:
        return CustomPayMethod.upi;
    }
  }

  String _topUpiApp() {
    String best = selectedUpiApp;
    int bestN = -1;
    for (final a in _kUpiApps) {
      final n = _usage['upi_${a.id}'] ?? 0;
      if (n > bestN && _upiInstalled(a.pkg)) {
        bestN = n;
        best = a.id;
      }
    }
    return best;
  }

  /// UPI apps ordered for display: installed first, then most-used.
  List<_UpiApp> _orderedUpiApps() {
    final list = List<_UpiApp>.from(_kUpiApps);
    list.sort((a, b) {
      final ai = _upiInstalled(a.pkg) ? 0 : 1;
      final bi = _upiInstalled(b.pkg) ? 0 : 1;
      if (ai != bi) return ai.compareTo(bi);
      return ((_usage['upi_${b.id}'] ?? 0)).compareTo(_usage['upi_${a.id}'] ?? 0);
    });
    return list;
  }

  bool _upiInstalled(String pkg) {
    if (installedUpi.isEmpty) return true;
    final p = pkg.toLowerCase();
    if (installedUpi.contains(p)) return true;
    if (p.contains('paytm')) return installedUpi.any((s) => s.contains('paytm') || s.contains('one97'));
    if (p.contains('phonepe')) return installedUpi.any((s) => s.contains('phonepe'));
    if (p.contains('nbu.paisa') || p.contains('google')) {
      return installedUpi.any((s) => s.contains('google') || s.contains('gpay') || s.contains('paisa') || s.contains('tez'));
    }
    if (p.contains('npci')) return installedUpi.any((s) => s.contains('bhim') || s.contains('npci'));
    if (p.contains('amazon')) return installedUpi.any((s) => s.contains('amazon'));
    if (p.contains('whatsapp')) return installedUpi.any((s) => s.contains('whatsapp'));
    return false;
  }

  String _pkgOf(String id) {
    for (final a in _kUpiApps) {
      if (a.id == id) return a.pkg;
    }
    return '';
  }

  Future<void> _submit(Map<String, dynamic> options, String label, {String? usageKey}) async {
    // Enterprise: record most-used before submit (fire-and-forget).
    if (usageKey != null && usageKey.isNotEmpty) {
      try {
        await widget.razorpayService.recordUsage(usageKey);
        final method = usageKey.startsWith('upi_')
            ? 'upi'
            : usageKey.startsWith('nb_')
                ? 'netbanking'
                : usageKey.startsWith('wallet_')
                    ? 'wallet'
                    : usageKey.startsWith('paylater')
                        ? 'paylater'
                        : usageKey.startsWith('emi')
                            ? 'emi'
                            : usageKey.startsWith('card')
                                ? 'card'
                                : usageKey.startsWith('cod')
                                    ? 'cod'
                                    : null;
        if (method != null) await widget.razorpayService.recordUsage('method_$method');
      } catch (_) {}
    }
    setState(() {
      isSubmitting = true;
      processingStep = 0;
    });
    // Animate: request created -> app opened. "Waiting" holds until parent
    // verify fires success/error (modal covers this screen).
    // Watchdog: gateway must callback within 3 min (UPI app-switch return,
    // OTP/3DS). Otherwise reset so screen never sticks on processing.
    _procTimer?.cancel();
    _watchdogTimer?.cancel();
    _procTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted && isSubmitting) setState(() => processingStep = 1);
    });
    _watchdogTimer = Timer(const Duration(minutes: 3), () {
      if (mounted && isSubmitting) {
        setState(() {
          isSubmitting = false;
          processingStep = 0;
        });
        LocalNotificationService.cancelPaymentProgress();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment timed out. No money was charged. Try again.')));
      }
    });
    _logPayEvent('pay_submit', {'label': label, 'usageKey': usageKey ?? '', 'amount': widget.orderData['amount']?.toString() ?? ''});
    // Tray progress (Lottie can't render in RemoteViews): ongoing bar while
    // the gateway owns the payment. Cancelled on verify outcome / dispose.
    LocalNotificationService.showPaymentProgress('Confirm in $label — do not close the app.');
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
    try {
      widget.razorpayService.submitWithLabel(options, label);
    } catch (e) {
      _procTimer?.cancel();
      _watchdogTimer?.cancel();
      LocalNotificationService.cancelPaymentProgress();
      if (mounted) {
        setState(() {
          isSubmitting = false;
          processingStep = 0;
        });
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.pay_submit_failed(e.toString()))));
      }
    }
  }

  void _payUpiCollect() {
    if (!_validateContactEmail()) return;
    final vpa = vpaCtrl.text.trim();
    if (vpa.isEmpty || !vpa.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.pay_enter_vpa)));
      return;
    }
    widget.razorpayService
        .buildUpiCollectOptions(orderData: widget.orderData, vpa: vpa, contact: contactCtrl.text, email: emailCtrl.text)
        .then((o) => _submit(o, 'UPI', usageKey: 'upi_collect'));
    widget.razorpayService.saveVpa(vpa);
  }

  void _payUpiIntent([String? pkg, String? label]) {
    if (!_validateContactEmail()) return;
    final id = label ?? selectedUpiApp;
    final package = pkg ?? _pkgOf(selectedUpiApp);
    if (package.isNotEmpty && !_upiInstalled(package)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pay_app_missing)),
      );
      return;
    }
    widget.razorpayService
        .buildUpiIntentOptions(orderData: widget.orderData, upiAppPackage: package, contact: contactCtrl.text, email: emailCtrl.text)
        .then((o) => _submit(o, 'UPI (${_upiLabel(id)})', usageKey: 'upi_$selectedUpiApp'));
  }

  void _payCard() {
    if (!_validateContactEmail()) return;
    final t = AppLocalizations.of(context)!;
    final num = cardNumberCtrl.text.replaceAll(' ', '');
    final exp = expiryCtrl.text.split('/');
    if (num.length < 12 || exp.length != 2 || cvvCtrl.text.length < 3 || cardNameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.pay_enter_card)));
      return;
    }
    // Enterprise: persist masked card only (last4/network/name). PAN/CVV
    // stay in memory for this submit and are never written to disk.
    if (_saveCard) {
      widget.razorpayService.saveMaskedCard(pan: num, name: cardNameCtrl.text.trim());
    }
    widget.razorpayService
        .buildCardOptions(
          orderData: widget.orderData,
          cardNumber: num,
          cardName: cardNameCtrl.text.trim(),
          expiryMonth: exp.first.trim(),
          expiryYear: exp.last.trim(),
          cvv: cvvCtrl.text.trim(),
          contact: contactCtrl.text,
          email: emailCtrl.text,
        )
        .then((o) => _submit(o, t.pay_card_title, usageKey: 'card'));
  }

  void _payNb() {
    if (!_validateContactEmail()) return;
    if (selectedBank == null) return;
    final t = AppLocalizations.of(context)!;
    widget.razorpayService
        .buildNetbankingOptions(orderData: widget.orderData, bank: selectedBank!, contact: contactCtrl.text, email: emailCtrl.text)
        .then((o) => _submit(o, t.pay_nb_title, usageKey: 'nb_$selectedBank'));
  }

  void _payWallet() {
    if (!_validateContactEmail()) return;
    if (selectedWallet == null) return;
    final t = AppLocalizations.of(context)!;
    widget.razorpayService
        .buildWalletOptions(orderData: widget.orderData, wallet: selectedWallet!, contact: contactCtrl.text, email: emailCtrl.text)
        .then((o) => _submit(o, t.pay_wallets_title, usageKey: 'wallet_$selectedWallet'));
  }

  void _payPaylater() {
    if (!_validateContactEmail()) return;
    if (!_paylaterAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_paylaterReason)));
      return;
    }
    final provider = (selectedPaylater ?? '').trim();
    if (provider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.pay_paylater_note)));
      return;
    }
    widget.razorpayService
        .buildPaylaterOptions(orderData: widget.orderData, provider: provider, contact: contactCtrl.text, email: emailCtrl.text)
        .then((o) => _submit(o, 'PayLater ($provider)', usageKey: 'paylater_$provider'));
  }

  void _payEmi() {
    if (!_validateContactEmail()) return;
    if (!_emiAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_emiReason)));
      return;
    }
    if (selectedEmiBank == null || selectedEmiBank!.isEmpty) return;
    widget.razorpayService
        .buildEmiOptions(orderData: widget.orderData, bank: selectedEmiBank!, emiPlan: selectedEmiPlan, contact: contactCtrl.text, email: emailCtrl.text)
        .then((o) => _submit(o, 'EMI ($selectedEmiBank)', usageKey: 'emi_$selectedEmiBank'));
  }

  /// COD from the payment screen: converts the Razorpay initiation to offline.
  /// No gateway submit — backend marks order created + notifies restaurant.
  Future<void> _payCod() async {
    if (widget.codPaymentId.isEmpty || widget.paymentId.isEmpty) return;
    if (!_codAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_codReason)));
      return;
    }
    final t = AppLocalizations.of(context)!;
    setState(() => isSubmitting = true);
    try {
      final res = await CartRepository().switchToCod(widget.paymentId);
      if (res.success) {
        widget.razorpayService.lastMethodLabel = t.pay_cod_title;
        widget.onCodSuccess?.call();
        return;
      }
      if (mounted) {
        setState(() => isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.pay_failed_snack)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.pay_failed_snack)));
      }
    }
  }

  @override
  void dispose() {
    _procTimer?.cancel();
    _watchdogTimer?.cancel();
    LocalNotificationService.cancelPaymentProgress();
    vpaCtrl.dispose();
    cardNumberCtrl.dispose();
    cardNameCtrl.dispose();
    expiryCtrl.dispose();
    cvvCtrl.dispose();
    contactCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (isSubmitting) {
      body = _processingView();
    } else {
      switch (_step) {
        case 'upi':
          body = _upiDetailView();
          break;
        case 'card':
          body = _cardView();
          break;
        case 'nb':
          body = _nbView();
          break;
        case 'wallet':
          body = _walletView();
          break;
        case 'paylater':
          body = _paylaterView();
          break;
        case 'emi':
          body = _emiView();
          break;
        default:
          body = _methodsView();
          break;
      }
    }
    // Back-guard: system back / AppBar back during gateway processing would
    // orphan the payment (listeners die, verify never runs). Block + explain.
    return PopScope(
      canPop: !isSubmitting,
      onPopInvoked: (bool didPop) {
        if (!didPop && isSubmitting && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.pay_back_blocked)),
          );
        }
      },
      child: body,
    );
  }

  // ---------- shared bits ----------

  Widget _secureHeader() {
    final t = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user_outlined, size: 16, color: Colors.green[700]),
        const SizedBox(width: 6),
        Text(t.pay_secure_by, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const Text('Razorpay', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
      ],
    );
  }

  Widget _payButton(String label, VoidCallback? onTap) {
    final primary = Theme.of(context).primaryColor;
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(width: 8), const Icon(Icons.arrow_forward_ios, size: 16)],
        ),
        ),
      ),
    );
  }

  BoxDecoration _cardDeco({bool selected = false}) {
    final primary = Theme.of(context).primaryColor;
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: selected ? primary : Colors.grey.shade300, width: selected ? 1.5 : 1),
    );
  }

  Widget _radioDot(bool sel) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: sel ? primary : Colors.grey.shade400, width: 2),
        color: sel ? primary : Colors.transparent,
      ),
      child: sel ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
    );
  }

  /// UPI avatar: fetch favicon first (no assets), letter fallback.
  Widget _brandAvatar(String id, {double size = 48}) {
    final domain = _domainForUpi(id);
    if (domain.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(_faviconUrl(domain),
            width: size, height: size, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _brandLetters(id, size: size)),
      );
    }
    return _brandLetters(id, size: size);
  }

  /// Letter stand-in (offline-safe) when fetch fails.
  Widget _brandLetters(String id, {double size = 48}) {
    Widget inner;
    Color bg;
    switch (id) {
      case 'phonepe':
        bg = const Color(0xFF5F259F);
        inner = const Text('पे', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold));
        break;
      case 'gpay':
        bg = Colors.white;
        inner = const Text('G', style: TextStyle(color: Color(0xFF4285F4), fontSize: 26, fontWeight: FontWeight.bold));
        break;
      case 'paytm':
        bg = const Color(0xFFE8F4FD);
        inner = const Text('paytm', style: TextStyle(color: Color(0xFF002E6E), fontSize: 13, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic));
        break;
      case 'bhim':
        bg = const Color(0xFFF5F5F5);
        inner = const Text('BHIM', style: TextStyle(color: Color(0xFF097939), fontSize: 11, fontWeight: FontWeight.bold));
        break;
      case 'amazon':
        bg = const Color(0xFF232F3E);
        inner = const Text('pay', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold));
        break;
      case 'whatsapp':
        bg = const Color(0xFF25D366);
        inner = const Icon(Icons.chat_bubble, color: Colors.white, size: 24);
        break;
      default:
        bg = Colors.grey.shade200;
        inner = const Text('•••', style: TextStyle(fontSize: 18, color: Colors.grey));
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Center(child: inner),
    );
  }

  Widget _methodIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: Colors.black87, size: 24),
    );
  }

  // ---------- #1 order summary + trust (enterprise) ----------
  // Total always; breakdown rows render when backend includes them
  // (itemsTotal/subtotal/delivery/tax/discount). Amounts may be paise ints.
  String _moneyStr(dynamic v) {
    if (v == null) return '';
    if (v is int) return (v / 100).toStringAsFixed(2);
    if (v is double) return v.toStringAsFixed(2);
    final n = double.tryParse('$v');
    if (n == null) return '$v';
    return n.toStringAsFixed(2);
  }

  List<Map<String, String>> _breakdownRows() {
    final rows = <Map<String, String>>[];
    final data = widget.orderData;
    const candidates = <String, String>{
      'itemsTotal': 'Items',
      'subtotal': 'Subtotal',
      'deliveryFee': 'Delivery',
      'delivery': 'Delivery',
      'tax': 'Tax',
      'discount': 'Discount',
      'walletApplied': 'Wallet',
    };
    candidates.forEach((key, label) {
      if (data.containsKey(key) && data[key] != null && '${data[key]}' != '' && '${data[key]}' != '0') {
        rows.add({'k': label, 'v': '₹${_moneyStr(data[key])}'});
      }
    });
    return rows;
  }

  Widget _orderSummaryCard() {
    final t = AppLocalizations.of(context)!;
    final rows = _breakdownRows();
    final shortId = widget.paymentId.length > 8 ? widget.paymentId.substring(widget.paymentId.length - 8) : widget.paymentId;
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.pay_total_payable, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text('₹$_amountStr', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
          if (rows.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r['k']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(r['v']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 6),
          Text('Order ${shortId.isNotEmpty ? '#$shortId' : ''} • Secured by Razorpay',
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _trustRow() {
    Widget chip(IconData icon, String label) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF15803D)),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(Icons.verified_user_outlined, '100% Secure'),
        const SizedBox(width: 8),
        chip(Icons.shield_outlined, 'RBI Compliant'),
        const SizedBox(width: 8),
        chip(Icons.refresh_outlined, 'Instant Refunds'),
      ],
    );
  }

  // ---------- step: methods list (ref #3) ----------

  Widget _methodsView() {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _secureHeader(),
            kAppSpacerVertical(height: 12),
            _orderSummaryCard(),
            kAppSpacerVertical(height: 12),
            _trustRow(),
            kAppSpacerVertical(height: 12),
            // UPI card
            GestureDetector(
              onTap: () => setState(() => selected = CustomPayMethod.upi),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: _cardDeco(selected: selected == CustomPayMethod.upi),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _methodIcon(Icons.flash_on_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.pay_upi_recommended, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                              Text(t.pay_with_any_upi, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        _radioDot(selected == CustomPayMethod.upi),
                      ],
                    ),
                    kAppSpacerVertical(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (final a in _orderedUpiApps().take(3)) _quickUpi(a.id),
                        _quickUpi('other', label: t.pay_other_upi),
                      ],
                    ),
                    if (upiApps.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          t.pay_upi_apps_found(upiApps.length),
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ),
                    kAppSpacerVertical(height: 8),
                    InkWell(
                      onTap: () => setState(() {
                        selected = CustomPayMethod.upi;
                        _step = 'upi';
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            _methodIcon(Icons.alternate_email),
                            const SizedBox(width: 12),
                            Expanded(child: Text(t.pay_using_upi_id, style: const TextStyle(fontWeight: FontWeight.w500))),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            kAppSpacerVertical(height: 12),
            if (_savedCards.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: _cardDeco(selected: false),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.pay_saved_cards, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const Text('CVV required every time — full number never stored',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    kAppSpacerVertical(height: 8),
                    for (final c in _savedCards)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: _cardNetworkBadge(c['network'] ?? 'Card'),
                        title: Text('${c['network']} •••• ${c['last4']}',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(c['name'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                cardNumberCtrl.text = '';
                                cardNameCtrl.text = c['name'] ?? '';
                                setState(() {
                                  selected = CustomPayMethod.card;
                                  _step = 'card';
                                });
                              },
                              child: Text(t.pay_use),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () async {
                                await widget.razorpayService.removeSavedCard(c['last4'] ?? '');
                                final saved = await widget.razorpayService.getSavedCards();
                                if (mounted) setState(() => _savedCards = saved);
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              kAppSpacerVertical(height: 12),
            ],
            _radioRow(
              icon: Icons.credit_card_outlined,
              title: t.pay_card_title,
              sub: t.pay_card_sub,
              sel: selected == CustomPayMethod.card,
              badge: _badgeFor('card'),
              onTap: () => setState(() {
                selected = CustomPayMethod.card;
                _step = 'card';
              }),
            ),
            kAppSpacerVertical(height: 12),
            _radioRow(
              icon: Icons.account_balance_outlined,
              title: t.pay_nb_title,
              sub: banks.isEmpty ? t.pay_loading_banks : '${t.pay_nb_sub} • ${banks.length} banks',
              sel: selected == CustomPayMethod.netbanking,
              badge: _badgeFor('netbanking'),
              onTap: () => setState(() {
                selected = CustomPayMethod.netbanking;
                _step = 'nb';
              }),
            ),
            kAppSpacerVertical(height: 12),
            _radioRow(
              icon: Icons.account_balance_wallet_outlined,
              title: t.pay_wallets_title,
              sub: wallets.isEmpty ? t.pay_loading_wallets : '${t.pay_wallets_sub} • ${wallets.length} available',
              sel: selected == CustomPayMethod.wallet,
              badge: _badgeFor('wallet'),
              onTap: () => setState(() {
                selected = CustomPayMethod.wallet;
                _step = 'wallet';
              }),
            ),
            kAppSpacerVertical(height: 12),
            Opacity(
              opacity: _paylaterAvailable ? 1.0 : 0.55,
              child: _radioRow(
              icon: Icons.schedule_outlined,
              title: t.pay_paylater,
                sub: _paylaterAvailable ? 'Simpl, LazyPay — pay next month' : _paylaterReason,
                sel: selected == CustomPayMethod.paylater,
                badge: _badgeFor('paylater'),
                onTap: () {
                  if (!_paylaterAvailable) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_paylaterReason)));
                    return;
                  }
                  setState(() {
                    selected = CustomPayMethod.paylater;
                    _step = 'paylater';
                  });
                },
              ),
            ),
            kAppSpacerVertical(height: 12),
            Opacity(
              opacity: _emiAvailable ? 1.0 : 0.55,
              child: _radioRow(
              icon: Icons.calendar_month_outlined,
              title: t.pay_emi,
                sub: _emiAvailable ? 'Credit-card EMI 3/6/9/12 months' : _emiReason,
                sel: selected == CustomPayMethod.emi,
                badge: _badgeFor('emi'),
                onTap: () {
                  if (!_emiAvailable) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_emiReason)));
                    return;
                  }
                  setState(() {
                    selected = CustomPayMethod.emi;
                    _step = 'emi';
                  });
                },
              ),
            ),
            if (widget.codPaymentId.isNotEmpty) ...[
              kAppSpacerVertical(height: 12),
              Opacity(
                opacity: _codAllowed ? 1.0 : 0.55,
                child: _radioRow(
                  icon: Icons.money_outlined,
                  title: t.pay_cod_title,
                  sub: _codAllowed ? t.pay_cod_sub : _codReason,
                  sel: selected == CustomPayMethod.cod,
                  onTap: () {
                    if (!_codAllowed) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_codReason)));
                      return;
                    }
                    setState(() => selected = CustomPayMethod.cod);
                  },
                ),
              ),
            ],
            if (_needsIdentity) ...[
              kAppSpacerVertical(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: contactCtrl, keyboardType: TextInputType.phone, maxLength: 10, decoration: InputDecoration(labelText: '${t.pay_mobile} *', hintText: t.pay_mobile_hint, counterText: ''))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: '${t.pay_email} *', hintText: t.pay_email_hint))),
                ],
              ),
            ],
            kAppSpacerVertical(height: 16),
            _payButton('${t.pay_prefix} ₹$_amountStr', _onMethodsPay),
            Center(
              child: TextButton(
                onPressed: () {
                  // Support chat types: orders/dining/tiffin_subscription/...
                  // 'payment' is rejected (validation). Use local order id.
                  final localId = (widget.orderData['localOrderId'] ?? '').toString();
                  if (localId.isNotEmpty) {
                    Navigator.of(context).pushNamed(AppRouter.supportChatRoute, arguments: ['orders', localId]);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Quote payment ${widget.paymentId} to support')));
                  }
                },
                child: Text('Need help? Payment ${widget.paymentId.length > 8 ? '#${widget.paymentId.substring(widget.paymentId.length - 8)}' : ''}',
                    style: const TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickUpi(String id, {String? label}) {
    final name = label ?? _upiLabel(id);
    final bool installed = id == 'other' ? true : _upiInstalled(_pkgOf(id));
    final bool mostUsed = id != 'other' && _mostUsedMethod == 'upi' && selectedUpiApp == id;
    return InkWell(
      onTap: () {
        if (id == 'other') {
          setState(() {
            selected = CustomPayMethod.upi;
            _step = 'upi';
          });
          return;
        }
        setState(() {
          selected = CustomPayMethod.upi;
          selectedUpiApp = id;
          _step = 'upi';
        });
      },
      child: Column(
        children: [
          Stack(
            children: [
              id == 'other'
                  ? Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                      child: const Center(child: Text('•••', style: TextStyle(fontSize: 18, color: Colors.grey))),
                    )
                  : Opacity(opacity: installed ? 1.0 : 0.45, child: _brandAvatar(id)),
              if (!installed && id != 'other')
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(8)),
                    child: const Text('GET', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              if (mostUsed)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(color: Color(0xFF1D4ED8), shape: BoxShape.circle),
                    child: const Icon(Icons.star, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(width: 64, child: Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11))),
        ],
      ),
    );
  }

  Widget _radioRow({required IconData icon, required String title, required String sub, required bool sel, required VoidCallback onTap, String? badge}) {
    return Semantics(
      button: true,
      selected: sel,
      label: '$title. $sub',
      child: InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDeco(selected: sel),
        child: Row(
          children: [
            _methodIcon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
                      if (badge != null && badge.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFBFDBFE))),
                          child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8))),
                        ),
                      ],
                    ],
                  ),
                  Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            _radioDot(sel),
          ],
        ),
      ),
      ),
    );
  }

  String? _badgeFor(String methodId) {
    if (_mostUsedMethod == methodId && (_usage['method_$methodId'] ?? 0) > 0) return 'MOST USED';
    return null;
  }

  void _onMethodsPay() {
    if (!_validateContactEmail()) return;
    _logPayEvent('pay_method_select', {'method': selected.name});
    switch (selected) {
      case CustomPayMethod.upi:
        setState(() => _step = 'upi');
        break;
      case CustomPayMethod.card:
        setState(() => _step = 'card');
        break;
      case CustomPayMethod.netbanking:
        setState(() => _step = 'nb');
        break;
      case CustomPayMethod.wallet:
        setState(() => _step = 'wallet');
        break;
      case CustomPayMethod.cod:
        _payCod();
        break;
      case CustomPayMethod.paylater:
        setState(() => _step = 'paylater');
        break;
      case CustomPayMethod.emi:
        setState(() => _step = 'emi');
        break;
    }
  }

  // ---------- step: UPI detail (ref #4) ----------

  Widget _upiDetailView() {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(onPressed: () => setState(() => _step = 'methods'), icon: const Icon(Icons.arrow_back)),
                Text(t.upi_payment_title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
            Text(t.upi_pay_using, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(t.upi_select_app, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            kAppSpacerVertical(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: _orderedUpiApps().map((a) {
                final sel = selectedUpiApp == a.id;
                final primary = Theme.of(context).primaryColor;
                final installed = _upiInstalled(a.pkg);
                return InkWell(
                  onTap: () => setState(() => selectedUpiApp = a.id),
                  child: Opacity(
                    opacity: installed ? 1.0 : 0.5,
                    child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? primary : Colors.grey.shade300, width: sel ? 1.5 : 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            _brandAvatar(a.id, size: 52),
                            if (sel)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(color: primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(a.label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                        if (!installed)
                          Text(t.pay_not_installed, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        if ((_usage['upi_${a.id}'] ?? 0) > 0)
                          Text('Used ${_usage['upi_${a.id}']}×', style: const TextStyle(fontSize: 10, color: Color(0xFF1D4ED8))),
                      ],
                    ),
                  ),
                  ),
                );
              }).toList(),
            ),
            kAppSpacerVertical(height: 12),
            Text(t.pay_upi_switch_hint, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            if (upiApps.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(t.pay_upi_on_device(upiApps.length), style: Theme.of(context).textTheme.bodySmall),
              ),
            kAppSpacerVertical(height: 8),
            Row(
              children: [const Expanded(child: Divider()), Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(t.upi_or_id, style: const TextStyle(color: Colors.grey, fontSize: 12))), const Expanded(child: Divider())],
            ),
            kAppSpacerVertical(height: 8),
            TextField(controller: vpaCtrl, decoration: InputDecoration(prefixText: '@ ', hintText: t.upi_id_hint, labelText: t.upi_id_label)),
            Padding(padding: const EdgeInsets.only(top: 4), child: Text(t.upi_id_example, style: const TextStyle(color: Colors.grey, fontSize: 11))),
            if (_savedVpas.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final v in _savedVpas)
                    ActionChip(
                      avatar: const Icon(Icons.history, size: 16),
                      label: Text(v, style: const TextStyle(fontSize: 12)),
                      onPressed: () => setState(() => vpaCtrl.text = v),
                    ),
                ],
              ),
            ],
            if (_needsIdentity) ...[
              kAppSpacerVertical(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(controller: contactCtrl, keyboardType: TextInputType.phone, maxLength: 10, decoration: InputDecoration(labelText: '${t.pay_mobile} *', counterText: ''))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: '${t.pay_email} *'))),
                ],
              ),
            ],
            kAppSpacerVertical(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(t.amount_to_pay, style: const TextStyle(color: Colors.grey)), Text('₹$_amountStr', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
            ),
            kAppSpacerVertical(height: 12),
            _payButton('${t.pay_with} ${_upiLabel(selectedUpiApp)}', () {
              // VPA typed -> collect (in-app). Else intent to chosen app.
              if (vpaCtrl.text.trim().contains('@')) {
                _payUpiCollect();
              } else {
                _payUpiIntent();
              }
            }),
          ],
        ),
      ),
    );
  }

  // ---------- step: card / nb / wallet ----------

  Widget _subHeader(String title) {
    return Row(
      children: [
        IconButton(onPressed: () => setState(() => _step = 'methods'), icon: const Icon(Icons.arrow_back)),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _cardView() {
    final t = AppLocalizations.of(context)!;
    final net = _cardNetworkLive;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _subHeader(t.pay_card_title),
            Text(t.pay_card_sub, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            kAppSpacerVertical(height: 12),
            // Live card preview (spacing + network, masked display only).
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.credit_card, color: Colors.white70),
                      if (net.isNotEmpty) _cardNetworkBadge(net),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    cardNumberCtrl.text.isEmpty ? '•••• •••• •••• ••••' : cardNumberCtrl.text,
                    style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(cardNameCtrl.text.isEmpty ? t.pay_card_name : cardNameCtrl.text, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Text(expiryCtrl.text.isEmpty ? 'MM/YY' : expiryCtrl.text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            kAppSpacerVertical(height: 12),
            if (_savedCards.isNotEmpty) ...[
              Text(t.pay_saved_cards, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _savedCards.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final c = _savedCards[i];
                    return ActionChip(
                      avatar: _cardNetworkBadge(c['network'] ?? 'Card'),
                      label: Text('•••• ${c['last4']}'),
                      onPressed: () {
                        cardNameCtrl.text = c['name'] ?? '';
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter full card number + CVV to pay')));
                      },
                    );
                  },
                ),
              ),
              kAppSpacerVertical(height: 12),
            ],
            TextField(
              controller: cardNumberCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [_cardNumberFormatter],
              maxLength: 19,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: t.pay_card_number, hintText: t.pay_card_number_hint, counterText: '', suffixIcon: net.isNotEmpty ? Padding(padding: const EdgeInsets.all(8), child: _cardNetworkBadge(net)) : null),
            ),
            kAppSpacerVertical(height: 12),
            TextField(controller: cardNameCtrl, textCapitalization: TextCapitalization.words, onChanged: (_) => setState(() {}), decoration: InputDecoration(labelText: t.pay_card_name)),
            kAppSpacerVertical(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: expiryCtrl, keyboardType: TextInputType.number, inputFormatters: [_expiryFormatter], maxLength: 5, decoration: InputDecoration(hintText: t.pay_card_expiry_hint, labelText: t.pay_card_expiry))),
                const SizedBox(width: 12),
                Expanded(
                    child: TextField(
                        controller: cvvCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: _obscureCvv,
                        decoration: InputDecoration(
                          labelText: t.pay_card_cvv,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureCvv ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                            onPressed: () => setState(() => _obscureCvv = !_obscureCvv),
                          ),
                        ))),
              ],
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.pay_save_card, style: TextStyle(fontSize: 14)),
              subtitle: Text(t.pay_save_card_sub,
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              value: _saveCard,
              onChanged: (v) => setState(() => _saveCard = v ?? false),
            ),
            kAppSpacerVertical(height: 4),
            _payButton('${t.pay_prefix} ₹$_amountStr', _payCard),
          ],
        ),
      ),
    );
  }

  /// Enterprise picker: replaces DropdownButtonFormField (which renders a
  /// black overlay menu inside bottom sheets on some themes/devices).
  /// White sheet, leading icons, radio rows, most-used first (lists already sorted).
  /// Pass [logoFor] to render real brand logos (bank/wallet via Razorpay URLs).
  Future<String?> _pickFromList(BuildContext context, String title, List<String> items, String? current, {IconData icon = Icons.account_balance_outlined, Widget Function(String item)? logoFor}) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Icon(icon, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 10),
                    Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                    IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final v = items[i];
                    final sel = v == current;
                    final Widget leading = logoFor != null
                        ? logoFor(v)
                        : Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                            child: Icon(icon, color: Colors.black87, size: 22),
                          );
                    return ListTile(
                      tileColor: Theme.of(context).colorScheme.surface,
                      leading: leading,
                      title: Text(v, style: TextStyle(fontWeight: sel ? FontWeight.w700 : FontWeight.normal)),
                      trailing: sel ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      onTap: () => Navigator.of(ctx).pop(v),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

    /// #8 funnel analytics (fire-and-forget; backend has verify truth).
  Future<void> _logPayEvent(String name, [Map<String, String>? data]) async {    try {
      await AuthRepository().saveEvent(name, data ?? {'paymentId': widget.paymentId}, 'pay_funnel', 'pay_funnel');
    } catch (_) {}
  }
  Widget _loadingRows({int count = 3}) {
    return Column(
      children: List.generate(
        count,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: SkeletonLine(style: SkeletonLineStyle(height: 48, width: double.infinity, borderRadius: BorderRadius.all(Radius.circular(10)))),
        ),
      ),
    );
  }

  Widget _pickerField({required String label, required String value, required VoidCallback onTap, IconData icon = Icons.arrow_drop_down}) {    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: Colors.black87), suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.black54)),
        child: Text(value.isEmpty ? 'Select' : value, style: const TextStyle(fontSize: 15, color: Colors.black87)),
      ),
    );
  }

  // ---------- real brand logos (Razorpay URLs + fallbacks) ----------
  // Banks/wallets: Razorpay hosts official logos — fetched live, cached per
  // build via FutureBuilder. UPI apps have no logo API (Play-store
  // trademarks can't be bundled) so _brandAvatar letters + installed tick
  // stay the enterprise-acceptable stand-in until designer PNGs land.
  // Cards: network badge from PAN (Visa/MC/RuPay/Amex), never the full number.
  final Map<String, Future<String>> _logoFutures = {};

  /// Fetch-based logo: Google favicon service by brand domain (no assets).
  /// Always PNG, hotlink-friendly. Falls back to initials on error.
  String _faviconUrl(String domain, {int size = 128}) =>
      'https://www.google.com/s2/favicons?domain=$domain&sz=$size';

  String _domainForUpi(String id) {
    switch (id) {
      case 'phonepe':
        return 'phonepe.com';
      case 'gpay':
        return 'pay.google.com';
      case 'paytm':
        return 'paytm.com';
      case 'bhim':
        return 'bhimupi.org.in';
      case 'amazon':
        return 'amazonpay.in';
      case 'whatsapp':
        return 'whatsapp.com';
      default:
        return '';
    }
  }

  String _domainForWallet(String wallet) {
    final w = wallet.toLowerCase();
    if (w.contains('mobikwik')) return 'mobikwik.com';
    if (w.contains('paytm')) return 'paytm.com';
    if (w.contains('amazon')) return 'amazonpay.in';
    if (w.contains('phonepe')) return 'phonepe.com';
    if (w.contains('freecharge')) return 'freecharge.in';
    if (w.contains('olamoney')) return 'olamoney.com';
    if (w.contains('jiomoney') || w.contains('jio')) return 'jio.com';
    return '';
  }

  String _domainForBank(String bank) {
    final b = bank.toLowerCase();
    if (b.contains('hdfc')) return 'hdfcbank.com';
    if (b.contains('sbi') || b.contains('state bank')) return 'sbi.co.in';
    if (b.contains('icici')) return 'icicibank.com';
    if (b.contains('axis')) return 'axisbank.com';
    if (b.contains('kotak')) return 'kotak.com';
    if (b.contains('yes')) return 'yesbank.in';
    if (b.contains('punjab') || b.contains('pnb')) return 'pnb.co.in';
    if (b.contains('baroda') || b.contains('bob')) return 'bankofbaroda.in';
    if (b.contains('canara')) return 'canarabank.com';
    if (b.contains('union')) return 'unionbankofindia.co.in';
    if (b.contains('idbi')) return 'idbi.com';
    if (b.contains('indusind')) return 'indusind.com';
    return '';
  }

  String _domainForPaylater(String provider) {
    final p = provider.toLowerCase();
    if (p.contains('simpl')) return 'getsimpl.com';
    if (p.contains('lazy')) return 'lazypay.com';
    if (p.contains('icici')) return 'icicibank.com';
    return '';
  }

  Future<String> _bankLogoUrl(String bank) {
    return _logoFutures.putIfAbsent('bank_$bank', () async {
      try {
        final url = await widget.razorpayService.getBankLogoUrl(bank);
        return url.toString();
      } catch (_) {
        return '';
      }
    });
  }

  Future<String> _walletLogoUrl(String wallet) {
    return _logoFutures.putIfAbsent('wallet_$wallet', () async {
      try {
        final url = await widget.razorpayService.getWalletLogoUrl(wallet);
        return url.toString();
      } catch (_) {
        return '';
      }
    });
  }

  Widget _bankLogo(String bank) {
    // Fetch-first: favicon by domain (no assets). Razorpay URL second.
    final domain = _domainForBank(bank);
    if (domain.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(_faviconUrl(domain),
            width: 40, height: 40, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _razorpayBankLogo(bank)),
      );
    }
    return _razorpayBankLogo(bank);
  }

  Widget _razorpayBankLogo(String bank) {
    return FutureBuilder<String>(
      future: _bankLogoUrl(bank),
      builder: (ctx, snap) {
        final url = snap.data ?? '';
        if (url.startsWith('http')) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(url, width: 40, height: 40, fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _initialAvatar(bank)),
          );
        }
        // Loading or no URL: letter avatar (never blank).
        return _initialAvatar(bank);
      },
    );
  }

  Widget _walletLogo(String wallet) {
    final domain = _domainForWallet(wallet);
    if (domain.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(_faviconUrl(domain),
            width: 40, height: 40, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _razorpayWalletLogo(wallet)),
      );
    }
    return _razorpayWalletLogo(wallet);
  }

  Widget _razorpayWalletLogo(String wallet) {
    return FutureBuilder<String>(
      future: _walletLogoUrl(wallet),
      builder: (ctx, snap) {
        final url = snap.data ?? '';
        if (url.startsWith('http')) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(url, width: 40, height: 40, fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _initialAvatar(wallet, bg: const Color(0xFFFEF3C7))),
          );
        }
        return _initialAvatar(wallet, bg: const Color(0xFFFEF3C7));
      },
    );
  }

  Widget _cardNetworkBadge(String label) {
    final upper = label.toUpperCase();
    Color bg = Colors.grey.shade200;
    Color fg = Colors.black87;
    String text = label;
    if (upper.contains('VISA')) {
      bg = const Color(0xFF1A1F71);
      fg = Colors.white;
      text = 'VISA';
    } else if (upper.contains('MASTER')) {
      bg = const Color(0xFFB71C1C);
      fg = Colors.white;
      text = 'MC';
    } else if (upper.contains('RUPAY')) {
      bg = const Color(0xFF097939);
      fg = Colors.white;
      text = 'RuPay';
    } else if (upper.contains('AMEX')) {
      bg = const Color(0xFF2E77BC);
      fg = Colors.white;
      text = 'AMEX';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
    );
  }

  /// PayLater: fetch brand favicon first, chip stand-in on error.
  Widget _paylaterLogo(String provider) {
    final domain = _domainForPaylater(provider);
    if (domain.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(_faviconUrl(domain),
            width: 40, height: 40, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _paylaterChip(provider)),
      );
    }
    return _paylaterChip(provider);
  }

  Widget _paylaterChip(String provider) {
    final p = provider.toLowerCase();
    Color bg = const Color(0xFF4F46E5);
    String text = provider;
    if (p.contains('simpl')) {
      bg = const Color(0xFF00BFA6);
      text = 'Simpl';
    } else if (p.contains('lazy')) {
      bg = const Color(0xFF7C3AED);
      text = 'LazyPay';
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Center(child: Text(text.isNotEmpty ? text[0].toUpperCase() : 'P', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
    );
  }

  /// Letter avatar fallback when Razorpay returns no logo URL — so rows
  /// never look imageless ("images not loading").
  Widget _initialAvatar(String name, {Color bg = const Color(0xFFEEF2FF)}) {
    final initials = name.trim().isEmpty
        ? '•'
        : name.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0].toUpperCase()).join();
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
      child: Center(child: Text(initials, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A)))),
    );
  }

  Widget _nbView() {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _subHeader(t.pay_nb_title),
            Text(t.pay_nb_sub, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            kAppSpacerVertical(height: 12),
            if (banks.isEmpty)
              _loadingRows()
            else
              _pickerField(
                label: t.pay_select_bank,
                value: selectedBank ?? '',
                icon: Icons.account_balance_outlined,
                onTap: () async {
                  final v = await _pickFromList(context, t.pay_select_bank, banks, selectedBank, icon: Icons.account_balance_outlined, logoFor: _bankLogo);
                  if (v != null && mounted) setState(() => selectedBank = v);
                },
              ),
            kAppSpacerVertical(height: 16),
            _payButton('${t.pay_prefix} ₹$_amountStr', _payNb),
          ],
        ),
      ),
    );
  }

  Widget _walletView() {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _subHeader(t.pay_wallets_title),
            Text(t.pay_wallets_sub, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            kAppSpacerVertical(height: 12),
            if (wallets.isEmpty)
              _loadingRows()
            else
              _pickerField(
                label: t.pay_select_wallet,
                value: selectedWallet ?? '',
                icon: Icons.account_balance_wallet_outlined,
                onTap: () async {
                  final v = await _pickFromList(context, t.pay_select_wallet, wallets, selectedWallet, icon: Icons.account_balance_wallet_outlined, logoFor: _walletLogo);
                  if (v != null && mounted) setState(() => selectedWallet = v);
                },
              ),
            kAppSpacerVertical(height: 8),
            Text(t.pay_wallet_note, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            kAppSpacerVertical(height: 16),
            _payButton('${t.pay_prefix} ₹$_amountStr', _payWallet),
          ],
        ),
      ),
    );
  }

  Widget _paylaterView() {
    final t = AppLocalizations.of(context)!;
    final providers = <String>['simpl', 'lazypay'];
    selectedPaylater ??= providers.first;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _subHeader(t.pay_paylater),
            Text(t.pay_paylater_note, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            kAppSpacerVertical(height: 12),
            _pickerField(
              label: t.pay_provider,
              value: selectedPaylater ?? providers.first,
              icon: Icons.schedule_outlined,
              onTap: () async {
                final v = await _pickFromList(context, t.pay_provider, providers, selectedPaylater, icon: Icons.schedule_outlined, logoFor: _paylaterLogo);
                if (v != null && mounted) setState(() => selectedPaylater = v);
              },
            ),
            kAppSpacerVertical(height: 8),
            const Text('Billed to your PayLater account. Enable Simpl/LazyPay in Razorpay dashboard for live use.',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            kAppSpacerVertical(height: 16),
            _payButton('${t.pay_prefix} ₹$_amountStr', _payPaylater),
          ],
        ),
      ),
    );
  }

  Widget _emiView() {
    final t = AppLocalizations.of(context)!;
    const plans = <String>['3 months', '6 months', '9 months', '12 months'];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _subHeader(t.pay_emi),
            const Text('Credit-card EMI. Interest as per bank.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            kAppSpacerVertical(height: 12),
            if (banks.isEmpty)
              _loadingRows()
            else
              _pickerField(
                label: t.pay_bank,
                value: selectedEmiBank ?? '',
                icon: Icons.account_balance_outlined,
                onTap: () async {
                  final v = await _pickFromList(context, t.pay_bank, banks, selectedEmiBank, icon: Icons.account_balance_outlined, logoFor: _bankLogo);
                  if (v != null && mounted) setState(() => selectedEmiBank = v);
                },
              ),
            kAppSpacerVertical(height: 8),
            _pickerField(
              label: t.pay_plan,
              value: selectedEmiPlan,
              icon: Icons.calendar_month_outlined,
              onTap: () async {
                final v = await _pickFromList(context, t.pay_plan, plans, selectedEmiPlan, icon: Icons.calendar_month_outlined);
                if (v != null && mounted) setState(() => selectedEmiPlan = v);
              },
            ),
            kAppSpacerVertical(height: 8),
            _emiBreakdown(),
            kAppSpacerVertical(height: 16),
            _payButton('${t.pay_prefix} ₹$_amountStr', _payEmi),
          ],
        ),
      ),
    );
  }

  /// #4 EMI calculator (indicative; bank adds interest on its page).
  int _emiMonths() {
    final m = RegExp(r'(\d+)').firstMatch(selectedEmiPlan)?.group(1);
    return int.tryParse(m ?? '') ?? 6;
  }

  Widget _emiBreakdown() {
    final months = _emiMonths();
    final monthly = months > 0 ? _amountRupees / months : 0.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('₹${monthly.toStringAsFixed(2)} × $months months', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('Indicative principal split. Interest/charges as per bank on next screen.',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  // ---------- processing (ref #5) ----------

  Widget _processingView() {
    final t = AppLocalizations.of(context)!;
    final bool isCod = selected == CustomPayMethod.cod;
    final String appName = isCod
        ? t.pay_cod_title
        : selected == CustomPayMethod.upi
            ? _upiLabel(selectedUpiApp)
            : selected == CustomPayMethod.paylater
                ? 'PayLater (${selectedPaylater ?? ''})'
                : selected == CustomPayMethod.emi
                    ? 'EMI (${selectedEmiBank ?? ''})'
                    : selected.name.toUpperCase();
    final steps = [t.pay_step_request, t.pay_step_open(appName), t.pay_step_wait, t.pay_step_finalize];
    final String redirectHint = selected == CustomPayMethod.upi
        ? 'You will switch to $appName — approve there, then return here. Do not close the app.'
        : selected == CustomPayMethod.wallet
            ? 'Enter the wallet OTP on the next screen to authorize.'
            : selected == CustomPayMethod.card || selected == CustomPayMethod.emi
                ? 'Complete 3DS / OTP on the bank page to authorize.'
                : t.pay_redirect_sub(appName);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(onPressed: null, icon: const Icon(Icons.arrow_back, color: Colors.grey)),
                Text(t.pay_processing_title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
            kAppSpacerVertical(height: 24),
            // Lottie processing art with static fallback (offline-safe).
            SizedBox(
              width: 180,
              height: 180,
              child: Lottie.asset(
                'assets/jsons/payment_processing.json',
                repeat: true,
                animate: true,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) => Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(color: const Color(0xFFF3EFFF), shape: BoxShape.circle),
                    ),
                    Container(
                      width: 110,
                      height: 160,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade300)),
                      child: Center(child: _brandAvatar(selected == CustomPayMethod.upi ? selectedUpiApp : 'other', size: 56)),
                    ),
                  ],
                ),
              ),
            ),
            kAppSpacerVertical(height: 20),
            Text(isCod ? t.pay_cod_placing : t.pay_redirect_title(appName), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(isCod ? t.pay_cod_wait : redirectHint,
                textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            kAppSpacerVertical(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: List.generate(steps.length, (i) {
                  final done = i < processingStep + 1;
                  final active = i == processingStep + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(done ? Icons.check_circle : Icons.radio_button_checked_outlined, color: done ? Colors.green : Colors.grey.shade400, size: 22),
                        const SizedBox(width: 12),
                        Expanded(child: Text(steps[i], style: TextStyle(fontWeight: active ? FontWeight.w600 : FontWeight.normal, color: done || active ? Colors.black87 : Colors.grey))),
                      ],
                    ),
                  );
                }),
              ),
            ),
            kAppSpacerVertical(height: 12),
            Text(t.pay_dont_back, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class CustomPaymentSheetView extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final RazorpayService razorpayService;
  final String paymentId;
  final String codPaymentId;
  final VoidCallback? onCodSuccess;
  const CustomPaymentSheetView({
    super.key,
    required this.orderData,
    required this.razorpayService,
    this.paymentId = '',
    this.codPaymentId = '',
    this.onCodSuccess,
  });

  @override
  State<CustomPaymentSheetView> createState() => _CustomPaymentSheetViewState();
}
