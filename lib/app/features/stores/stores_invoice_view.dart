import 'package:flutter/material.dart';

/// Displays a GST tax invoice for a delivered order.
class StoresInvoiceView extends StatelessWidget {
  const StoresInvoiceView({super.key, required this.order});
  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> inv = order['invoice'] is Map
        ? Map<String, dynamic>.from(order['invoice'] as Map)
        : <String, dynamic>{};
    final List<dynamic> lines = inv['lines'] is List ? inv['lines'] as List : const <dynamic>[];
    return Scaffold(
      appBar: AppBar(title: Text('Invoice ${inv['invoiceNo'] ?? ''}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('Invoice No: ${inv['invoiceNo'] ?? '—'}'),
          Text('Financial Year: ${inv['financialYear'] ?? '—'}'),
          Text('Issued: ${inv['issuedAt'] ?? '—'}'),
          Text('Seller GSTIN: ${inv['sellerGstin'] ?? '—'}'),
          Text('Buyer GSTIN: ${inv['buyerGstin'] ?? '—'}'),
          Text('Place of supply: ${inv['placeOfSupply'] ?? '—'}'),
          Text('Tax mode: ${inv['taxMode'] ?? '—'}'),
          const SizedBox(height: 12),
          const Text('Lines', style: TextStyle(fontWeight: FontWeight.bold)),
          for (final dynamic raw in lines)
            if (raw is Map<String, dynamic>)
              ListTile(
                dense: true,
                title: Text('${raw['description'] ?? 'Item'}'),
                subtitle: Text('HSN ${raw['hsn'] ?? '—'}'),
                trailing: Text('₹${raw['total'] ?? 0}'),
              ),
          const SizedBox(height: 12),
          Text('CGST: ${inv['cgstTotal'] ?? 0}'),
          Text('SGST: ${inv['sgstTotal'] ?? 0}'),
          Text('IGST: ${inv['igstTotal'] ?? 0}'),
          Text('Grand total: ${order['grandTotal'] ?? ''}'),
          if (inv['isVoided'] == true) const Text('VOIDED', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
