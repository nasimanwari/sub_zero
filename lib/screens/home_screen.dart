import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
import 'package:sub_zero/models/subscription.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  DateTime? selectedDate;

  // Reference to our opened box
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sub-Zero 🧊"),
        centerTitle: true,
      ),
      // 👇 MAGIC HAPPENS HERE: Watch the box for changes
      body: ValueListenableBuilder(
        valueListenable: _myBox.listenable(),
        builder: (context, box, widget) {
          
          // If box is empty, show a nice message
          if (box.isEmpty) {
            return const Center(child: Text("No subscriptions yet. Add one! ➕"));
          }

          // If box has data, show the list
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              // Get data directly from the box
              final subscription = box.getAt(index) as Subscription;
              
              int daysLeft = subscription.renewalDate.difference(DateTime.now()).inDays;

              return Dismissible(
                key: UniqueKey(),
                background: Container(color: Colors.red),
                onDismissed: (direction) {
                  // DELETE from Database 🗑️
                  box.deleteAt(index);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${subscription.name} deleted")),
                  );
                },
                child: ListTile(
                  leading: const Icon(Icons.subscriptions_outlined, color: Colors.blueAccent),
                  title: Text(subscription.name),
                  subtitle: Text("${subscription.price} \$"),
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
                                : "Selected: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty || priceController.text.isEmpty) return;

                        DateTime finalDate = selectedDate ?? DateTime.now().add(const Duration(days: 30));

                        // 1. Create Object
                        Subscription newSub = Subscription(
                          nameController.text,
                          double.parse(priceController.text),
                          finalDate,
                        );

                        // 2. ADD TO DATABASE directly 💾
                        _myBox.add(newSub); 

                        // 3. Clear & Close
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