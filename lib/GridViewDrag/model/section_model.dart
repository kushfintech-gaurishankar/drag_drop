import 'package:drag_drop/GridViewDrag/model/seat_model.dart';

class SectionModel {
  String name;
  int mainAxisCount;
  double height;
  List<SeatModel> seats;
  List<SeatModel> wheels;
  List<SeatModel> doors;

  SectionModel({
    required this.name,
    required this.mainAxisCount,
    required this.height,
    required this.seats,
    required this.wheels,
    required this.doors,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) => SectionModel(
        name: json["name"] as String,
        mainAxisCount: json["mainAxisCount"] as int,
        height: json["height"] as double,
        seats:
            (json["seats"] as List).map((e) => SeatModel.fromJson(e)).toList(),
        wheels: (json["wheels"] as List)
            .map((e) => SeatModel.fromJson(json))
            .toList(),
        doors: (json["doors"] as List)
            .map((e) => SeatModel.fromJson(json))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "mainAxisCount": mainAxisCount,
        "height": height,
        "seats": seats.map((e) => e.toJson()).toList(),
        "wheels": wheels.map((e) => e.toJson()).toList(),
        "doors": doors.map((e) => e.toJson()).toList(),
      };
}
