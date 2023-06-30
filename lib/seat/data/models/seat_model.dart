import 'package:drag_drop/seat/domain/entities/seat_entity.dart';

class SeatModel extends SeatEntity {
 const SeatModel({
    required super.title,
    required super.number,
    required super.status,
    required super.price,
    required super.description,
    required super.facilities,
    required super.x,
    required super.y,
    required super.height,
    required super.width,
    required super.refundable,
  });
}
