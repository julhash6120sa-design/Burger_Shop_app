import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const BurgerShopApp());

class MenuItem {
  final String category, code, bangla, arabic;
  final double price;
  const MenuItem(this.category, this.code, this.bangla, this.arabic, this.price);
}

const menu = <MenuItem>[
  MenuItem('মিলস', 'M1', 'এম ওয়ান লাহাম বার্গার ওয়াজবা', 'M1 لحم برجر وجبة', 17.75),
  MenuItem('মিলস', 'M2', 'এম টু লাহাম বার্গার ওয়াজবা', 'M2 لحم برجر وجبة', 19.75),
  MenuItem('মিলস', 'M3', 'এম থ্রি লাহাম বার্গার ওয়াজবা', 'M3 لحم برجر وجبة', 23.75),
  MenuItem('স্যান্ডউইচ', 'M1', 'এম ওয়ান লাহাম বার্গার', 'M1 لحم برجر', 13.75),
  MenuItem('স্যান্ডউইচ', 'M2', 'এম টু লাহাম বার্গার', 'M2 لحم برجر', 15.75),
  MenuItem('স্যান্ডউইচ', 'M3', 'এম থ্রি লাহাম বার্গার', 'M3 لحم برجر', 19.75),
  MenuItem('সাইড অর্ডার', 'SO1', 'বাতাতিস বিল-জুবজুন', 'بطاطس بالجبن', 9.50),
  MenuItem('সাইড অর্ডার', 'SO2', 'বাতাতিস মুবাহার', 'مبهر بطاطس', 5.50),
  MenuItem('সাইড অর্ডার', 'SO3', 'বাতাতিস ফ্রাই', 'بطاطس', 5.00),
  MenuItem('অতিরিক্ত আইটেম', 'E1', 'শারীহাত লাহাম এম২', 'M2 لحم شريحة', 7.00),
  MenuItem('অতিরিক্ত আইটেম', 'E2', 'জুবজুন', 'جبن', 1.00),
  MenuItem('অতিরিক্ত আইটেম', 'E3', 'সস এম বার্গার দাজাজ', 'دجاج برجر M صوص', 2.00),
  MenuItem('অতিরিক্ত আইটেম', 'E4', 'সস এম বার্গার লাহাম', 'لحم برجر M صوص', 2.00),
  MenuItem('অতিরিক্ত আইটেম', 'E5', 'সস জুবজুন', 'جبن صوص', 2.00),
  MenuItem('অতিরিক্ত আইটেম', 'E6', 'হালাপিনো', 'هالبينو', 2.00),
  MenuItem('অতিরিক্ত আইটেম', 'E7', 'মুখাল্লাল খিয়ার', 'خيار مخلل', 2.00),
  MenuItem('পানীয়', 'D1', 'কিনজা', 'كنز', 2.00),
  MenuItem('পানীয়', 'D2', '', '', 2.00),
];

