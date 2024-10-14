// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FontAdapter extends TypeAdapter<Font> {
  @override
  final int typeId = 1;

  @override
  Font read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Font(
      id: fields[0] as String,
      size: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Font obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.size);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FontAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
