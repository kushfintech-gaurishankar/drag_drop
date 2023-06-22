import 'package:drag_drop/GridViewDrag/model/coordinates.dart';
import 'package:equatable/equatable.dart';

class SeatModel extends Equatable {
  final String name;
  final CoordinateModel coordinate;

  const SeatModel({
    required this.name,
    required this.coordinate,
  });

  @override
  List<Object?> get props => [name, coordinate];

  @override
  String toString() {
    return "{name: $name, coordinate: ${coordinate.toString()}}";
  }
}
