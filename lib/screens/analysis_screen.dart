import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sub_zero/models/subscription.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  Color getSmartColor(String name) {
    String lower = name.toLowerCase();
    if (lower.contains('netflix')) return const Color(0xFFE50914);
    if (lower.contains('spotify')) return const Color(0xFF1DB954);
    if (lower.contains('youtube')) return const Color(0xFFFF0000);
    if (lower.contains('disney')) return const Color(0xFF113CCF);
    if (lower.contains('amazon') || lower.contains('prime')) return const Color(0xFF00A8E1);
    if (lower.contains('twitter') || lower.contains('x')) return const Color(0xFF1DA1F2);
    if (lower.contains('apple')) return const Color(0xFF2C2C2C);
    
    return Colors.primaries[name.hashCode % Colors.primaries.length];
  }

  // SÜRPRİZ ÖZELLİK: KARAKTER ANALİZ MOTORU 🧠
  Map<String, String> getPersona(Map<String, double> data, double total) {
    if (total == 0) return {"title": "The Ghost 👻", "desc": "No subscriptions? Are you even real?"};
    if (total > 3000) return {"title": "The Tycoon 🎩", "desc": "You are single-handedly funding the economy."};
    
    int video = 0, music = 0, game = 0, work = 0;
    
    for (var key in data.keys) {
      String name = key.toLowerCase();
      if (name.contains('netflix') || name.contains('disney') || name.contains('hbo') || name.contains('prime') || name.contains('tv')) video++;
      else if (name.contains('spotify') || name.contains('music') || name.contains('deezer') || name.contains('tidal')) music++;
      else if (name.contains('xbox') || name.contains('psn') || name.contains('steam') || name.contains('game')) game++;
      else if (name.contains('adobe') || name.contains('office') || name.contains('linkedin') || name.contains('cloud')) work++;
    }

    if (video > music && video > game && video > work) return {"title": "The Binge Watcher 🍿", "desc": "Just one more episode, right?"};
    if (music > video && music > game && music > work) return {"title": "The Audiophile 🎧", "desc": "Life needs a background score."};
    if (game > video && game > music && game > work) return {"title": "The Gamer 🎮", "desc": "Sleep is for the weak. Level up!"};
    if (work > video && work > music && work > game) return {"title": "The Hustler 💼", "desc": "Productivity is your middle name."};

    return {"title": "The Subscriber ⭐", "desc": "You have a balanced digital life."};
  }

  @override
  Widget build(BuildContext context) {
    final subBox = Hive.box('subscriptionsBox');
    final settingsBox = Hive.box('settingsBox');

    return Scaffold(
      appBar: AppBar(
        title: Text("Spending Analysis", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), 
        centerTitle: true
      ),
      body: ValueListenableBuilder(
        valueListenable: subBox.listenable(),
        builder: (context, box, _) {
          return ValueListenableBuilder(
             valueListenable: settingsBox.listenable(),
             builder: (context, settings, _) {
                String currency = settings.get('currency', defaultValue: '\$');

                if (box.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pie_chart_outline_rounded, size: 100, color: Colors.grey.withOpacity(0.2)),
                        const SizedBox(height: 20),
                        Text("Add data to see magic", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                      ],
                    ),
                  );
                }

                Map<String, double> dataMap = {};
                double totalMonthly = 0;

                for (var item in box.values.cast<Subscription>()) {
                  double monthlyPrice = item.period == 'Yearly' ? item.price / 12 : item.price;
                  totalMonthly += monthlyPrice;

                  if (dataMap.containsKey(item.name)) {
                    dataMap[item.name] = dataMap[item.name]! + monthlyPrice;
                  } else {
                    dataMap[item.name] = monthlyPrice;
                  }
                }

                // Kişilik Analizini Hesapla
                var persona = getPersona(dataMap, totalMonthly);

                List<PieChartSectionData> sections = dataMap.entries.map((e) {
                  final percentage = (e.value / totalMonthly) * 100;
                  return PieChartSectionData(
                    color: getSmartColor(e.key),
                    value: e.value,
                    title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    badgeWidget: percentage > 10 
                      ? Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Text(e.key[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: getSmartColor(e.key))),
                        )
                      : null,
                    badgePositionPercentageOffset: .98,
                  );
                }).toList();

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // KİŞİLİK KARTI (SURPRISE FEATURE)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF4A00E0).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("YOUR SUBSCRIPTION PERSONA", 
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(persona['title']!, 
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(persona['desc']!, 
                            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),

                    SizedBox(
                      height: 250,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sections: sections,
                              centerSpaceRadius: 60,
                              sectionsSpace: 3,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("MONTHLY", style: TextStyle(fontSize: 10, color: Colors.grey[500], letterSpacing: 2)),
                              Text(
                                "${totalMonthly.toStringAsFixed(0)}$currency",
                                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Column(
                      children: dataMap.entries.map((e) {
                         double percentage = (e.value / totalMonthly);
                         return Container(
                           margin: const EdgeInsets.only(bottom: 15),
                           child: Row(
                              children: [
                                Container(
                                  width: 15, height: 15,
                                  decoration: BoxDecoration(color: getSmartColor(e.key), shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 5),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: LinearProgressIndicator(
                                          value: percentage,
                                          minHeight: 6,
                                          backgroundColor: Colors.grey[200],
                                          color: getSmartColor(e.key),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Text("${e.value.toStringAsFixed(2)} $currency", style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                         );
                      }).toList(),
                    ),
                  ],
                );
             }
          );
        },
      ),
    );
  }
}