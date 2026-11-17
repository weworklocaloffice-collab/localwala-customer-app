/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * This source code, including all associated assets, APIs, databases,
 * business logic, designs, and documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution, publication, resale,
 * reverse engineering, or use of this software without prior written
 * authorization is strictly prohibited.
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color _slate900 = Color(0xFF0F172A);
const Color _slate600 = Color(0xFF475569);
const Color _slate500 = Color(0xFF64748B);
const Color _slate200 = Color(0xFFE2E8F0);
const Color _slate50 = Color(0xFFF8FAFC);

Color lsStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'CONFIRMED':
    case 'ACCEPTED':
      return const Color(0xFF2563EB);
    case 'IN_PROGRESS':
      return const Color(0xFF4F46E5);
    case 'COMPLETED':
    case 'PAID':
    case 'RESOLVED':
      return const Color(0xFF059669);
    case 'REQUESTED':
    case 'PENDING':
    case 'PAYMENT_PENDING':
    case 'OPEN':
      return const Color(0xFFD97706);
    case 'CANCELLED':
    case 'FAILED':
    case 'REJECTED':
      return const Color(0xFFDC2626);
    case 'DISPUTED':
      return const Color(0xFFEA580C);
    case 'REFUNDED':
    case 'PARTIALLY_REFUNDED':
      return const Color(0xFF7C3AED);
    case 'DRAFT':
    default:
      return _slate500;
  }
}

String lsStatusLabel(String status, {bool payment = false}) {
  final String value = status.toUpperCase();
  if (payment) {
    switch (value) {
      case 'PENDING':
        return 'Payment pending';
      case 'PARTIALLY_PAID':
        return 'Partially paid';
      case 'PAID':
        return 'Paid';
      case 'PARTIALLY_REFUNDED':
        return 'Partially refunded';
      case 'REFUNDED':
        return 'Refunded';
      case 'FAILED':
        return 'Payment failed';
      default:
        return status.isEmpty ? 'Payment pending' : status;
    }
  }
  switch (value) {
    case 'DRAFT':
      return 'Draft';
    case 'REQUESTED':
      return 'Requested';
    case 'CONFIRMED':
      return 'Confirmed';
    case 'IN_PROGRESS':
      return 'In progress';
    case 'COMPLETED':
      return 'Completed';
    case 'CANCELLED':
      return 'Cancelled';
    case 'DISPUTED':
      return 'Disputed';
    case 'OPEN':
      return 'Open';
    case 'RESOLVED':
      return 'Resolved';
    default:
      return status.isEmpty ? 'Unknown' : status;
  }
}

/// Small tinted pill used for booking / payment / complaint statuses.
class LsStatusChip extends StatelessWidget {
  const LsStatusChip({super.key, required this.status, this.payment = false});

  final String status;
  final bool payment;

  @override
  Widget build(BuildContext context) {
    final Color color = lsStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            lsStatusLabel(status, payment: payment),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Surface card used across the customer Local Services screens.
class LsCard extends StatelessWidget {
  const LsCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color surface = theme.cardTheme.color ?? theme.colorScheme.surface;
    final Widget content = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _slate900.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap, child: content),
            ),
    );
  }
}

/// Full-height empty state with an optional call to action.
class LsEmptyState extends StatelessWidget {
  const LsEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: _slate900,
              ),
            ),
            if (message != null && message!.isNotEmpty) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: _slate500),
              ),
            ],
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 20),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline error with retry, matching the empty-state layout.
class LsErrorState extends StatelessWidget {
  const LsErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return LsEmptyState(
      icon: Icons.cloud_off_rounded,
      title: 'Something went wrong',
      message: message,
      actionLabel: onRetry == null ? null : 'Try again',
      onAction: onRetry,
    );
  }
}

/// Simple skeleton placeholder list while the first page loads.
class LsSkeletonList extends StatelessWidget {
  const LsSkeletonList({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        return LsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: _bar(context, height: 14, width: 160)),
                  _bar(context, height: 20, width: 72, radius: 999),
                ],
              ),
              const SizedBox(height: 12),
              _bar(context, height: 10, width: double.infinity),
              const SizedBox(height: 8),
              _bar(context, height: 10, width: 220),
              const SizedBox(height: 16),
              _bar(context, height: 28, width: double.infinity, radius: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _bar(
    BuildContext context, {
    required double height,
    required double width,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _slate200.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Section label used above grouped content.
class LsSectionHeader extends StatelessWidget {
  const LsSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: _slate600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (trailing != null) ?trailing,
        ],
      ),
    );
  }
}

/// Avatar-style icon used in support / empty states.
class LsIconBadge extends StatelessWidget {
  const LsIconBadge({super.key, required this.icon, this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color tone = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: tone, size: 22),
    );
  }
}

/// `12 Mar 2026, 04:30 PM` — returns '' when the source is not a date.
String lsFormatDate(String raw, {String pattern = 'dd MMM yyyy, hh:mm a'}) {
  final DateTime? parsed = DateTime.tryParse(raw);
  if (parsed == null) return '';
  return DateFormat(pattern).format(parsed.toLocal());
}

/// `₹1,240.00` from a rupee amount.
String lsMoney(num amount) {
  final NumberFormat format = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20b9',
    decimalDigits: 2,
  );
  return format.format(amount);
}

const Color lsSlate900 = _slate900;
const Color lsSlate600 = _slate600;
const Color lsSlate500 = _slate500;
const Color lsSlate50 = _slate50;
