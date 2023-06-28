import 'package:drag_drop/GridViewDrag/model/coordinate_model.dart';
import 'package:equatable/equatable.dart';

class SeatModel extends Equatable {
  final String name;
  final bool isWindowSeat;
  final bool isFoldingSeat;
  final bool isReadingLights;
  final double height;
  final double width;
  final CoordinateModel coordinate;

  const SeatModel({
    required this.name,
    required this.isWindowSeat,
    required this.isFoldingSeat,
    required this.isReadingLights,
    required this.height,
    required this.width,
    required this.coordinate,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) => SeatModel(
        name: json["name"] as String,
        isWindowSeat: json["isWindowSeat"] as bool,
        isFoldingSeat: json["isFoldingSeat"] as bool,
        isReadingLights: json["isReadingLights"] as bool,
        height: json["height"] as double,
        width: json["width"] as double,
        coordinate: CoordinateModel.fromJson(
            json["coordinate"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "isWindowSeat": isWindowSeat,
        "isFoldingSeat": isFoldingSeat,
        "isReadingLights": isReadingLights,
        "height": height,
        "width": width,
        "coordinate": coordinate.toJson(),
      };

  @override
  List<Object?> get props => [
        name,
        isWindowSeat,
        isFoldingSeat,
        isReadingLights,
        coordinate,
      ];

  @override
  String toString() {
    return "SeatModel(name: $name, coordinate: ${coordinate.toString()})";
  }
}
