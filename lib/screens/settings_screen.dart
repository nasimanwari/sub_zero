import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settingsBox');

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Preferences & Controls",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: settingsBox.listenable(),
              builder: (context, box, _) {
                String currentCurrency = box.get('currency', defaultValue: '\$');
                bool notificationsEnabled = box.get('notifications', defaultValue: true);
                bool isDarkMode = box.get('darkMode', defaultValue: false);

                Color cardColor = Theme.of(context).cardColor;

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      "Currency",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Column(
                      children: [
                        _buildCurrencyOption(context, box, "Dollar", "\$", Icons.attach_money, currentCurrency),
                        const SizedBox(height: 10),
                        _buildCurrencyOption(context, box, "Euro", "€", Icons.euro, currentCurrency),
                        const SizedBox(height: 10),
                        _buildCurrencyOption(context, box, "Turkish Lira", "₺", Icons.currency_lira, currentCurrency),
                        const SizedBox(height: 10),
                        _buildCurrencyOption(context, box, "Pound", "£", Icons.currency_pound, currentCurrency),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "General",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                           BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: const Text("Receive renewal alerts"),
                            secondary: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications, color: Colors.orange),
                            ),
                            value: notificationsEnabled,
                            onChanged: (val) {
                              box.put('notifications', val);
                            },
                            activeColor: const Color(0xFF0072FF),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            title: const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: const Text("Switch theme"),
                            secondary: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.dark_mode, color: Colors.purple),
                            ),
                            value: isDarkMode,
                            onChanged: (val) {
                              box.put('darkMode', val);
                            },
                            activeColor: Colors.purple,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyOption(BuildContext context, Box box, String label, String symbol, IconData icon, String currentSelection) {
    bool isSelected = currentSelection == symbol;
    Color bgColor = Theme.of(context).cardColor;
    Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return GestureDetector(
      onTap: () => box.put('currency', symbol),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0072FF).withOpacity(0.05) : bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF0072FF) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0072FF) : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF0072FF) : textColor,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF0072FF)),
          ],
        ),
      ),
    );
  }
}