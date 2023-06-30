import 'package:equatable/equatable.dart';

class SeatEntity extends Equatable {
  final String title;
  final String number;
  final String status;
  final String price;
  final String description;
  final String facilities;
  final String x;
  final String y;
  final String height;
  final String width;
  final bool refundable;

  const SeatEntity({
    required this.title,
    required this.number,
    required this.status,
    required this.price,
    required this.description,
    required this.facilities,
    required this.x,
    required this.y,
    required this.height,
    required this.width,
    required this.refundable,
  });

  @override
  List<Object?> get props => [
        title,
        number,
        status,
        price,
        description,
        facilities,
        x,
        y,
        height,
        width,
        refundable,
      ];
}
