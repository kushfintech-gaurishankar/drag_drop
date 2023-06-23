import 'package:drag_drop/GridViewDrag/model/coordinate_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';


@JsonSerializable(explicitToJson: true)
class SeatModel extends Equatable {
  final String name;
  final CoordinateModel coordinate;

  const SeatModel({
    required this.name,
    required this.coordinate,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) => SeatModel(
        name: json["name"] as String,
        coordinate: CoordinateModel.fromJson(
            json["coordinate"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "coordinate": coordinate.toJson(),
      };

  @override
  List<Object?> get props => [name, coordinate];

  @override
  String toString() {
    return "SeatModel(name: $name, coordinate: ${coordinate.toString()})";
  }
}
