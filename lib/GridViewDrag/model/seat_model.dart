import 'package:drag_drop/GridViewDrag/model/coordinate_model.dart';
import 'package:equatable/equatable.dart';

class SeatModel extends Equatable {
  final String name;
  final bool isWindowSeat;
  final bool isFoldingSeat;
  final bool isReadingLights;
  final double height;
  final double width;
  final int heightInch;
  final int widthInch;
  final CoordinateModel coordinate;

  const SeatModel({
    required this.name,
    required this.isWindowSeat,
    required this.isFoldingSeat,
    required this.isReadingLights,
    required this.height,
    required this.width,
    required this.heightInch,
    required this.widthInch,
    required this.coordinate,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) => SeatModel(
        name: json["name"] as String,
        isWindowSeat: json["isWindowSeat"] as bool,
        isFoldingSeat: json["isFoldingSeat"] as bool,
        isReadingLights: json["isReadingLights"] as bool,
        height: json["height"] as double,
        width: json["width"] as double,
        heightInch: json["heightInch"] as int,
        widthInch: json["widthInch"] as int,
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
        "heightInch": heightInch,
        "widthInch": widthInch,
        "coordinate": coordinate.toJson(),
      };

  @override
  List<Object?> get props => [
        name,
        isWindowSeat,
        isFoldingSeat,
        isReadingLights,
        height,
        width,
        heightInch,
        widthInch,
        coordinate,
      ];

  @override
  String toString() {
    return "SeatModel(name: $name, isWindowSeat: $isWindowSeat, isFoldingSeat: $isFoldingSeat, isReadingLights: $isReadingLights, coordinate: ${coordinate.toString()})";
  }
}