class BurgerShopApp extends StatelessWidget {
  const BurgerShopApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Burger Shop',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB94B20)),
      useMaterial3: true, scaffoldBackgroundColor: const Color(0xFFFFF9F3)),
    home: const OrderScreen(),
  );
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String category = 'সব';
  final Map<int, int> cart = {};
  String payment = 'Cash';
  double salesToday = 0;
  int ordersToday = 0;
  List<String> recentReceipts = [];

  final categories = const ['সব', 'মিলস', 'স্যান্ডউইচ', 'সাইড অর্ডার', 'অতিরিক্ত আইটেম', 'পানীয়'];
  double get total => cart.entries.fold(0, (s, e) => s + menu[e.key].price * e.value);
  int get count => cart.values.fold(0, (s, q) => s + q);

  @override
  void initState() { super.initState(); _loadStats(); }
  Future<void> _loadStats() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      salesToday = p.getDouble('salesToday') ?? 0;
      ordersToday = p.getInt('ordersToday') ?? 0;
      recentReceipts = p.getStringList('recentReceipts') ?? [];
    });
  }
  Future<void> _saveStats() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('salesToday', salesToday);
    await p.setInt('ordersToday', ordersToday);
    await p.setStringList('recentReceipts', recentReceipts.take(30).toList());
  }
  void add(int i) => setState(() => cart[i] = (cart[i] ?? 0) + 1);
  void changeQty(int i, int d) => setState(() {
    final q = (cart[i] ?? 0) + d;
    if (q <= 0) { cart.remove(i); } else { cart[i] = q; }
  });

  Future<void> checkout() async {
    if (cart.isEmpty) return;
    final lines = cart.entries.map((e) =>
      '${menu[e.key].code}  ${menu[e.key].bangla.isEmpty ? "D2" : menu[e.key].bangla} × ${e.value} = ${(menu[e.key].price * e.value).toStringAsFixed(2)} ⃁').join('\n');
    final receipt = 'BURGER SHOP\n$lines\nTOTAL: ${total.toStringAsFixed(2)} ⃁\nPAYMENT: $payment';
    setState(() {
      salesToday += total;
      ordersToday++;
      recentReceipts.insert(0, '${DateTime.now().toString().substring(0,16)} | ${total.toStringAsFixed(2)} ⃁ | $payment');
      cart.clear();
    });
    await _saveStats();
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('অর্ডার সম্পন্ন হয়েছে'),
      content: SingleChildScrollView(child: SelectableText(receipt)),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('বন্ধ করুন'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final shown = menu.asMap().entries.where((e) => category == 'সব' || e.value.category == category).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('🍔 BURGER SHOP', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [IconButton(tooltip: 'আজকের বিক্রি', icon: const Icon(Icons.bar_chart),
          onPressed: () => showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Padding(
            padding: const EdgeInsets.all(22), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('আজকের বিক্রি', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12), Text('অর্ডার: $ordersToday'), Text('মোট বিক্রি: ${salesToday.toStringAsFixed(2)} ⃁'),
                const SizedBox(height: 12), const Text('সাম্প্রতিক অর্ডার'), ...recentReceipts.take(8).map(Text.new)]
            )))))]),
      body: Column(children: [
        SizedBox(height: 58, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: categories.length, separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => ChoiceChip(label: Text(categories[i]), selected: category == categories[i],
            onSelected: (_) => setState(() => category = categories[i])))),
        Expanded(child: GridView.builder(padding: const EdgeInsets.all(12), itemCount: shown.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .83, crossAxisSpacing: 12, mainAxisSpacing: 12),
          itemBuilder: (_, n) {
            final index = shown[n].key; final item = shown[n].value;
            return InkWell(onTap: () => add(index), borderRadius: BorderRadius.circular(18),
              child: Card(clipBehavior: Clip.antiAlias, elevation: 1, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: Container(color: const Color(0xFFFFE8D4), child: Stack(alignment: Alignment.center, children: [
                  const Icon(Icons.lunch_dining, size: 74, color: Color(0xFFB94B20)),
                  if ((cart[index] ?? 0) > 0) Positioned(right: 8, top: 8, child: CircleAvatar(radius: 14, child: Text('${cart[index]}'))),
                ]))),
                Padding(padding: const EdgeInsets.fromLTRB(10, 8, 10, 2), child: Text(item.bangla.isEmpty ? 'D2' : item.bangla,
                  maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(item.arabic, textDirection: TextDirection.rtl,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                Padding(padding: const EdgeInsets.fromLTRB(10, 5, 10, 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${item.price.toStringAsFixed(2)} ⃁', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFB94B20))),
                  const Icon(Icons.add_circle, color: Color(0xFFB94B20))
                ]))
              ])));
          })),
        Container(padding: const EdgeInsets.fromLTRB(16, 12, 16, 18), decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
          child: Column(children: [
            Row(children: [Text('অর্ডার: $count আইটেম'), const Spacer(), Text('মোট: ${total.toStringAsFixed(2)} ⃁', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold))]),
            if (cart.isNotEmpty) SizedBox(height: 76, child: ListView(children: cart.entries.map((e) => Row(children: [
              Expanded(child: Text(menu[e.key].bangla.isEmpty ? 'D2' : menu[e.key].bangla, maxLines: 1, overflow: TextOverflow.ellipsis)),
              IconButton(onPressed: () => changeQty(e.key, -1), icon: const Icon(Icons.remove_circle_outline)),
              Text('${e.value}'),
              IconButton(onPressed: () => changeQty(e.key, 1), icon: const Icon(Icons.add_circle_outline)),
              Text('${(menu[e.key].price * e.value).toStringAsFixed(2)}')
            ])).toList())),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: ChoiceChip(label: const Text('Cash'), selected: payment == 'Cash', onSelected: (_) => setState(() => payment = 'Cash'))),
              const SizedBox(width: 10),
              Expanded(child: ChoiceChip(label: const Text('Card'), selected: payment == 'Card', onSelected: (_) => setState(() => payment = 'Card'))),
              const SizedBox(width: 10),
              FilledButton.icon(onPressed: cart.isEmpty ? null : checkout, icon: const Icon(Icons.receipt_long), label: const Text('অর্ডার / Receipt')),
            ])
          ]))
      ]),
    );
  }
}
