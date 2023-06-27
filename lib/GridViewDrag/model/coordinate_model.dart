import 'package:equatable/equatable.dart';

class CoordinateModel extends Equatable {
  final double dx;
  final double dy;

  const CoordinateModel({
    required this.dx,
    required this.dy,
  });

  factory CoordinateModel.fromJson(Map<String, dynamic> json) =>
      CoordinateModel(
        dx: json["dx"] as double,
        dy: json["dy"] as double,
      );

  Map<String, dynamic> toJson() => {
        "dx": dx,
        "dy": dy,
      };

  @override
  List<Object?> get props => [dx, dy];

  @override
  String toString() {
    return "CoordinateModel($dx, $dy)";
  }
}
