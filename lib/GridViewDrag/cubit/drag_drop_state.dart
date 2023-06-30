part of 'drag_drop_cubit.dart';

abstract class DragDropState extends Equatable {
  const DragDropState();

  @override
  List<Object?> get props => [];
}

class DragDropInitial extends DragDropState {}

class DragDrop extends DragDropState {
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
  final List<SeatTypeModel> sTypes;
  final List<SeatModel> seats;
  final double vWidth;

  const DragDrop({
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
    required this.sTypes,
    required this.seats,
  });

  @override
  List<Object?> get props => [
        mainAxisCount,
        seats,
      ];
}
