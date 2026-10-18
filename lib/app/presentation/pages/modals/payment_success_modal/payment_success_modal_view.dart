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
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class PaymentSuccessModalScreen extends StatelessWidget {
  final String from;
  // Reference success screen (ref #6) — all live, no mocks.
  final String? orderId;
  final String? amount;
  final String? methodLabel;
  final String? eta;
  final VoidCallback? onTrackOrder;
  final VoidCallback? onBackHome;
  const PaymentSuccessModalScreen({
    super.key,
    required this.from,
    this.orderId,
    this.amount,
    this.methodLabel,
    this.eta,
    this.onTrackOrder,
    this.onBackHome,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    // Detailed order-success layout when live data provided.
    if (from == 'order' && orderId != null) {
      return _OrderSuccessView(
        orderId: orderId!,
        amount: amount ?? '',
        methodLabel: (methodLabel?.isNotEmpty == true) ? methodLabel! : t.pay_online,
        eta: eta ?? '',
        onTrackOrder: onTrackOrder,
        onBackHome: onBackHome,
      );
    }
    // Failed states: titled view with Try Again (pop 'retry') + dismiss (pop true).
    // Previously these rendered a blank title — the No.1 UX complaint.
    if (from.endsWith('_failed')) {
      return _PaymentFailedView(from: from);
    }
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(scrolledUnderElevation: 0, automaticallyImplyLeading: false),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(AssetsUrl.imageURL.successPaymentIcon, height: 100, width: 100),
              kAppSpacerVertical(height: 20),
              if (from == 'order') ...[
                Text(
                  translate.order_success_dialog_title,
                  textAlign: TextAlign.center,
                  style: kAppLblSmallFontBold(context, color: 'primary'),
                ),
                kAppSpacerVertical(height: 10),
                Text(translate.order_sucess_dialog_content, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
              ] else if (from == 'wallet') ...[
                Text(
                  translate.wallet_success_dialog_title,
                  textAlign: TextAlign.center,
                  style: kAppLblSmallFontBold(context, color: 'primary'),
                ),
                kAppSpacerVertical(height: 10),
                Text(translate.wallet_success_dialog_content, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
              ] else if (from == 'dining') ...[
                Text(
                  translate.dining_success_dialog_title,
                  textAlign: TextAlign.center,
                  style: kAppLblSmallFontBold(context, color: 'primary'),
                ),
                kAppSpacerVertical(height: 10),
                Text(translate.dining_success_dialog_content, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
              ] else if (from == 'tiffin') ...[
                Text(
                  translate.tiffin_success_dialog_title,
                  textAlign: TextAlign.center,
                  style: kAppLblSmallFontBold(context, color: 'primary'),
                ),
                kAppSpacerVertical(height: 10),
                Text(translate.tiffin_success_dialog_content, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
              ],
              kAppSpacerVertical(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: kAppTextButtonColoredStyle(context, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor),
                      child: Text(translate.thank_you_btn),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Failed payment view: titled + Try Again (pop 'retry') + dismiss (pop true).
/// Callers handle 'retry' by resetting gateway state (idempotent re-submit).
/// PopScope blocks system-back null dismissal (which left processing stuck).
class _PaymentFailedView extends StatelessWidget {
  final String from;
  const _PaymentFailedView({required this.from});

  String _title(AppLocalizations t) {
    switch (from) {
      case 'wallet_failed':
        return t.pay_fail_wallet;
      case 'dining_failed':
        return t.pay_fail_dining;
      case 'tiffin_failed':
        return t.pay_fail_tiffin;
      case 'restaurant_register_failed':
        return t.pay_fail_register;
      default:
        return t.pay_fail_order;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    // Block system-back: null pop left payment screen stuck on processing.
    // User must choose Try Again (retry) or Go Back (true).
    return PopScope(
      canPop: false,
      child: Scaffold(
      appBar: AppBar(scrolledUnderElevation: 0, automaticallyImplyLeading: false),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: Lottie.asset(
                  'assets/jsons/failed.json',
                  repeat: false,
                  animate: true,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => Icon(Icons.close, color: Colors.red.shade600, size: 56),
                ),
              ),
              kAppSpacerVertical(height: 16),
              Text(_title(t), textAlign: TextAlign.center, style: kAppLblSmallFontBold(context)),
              kAppSpacerVertical(height: 8),
              Text(
                t.pay_fail_msg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              kAppSpacerVertical(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.of(context).pop('retry'),
                  child: Text(t.pay_try_again, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              kAppSpacerVertical(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(t.pay_go_back),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
/// Reference success screen (ref #6): confetti header, live Order ID /
/// Total / Method / ETA, Track Order + Back to Home. No mocked numbers.
class _OrderSuccessView extends StatelessWidget {
  final String orderId;
  final String amount;
  final String methodLabel;
  final String eta;
  final VoidCallback? onTrackOrder;
  final VoidCallback? onBackHome;
  const _OrderSuccessView({
    required this.orderId,
    required this.amount,
    required this.methodLabel,
    required this.eta,
    this.onTrackOrder,
    this.onBackHome,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final primary = Theme.of(context).primaryColor;
    // Success animation stays until explicit Track/Home (no back-dismiss).
    return PopScope(
      canPop: false,
      child: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
          child: Column(
            children: [
              kAppSpacerVertical(height: 16),
              SizedBox(
                width: 120,
                height: 120,
                child: Lottie.asset(
                  'assets/jsons/success.json',
                  repeat: true,
                  animate: true,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 56),
                  ),
                ),
              ),
              kAppSpacerVertical(height: 12),
              Text(t.pay_success_title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(t.pay_success_sub, style: const TextStyle(color: Colors.grey)),
              kAppSpacerVertical(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _row(t.pay_order_id, '#$orderId', copyable: true),
                    const Divider(),
                    _row(t.pay_total_paid, '₹$amount', bold: true),
                    const Divider(),
                    _row(t.pay_method_label, methodLabel),
                    if (eta.isNotEmpty) ...[const Divider(), _row(t.pay_eta, eta)],
                  ],
                ),
              ),
              kAppSpacerVertical(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: onTrackOrder ?? () => Navigator.of(context).pop(true),
                  child: Text(t.pay_track, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              kAppSpacerVertical(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: onBackHome ?? () => Navigator.of(context).pop(true),
                  child: Text(t.pay_home),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  final text = 'Order #$orderId • ₹$amount • $methodLabel';
                  Share.share(text, subject: 'Payment receipt');
                },
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('Share receipt'),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _row(String k, String v, {bool bold = false, bool copyable = false}) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Row(
          children: [
            Text(v, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w600, fontSize: bold ? 16 : 14)),
            if (copyable) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.copy_outlined, size: 14, color: Colors.grey)),
          ],
        ),
      ],
    );
    if (!copyable) return row;
    return Builder(builder: (ctx) {
      return InkWell(
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: v));
          if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Copied')));
        },
        child: row,
      );
    });
  }
}

