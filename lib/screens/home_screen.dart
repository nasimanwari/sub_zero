import 'package:flutter/material.dart';
import 'package:sub_zero/models/subscription.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController nameController;
  late TextEditingController priceController;

  // ✨ YENİ: Seçilen tarihi tutacak değişken (Başlangıçta boş/null)
  DateTime? selectedDate;

  List<Subscription> subscriptions = [
    Subscription("Netflix", 9.99, DateTime(2026, 1, 19)),
    Subscription("Spotify", 4.99, DateTime(2026, 2, 3)),
    Subscription("Disney+", 19.99, DateTime(2026, 1, 25)),
  ];

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

  // ✨ YENİ: Tarih Seçme Fonksiyonu (Asenkron)
  void pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked; // Seçilen tarihi hafızaya al ve ekranı güncelle
      });
      print("Tarih seçildi: $selectedDate");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sub-Zero 🧊"),
        centerTitle: true,
      ),
   body: ListView.builder(
        itemCount: subscriptions.length,
        itemBuilder: (context, index) {
          final sub = subscriptions[index];
          int daysLeft = sub.renewalDate.difference(DateTime.now()).inDays;

          // ✨ YENİ: ListTile'ı Dismissible ile sarmaladık
          return Dismissible(
            // 1. KİMLİK KARTI: Her satıra benzersiz bir anahtar veriyoruz
            key: UniqueKey(),
            
            // 2. ARKA PLAN: Kaydırırken arkada görünecek renk (Kırmızı ve Çöp Kutusu)
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight, // Çöp kutusu sağda dursun
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            
            // 3. YÖN: Sadece sağdan sola (veya soldan sağa) kaydırılsın
            direction: DismissDirection.endToStart,

            // 4. OLAY ANI: Kullanıcı kaydırıp bitirdiğinde ne olsun?
            onDismissed: (direction) {
              setState(() {
                // Listeden veriyi siliyoruz
                subscriptions.removeAt(index);
              });

              // Kullanıcıya "Sildin" diye küçük bir bilgi verelim (SnackBar)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${sub.name} deleted")),
              );
            },

            // Burası eski kodumuzun aynısı (Görünen kısım)
            child: ListTile(
              leading: const Icon(Icons.subscriptions_outlined, color: Colors.blueAccent),
              title: Text(sub.name),
              subtitle: Text("${sub.price} \$"),
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Her açılışta tarihi sıfırlayalım ki önceki seçim kalmasın
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

                    // 🛠️ EKSİK PARÇA BURADA! 🛠️
                    // Kullanıcı buraya tıkladığında pickDate() çalışmalı.
                    ElevatedButton(
                      onPressed: pickDate,
                      // child artık sadece Text değil, bir Row (Satır) oldu 👇
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Düğme ekranı kaplamasın, yazı kadar olsun
                        children: [
                          // 1. İkonumuz burada 🗓️
                          const Icon(Icons.calendar_month),
                          
                          // İkon ile yazı arasına biraz boşluk
                          const SizedBox(width: 8), 
                          
                          // 2. Yazımız burada
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

                        // Tarih seçilmediyse varsayılan olarak 30 gün sonrasını verelim
                        DateTime finalDate = selectedDate ?? DateTime.now().add(const Duration(days: 30));

                        setState(() {
                          Subscription newSub = Subscription(
                            nameController.text,
                            double.parse(priceController.text),
                            finalDate, // Artık seçilen tarihi kullanıyoruz
                          );
                          subscriptions.add(newSub);
                          nameController.clear();
                          priceController.clear();
                          Navigator.pop(context);
                        });
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