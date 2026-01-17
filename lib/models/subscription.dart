import 'package:hive/hive.dart';

part 'subscription.g.dart'; 

@HiveType(typeId: 1)
class Subscription {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double price;

  @HiveField(2)
  final DateTime renewalDate;

  Subscription(this.name, this.price, this.renewalDate);
}