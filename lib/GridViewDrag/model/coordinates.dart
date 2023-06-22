import 'package:equatable/equatable.dart';

class CoordinateModel extends Equatable {
  final double dx;
  final double dy;

 const CoordinateModel({
    required this.dx,
    required this.dy,
  });

  @override
  List<Object?> get props => [dx, dy];

  @override
  String toString() {
    return "{$dx, $dy}";
  }
}
