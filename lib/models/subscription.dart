import 'package:hive/hive.dart';

// This links the generated code to this file.
// It will show an error until we run the build_runner.
part 'subscription.g.dart'; 

@HiveType(typeId: 1) // Unique ID for this object type
class Subscription {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double price;

  @HiveField(2)
  final DateTime renewalDate;

  Subscription(this.name, this.price, this.renewalDate);
}