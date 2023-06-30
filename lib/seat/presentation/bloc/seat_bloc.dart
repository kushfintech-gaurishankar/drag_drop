import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'seat_event.dart';
part 'seat_state.dart';

class SeatBloc extends Bloc<SeatEvent, SeatState> {
  SeatBloc() : super(SeatInitial()) {
    on<SeatEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
