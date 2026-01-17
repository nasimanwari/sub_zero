import 'package:flutter/material.dart';
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

  final _myBox = Hive.box('subscriptionsBox');

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

  void pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Color getColor(String name) {
    String lowerName = name.toLowerCase();

    if (lowerName.contains('netflix')) {
      return Colors.red;
    } else if (lowerName.contains('spotify')) {
      return Colors.green;
    } else if (lowerName.contains('disney')) {
      return Colors.blue;
    } else if (lowerName.contains('amazon') || lowerName.contains('prime')) {
      return Colors.lightBlue;
    } else if (lowerName.contains('youtube')) {
      return Colors.redAccent;
    }

    return Colors.primaries[name.hashCode % Colors.primaries.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sub-Zero"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: _myBox.listenable(),
        builder: (context, box, widget) {
          double totalCost = box.values.cast<Subscription>().fold(
              0, (sum, item) => sum + item.price
          );

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Total Monthly Cost",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${totalCost.toStringAsFixed(2)} \$",
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: box.isEmpty
                    ? const Center(child: Text("No subscriptions yet. Add one!"))
                    : ListView.builder(
                        itemCount: box.length,
                        itemBuilder: (context, index) {
                          final subscription = box.getAt(index) as Subscription;
                          
                          String formattedDate = DateFormat('dd/MM/yyyy').format(subscription.renewalDate);

                          int daysLeft = subscription.renewalDate
                              .difference(DateTime.now())
                              .inDays;

                          return Dismissible(
                            key: UniqueKey(),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              box.deleteAt(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("${subscription.name} deleted")),
                              );
                            },
                            child: ListTile(
                              leading: Icon(
                                Icons.subscriptions_outlined,
                                color: getColor(subscription.name),
                              ),
                              title: Text(
                                subscription.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text("${subscription.price} \$  •  $formattedDate"),
                              trailing: Text(
                                daysLeft <= 0 ? "Expired" : "$daysLeft days left",
                                style: TextStyle(
                                  color: daysLeft <= 0 ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          selectedDate = null;
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: "Price"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: pickDate,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month),
                          const SizedBox(width: 8),
                          Text(
                            selectedDate == null
                                ? "Select Renewal Date"
                                : "Selected: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty ||
                            priceController.text.isEmpty) return;

                        DateTime finalDate = selectedDate ??
                            DateTime.now().add(const Duration(days: 30));

                        Subscription newSub = Subscription(
                          nameController.text,
                          double.parse(priceController.text),
                          finalDate,
                        );

                        int id = await _myBox.add(newSub);

                        await NotificationService().scheduleNotification(
                          id,
                          newSub.name,
                          newSub.renewalDate,
                        );

                        nameController.clear();
                        priceController.clear();
                        Navigator.pop(context);
                      },
                      child: const Text("Add Subscription"),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}