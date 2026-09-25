import 'package:flutter/material.dart';

class TaxCalculatorScreen extends StatefulWidget {
  const TaxCalculatorScreen({super.key});

  @override
  State<TaxCalculatorScreen> createState() => _TaxCalculatorScreenState();
}

class _TaxCalculatorScreenState extends State<TaxCalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Calculator'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'GST'), Tab(text: 'TDS'), Tab(text: 'Income Tax')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [_GSTCalculator(), _TDSCalculator(), _IncomeTaxCalculator()],
      ),
    );
  }
}

// ---------------- GST Calculator ----------------
class _GSTCalculator extends StatefulWidget {
  const _GSTCalculator();
  @override
  State<_GSTCalculator> createState() => _GSTCalculatorState();
}

class _GSTCalculatorState extends State<_GSTCalculator> {
  final _amountCtrl = TextEditingController();
  double _rate = 18;
  bool _isExclusive = true; // true = add GST, false = remove GST (amount is inclusive)
  double? _cgst, _sgst, _igst, _total, _base;

  final List<double> _rates = [0, 0.25, 3, 5, 12, 18, 28];

  void _calculate() {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (amount <= 0) return;
    double base, gstAmount, total;
    if (_isExclusive) {
      base = amount;
      gstAmount = base * _rate / 100;
      total = base + gstAmount;
    } else {
      total = amount;
      base = total / (1 + _rate / 100);
      gstAmount = total - base;
    }
    setState(() {
      _base = base;
      _cgst = gstAmount / 2;
      _sgst = gstAmount / 2;
      _igst = gstAmount;
      _total = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const Text('GST Rate'),
          Wrap(
            spacing: 8,
            children: _rates.map((r) {
              return ChoiceChip(
                label: Text('$r%'),
                selected: _rate == r,
                onSelected: (_) => setState(() => _rate = r),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Add GST')),
              ButtonSegment(value: false, label: Text('Remove GST')),
            ],
            selected: {_isExclusive},
            onSelectionChanged: (s) => setState(() => _isExclusive = s.first),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Calculate'),
          )),
          const SizedBox(height: 20),
          if (_total != null) Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Base Amount', _base!),
                  _row('CGST (${_rate / 2}%)', _cgst!),
                  _row('SGST (${_rate / 2}%)', _sgst!),
                  _row('IGST ($_rate%)', _igst!),
                  const Divider(),
                  _row('Total Amount', _total!, bold: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double value, {bool bold = false}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 16 : 14);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text('₹${value.toStringAsFixed(2)}', style: style)],
      ),
    );
  }
}

// ---------------- TDS Calculator ----------------
class _TDSCalculator extends StatefulWidget {
  const _TDSCalculator();
  @override
  State<_TDSCalculator> createState() => _TDSCalculatorState();
}

class _TDSCalculatorState extends State<_TDSCalculator> {
  final _amountCtrl = TextEditingController();
  String _section = '194C - Contractor (Individual)';
  double? _tdsAmount, _netAmount;

  // section: rate %
  final Map<String, double> _sections = {
    '194C - Contractor (Individual)': 1,
    '194C - Contractor (Company)': 2,
    '194J - Professional Fees': 10,
    '194H - Commission/Brokerage': 5,
    '194I - Rent (Land/Building)': 10,
    '194I - Rent (Plant/Machinery)': 2,
    '192 - Salary (as per slab)': 0,
    '194A - Interest (other than securities)': 10,
  };

  void _calculate() {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (amount <= 0) return;
    final rate = _sections[_section] ?? 0;
    final tds = amount * rate / 100;
    setState(() {
      _tdsAmount = tds;
      _netAmount = amount - tds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Payment Amount (₹)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _section,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'TDS Section', border: OutlineInputBorder()),
            items: _sections.keys.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (v) => setState(() => _section = v!),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Calculate'),
          )),
          const SizedBox(height: 20),
          if (_tdsAmount != null) Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TDS Rate: ${_sections[_section]}%'),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('TDS Amount'),
                    Text('₹${_tdsAmount!.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                  const Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Net Payable', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('₹${_netAmount!.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Note: Rates shown are indicative. Verify current rates against the latest Income Tax Act before filing.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ---------------- Income Tax Calculator (New Regime FY 2024-25 slabs) ----------------
class _IncomeTaxCalculator extends StatefulWidget {
  const _IncomeTaxCalculator();
  @override
  State<_IncomeTaxCalculator> createState() => _IncomeTaxCalculatorState();
}

class _IncomeTaxCalculatorState extends State<_IncomeTaxCalculator> {
  final _incomeCtrl = TextEditingController();
  double? _tax, _cess, _totalTax;

  void _calculate() {
    final income = double.tryParse(_incomeCtrl.text) ?? 0;
    if (income <= 0) return;

    double taxable = income > 750000 ? income - 75000 : income; // standard deduction (new regime, approx)
    double tax = 0;

    // New regime slabs (illustrative - update per latest budget)
    final slabs = [
      [300000, 0.0],
      [700000, 0.05],
      [1000000, 0.10],
      [1200000, 0.15],
      [1500000, 0.20],
    ];

    double prevLimit = 0;
    for (var slab in slabs) {
      double limit = slab[0];
      double rate = slab[1];
      if (taxable > limit) {
        tax += (limit - prevLimit) * rate;
      } else {
        tax += (taxable - prevLimit) * rate;
        prevLimit = limit;
        break;
      }
      prevLimit = limit;
    }
    if (taxable > 1500000) {
      tax += (taxable - 1500000) * 0.30;
    }

    // Rebate u/s 87A - if taxable income <= 7,00,000, tax becomes 0 (new regime)
    if (taxable <= 700000) tax = 0;

    final cess = tax * 0.04;
    setState(() {
      _tax = tax;
      _cess = cess;
      _totalTax = tax + cess;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _incomeCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Annual Gross Income (₹)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          const Text('Based on New Tax Regime slabs. Update slab values in code as per latest Budget.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 20),
          FilledButton(onPressed: _calculate, child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Calculate'),
          )),
          const SizedBox(height: 20),
          if (_totalTax != null) Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Income Tax'), Text('₹${_tax!.toStringAsFixed(2)}'),
                  ]),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Health & Education Cess (4%)'), Text('₹${_cess!.toStringAsFixed(2)}'),
                  ]),
                  const Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total Tax Payable', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('₹${_totalTax!.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
