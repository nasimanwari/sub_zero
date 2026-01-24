import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sub_zero/models/subscription.dart';
import 'package:sub_zero/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  DateTime? selectedDate;
  String selectedPeriod = 'Monthly'; 

  final _subBox = Hive.box('subscriptionsBox');
  final _settingsBox = Hive.box('settingsBox');

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    priceController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  Color getSmartColor(String name) {
    String lower = name.toLowerCase();
    if (lower.contains('netflix')) return const Color(0xFFE50914);
    if (lower.contains('spotify')) return const Color(0xFF1DB954);
    if (lower.contains('youtube')) return const Color(0xFFFF0000);
    if (lower.contains('disney')) return const Color(0xFF113CCF);
    if (lower.contains('amazon') || lower.contains('prime')) return const Color(0xFF00A8E1);
    if (lower.contains('apple')) return const Color(0xFF2C2C2C);
    if (lower.contains('xbox')) return const Color(0xFF107C10);
    if (lower.contains('playstation')) return const Color(0xFF003087);
    return Colors.primaries[name.hashCode % Colors.primaries.length];
  }

  IconData getSmartIcon(String name) {
    String lower = name.toLowerCase();
    if (lower.contains('netflix') || lower.contains('disney') || lower.contains('prime')) return Icons.movie_filter_rounded;
    if (lower.contains('spotify') || lower.contains('music') || lower.contains('deezer')) return Icons.music_note_rounded;
    if (lower.contains('xbox') || lower.contains('game') || lower.contains('steam')) return Icons.sports_esports_rounded;
    if (lower.contains('gym') || lower.contains('fit')) return Icons.fitness_center_rounded;
    if (lower.contains('icloud') || lower.contains('drive')) return Icons.cloud_circle_rounded;
    return Icons.credit_card_rounded;
  }

  void showSubscriptionSheet({Subscription? existingSub, int? index}) {
    HapticFeedback.mediumImpact(); 
    String currency = _settingsBox.get('currency', defaultValue: '\$');

    if (existingSub != null) {
      nameController.text = existingSub.name;
      priceController.text = existingSub.price.toString();
      selectedDate = existingSub.renewalDate;
      selectedPeriod = existingSub.period;
    } else {
      nameController.clear();
      priceController.clear();
      selectedDate = null;
      selectedPeriod = 'Monthly';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 25, right: 25, top: 25,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 30),
                  Text(existingSub == null ? "New Subscription" : "Edit Details",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                    child: TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: "Service Name", border: InputBorder.none, contentPadding: EdgeInsets.all(20), prefixIcon: Icon(Icons.stars_rounded)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                          child: TextField(
                            controller: priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: "Cost", border: InputBorder.none, contentPadding: const EdgeInsets.all(20), prefixText: "$currency ", prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedPeriod,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            items: const [DropdownMenuItem(value: 'Monthly', child: Text("Monthly")), DropdownMenuItem(value: 'Yearly', child: Text("Yearly"))],
                            onChanged: (val) {
                              setModalState(() {
                                selectedPeriod = val!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                      if (picked != null) setModalState(() => selectedDate = picked);
                    },
                    child: Container(
                      width: double.infinity, padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withOpacity(0.2))),
                      child: Row(children: [const Icon(Icons.calendar_today_rounded, color: Colors.blueAccent), const SizedBox(width: 15), Text(selectedDate == null ? "Select Renewal Date" : DateFormat('dd MMMM yyyy').format(selectedDate!), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))]),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0072FF), foregroundColor: Colors.white, elevation: 10, shadowColor: const Color(0xFF0072FF).withOpacity(0.4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: () async {
                        if (nameController.text.isEmpty || priceController.text.isEmpty) { HapticFeedback.heavyImpact(); return; }
                        HapticFeedback.mediumImpact(); 
                        DateTime finalDate = selectedDate ?? DateTime.now().add(const Duration(days: 30));
                        Subscription newSub = Subscription(nameController.text, double.tryParse(priceController.text) ?? 0.0, finalDate, selectedPeriod);
                        bool notificationsEnabled = _settingsBox.get('notifications', defaultValue: true);
                        if (index != null) {
                          await _subBox.putAt(index, newSub);
                          int id = _subBox.keyAt(index);
                          await NotificationService().cancelNotification(id);
                          if (notificationsEnabled) await NotificationService().scheduleNotification(id, newSub.name, newSub.renewalDate);
                        } else {
                          int id = await _subBox.add(newSub);
                          if (notificationsEnabled) await NotificationService().scheduleNotification(id, newSub.name, newSub.renewalDate);
                        }
                        nameController.clear(); priceController.clear(); if (mounted) Navigator.pop(context);
                      },
                      child: const Text("Save Subscription", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: _subBox.listenable(),
        builder: (context, box, _) {
          return ValueListenableBuilder(
            valueListenable: _settingsBox.listenable(),
            builder: (context, settings, _) {
              String currency = settings.get('currency', defaultValue: '\$');
              double totalMonthly = 0;
              for (var item in box.values.cast<Subscription>()) {
                if (item.period == 'Yearly') totalMonthly += item.price / 12;
                else totalMonthly += item.price;
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 280.0,
                    floating: false,
                    pinned: true,
                    stretch: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      background: Container(
                        margin: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                             BoxShadow(
                              color: const Color(0xFF0072FF).withOpacity(0.4),
                              blurRadius: 25,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(getGreeting().toUpperCase(), 
                              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            const SizedBox(height: 5),
                            const Text("Monthly Expenses", 
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 10),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: totalMonthly),
                              duration: const Duration(seconds: 2),
                              curve: Curves.easeOutExpo,
                              builder: (context, value, child) {
                                return Text(
                                  "${value.toStringAsFixed(2)} $currency",
                                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  box.isEmpty 
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.donut_small_rounded, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 20),
                            Text("No subscriptions found", style: TextStyle(color: Colors.grey[400], fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final sub = box.getAt(index) as Subscription;
                          DateTime now = DateTime.now();
                          DateTime today = DateTime(now.year, now.month, now.day);
                          DateTime renewal = DateTime(sub.renewalDate.year, sub.renewalDate.month, sub.renewalDate.day);
                          int daysLeft = renewal.difference(today).inDays;
                          Color brandColor = getSmartColor(sub.name);

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(milliseconds: 400 + (index * 100)),
                            curve: Curves.easeOutQuart,
                            builder: (context, val, child) {
                              return Transform.translate(
                                offset: Offset(0, 50 * (1 - val)),
                                child: Opacity(opacity: val, child: child),
                              );
                            },
                            child: Dismissible(
                              key: UniqueKey(),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
                                alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 25), 
                                child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 30),
                              ),
                              onDismissed: (_) async {
                                HapticFeedback.mediumImpact(); 
                                int id = box.keyAt(index);
                                await NotificationService().cancelNotification(id);
                                box.deleteAt(index);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    )
                                  ]
                                ),
                                child: ListTile(
                                  onTap: () => showSubscriptionSheet(existingSub: sub, index: index),
                                  contentPadding: const EdgeInsets.all(18),
                                  leading: Container(
                                    width: 55, height: 55,
                                    decoration: BoxDecoration(color: brandColor.withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
                                    child: Icon(getSmartIcon(sub.name), color: brandColor, size: 30),
                                  ),
                                  title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Text("${sub.price} $currency", style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16)),
                                        Text(" / ${sub.period == 'Yearly' ? 'yr' : 'mo'}", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: daysLeft < 0 ? Colors.red.withOpacity(0.1) : (daysLeft <= 3 ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1)),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(daysLeft < 0 ? "Expired" : "$daysLeft days", style: TextStyle(color: daysLeft < 0 ? Colors.red : (daysLeft <= 3 ? Colors.orange : Colors.green), fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: box.length,
                      ),
                    ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showSubscriptionSheet(),
        backgroundColor: const Color(0xFF0072FF),
        elevation: 15,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }
} // EKSİK OLAN PARANTEZ BURADAYDI!