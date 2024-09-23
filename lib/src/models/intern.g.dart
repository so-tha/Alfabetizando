// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intern.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardsInternosAdapter extends TypeAdapter<CardsInternos> {
  @override
  final int typeId = 0;

  @override
  CardsInternos read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardsInternos(
      id: fields[0] as int,
      name: fields[1] as String,
      imageUrl: fields[2] as String,
      soundUrl: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CardsInternos obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.soundUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardsInternosAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
