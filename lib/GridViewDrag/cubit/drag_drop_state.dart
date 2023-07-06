part of 'drag_drop_cubit.dart';

abstract class DragDropState extends Equatable {
  const DragDropState();

  @override
  List<Object?> get props => [];
}

class DragDropInitial extends DragDropState {}

class DragDrop extends DragDropState {
  final bool updateState;
  final ScrollController sController;
  final int crossAxisCount;
  final int mainAxisCount;
  final int gridGap;
  final double gridHeight;
  final double seatTypeH;
  final double buttonH;
  final double paddingH;
  final double gridTM;
  final double gridBM;
  final int angle;
  final List<SeatTypeModel> sTypes;
  final List<SectionModel> sections;
  final List<SeatModel> seats;
  final List<SeatModel> wheels;
  final List<SeatModel> doors;
  final double vWidth;

  const DragDrop({
    required this.updateState,
    required this.sController,
    required this.crossAxisCount,
    required this.mainAxisCount,
    required this.gridGap,
    required this.vWidth,
    required this.gridHeight,
    required this.seatTypeH,
    required this.buttonH,
    required this.paddingH,
    required this.gridTM,
    required this.gridBM,
    required this.angle,
    required this.sTypes,
    required this.sections,
    required this.seats,
    required this.wheels,
    required this.doors,
  });

  @override
  List<Object?> get props => [
        updateState,
        mainAxisCount,
        angle,
        sections,
        seats,
        wheels,
        doors,
      ];
}
