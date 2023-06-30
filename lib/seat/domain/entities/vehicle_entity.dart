import 'package:drag_drop/seat/domain/entities/media_entity.dart';
import 'package:drag_drop/seat/domain/entities/profile_entity.dart';
import 'package:drag_drop/seat/domain/entities/seat_entity.dart';
import 'package:drag_drop/seat/domain/entities/staff_entity.dart';
import 'package:equatable/equatable.dart';

class VehicleEntity extends Equatable {
  final String type;
  final String org;
  final List<String> categories;
  final String band;
  final String model;
  final List<String> facilities;
  final String makeYear;
  final String purchasedYear;
  final String name;
  final String numberPlate;
  final String color;
  final ProfileEntity profile;
  final List<StaffEntity> staff;
  final List<SeatEntity> seats;
  final List<MediaEntity> videos;
  final String route;
  final bool isActive;
  final String refundablePolicy;
  final List<String> policies;

  const VehicleEntity({
    required this.type,
    required this.org,
    required this.categories,
    required this.band,
    required this.model,
    required this.facilities,
    required this.makeYear,
    required this.purchasedYear,
    required this.name,
    required this.numberPlate,
    required this.color,
    required this.profile,
    required this.staff,
    required this.seats,
    required this.videos,
    required this.route,
    required this.isActive,
    required this.refundablePolicy,
    required this.policies,
  });

  @override
  List<Object?> get props => [
        type,
        org,
        categories,
        band,
        model,
        facilities,
        makeYear,
        purchasedYear,
        name,
        numberPlate,
        color,
        profile,
        staff,
        seats,
        videos,
        route,
        isActive,
        refundablePolicy,
        policies,
      ];
}
