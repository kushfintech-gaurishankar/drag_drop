part of 'drag_drop_cubit.dart';

abstract class DragDropState extends Equatable {
  const DragDropState();

  @override
  List<Object?> get props => [];
}

class DragDropInitial extends DragDropState {}

class DragDrop extends DragDropState {
  final double cHeight;
  final double cWidth;
  final double sCHeight;
  final int gridGap;
  final double pdAll;
  final double pdBottom;
  final int gridLength;
  final List<String> seatTypes;
  final List<SeatModel> seats;

  const DragDrop({
    required this.cHeight,
    required this.cWidth,
    required this.sCHeight,
    required this.gridGap,
    required this.pdAll,
    required this.pdBottom,
    required this.gridLength,
    required this.seatTypes,
    required this.seats,
  });

  @override
  List<Object?> get props => [
        seats,
      ];
}
