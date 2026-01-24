import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Subscription extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double price;

  @HiveField(2)
  DateTime renewalDate;

  @HiveField(3)
  String period;

  Subscription(this.name, this.price, this.renewalDate, this.period);
}

class SubscriptionAdapter extends TypeAdapter<Subscription> {
  @override
  final int typeId = 0;

  @override
  Subscription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subscription(
      fields[0] as String,
      fields[1] as double,
      fields[2] as DateTime,
      fields[3] as String? ?? 'Monthly',
    );
  }

  @override
  void write(BinaryWriter writer, Subscription obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.price)
      ..writeByte(2)
      ..write(obj.renewalDate)
      ..writeByte(3)
      ..write(obj.period);
  }
}