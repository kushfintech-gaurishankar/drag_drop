import 'package:drag_drop/GridViewDrag/model/coordinate_model.dart';
import 'package:equatable/equatable.dart';

class SeatModel extends Equatable {
  final int id;
  final String name;
  final String icon;
  final bool isWindowSeat;
  final bool isFoldingSeat;
  final bool isReadingLights;
  final double height;
  final double width;
  final int heightInch;
  final int widthInch;
  final CoordinateModel coordinate;

  const SeatModel({
    required this.id,
    required this.name,
    required this.icon,
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
        id: json["id"] as int,
        name: json["name"] as String,
        icon: json["icon"] as String,
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
        "id": id,
        "name": name,
        "icon": icon,
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
        id,
        name,
        icon,
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
    return "SeatModel(id: $id,, name: $name, icon: $icon, isWindowSeat: $isWindowSeat, isFoldingSeat: $isFoldingSeat, isReadingLights: $isReadingLights, coordinate: ${coordinate.toString()})";
  }
}
