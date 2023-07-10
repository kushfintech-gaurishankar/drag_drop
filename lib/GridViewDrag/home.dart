import 'package:drag_drop/GridViewDrag/cubit/drag_drop_cubit.dart';
import 'package:drag_drop/GridViewDrag/widgets/add_section_dialog.dart';
import 'package:drag_drop/GridViewDrag/widgets/buttons.dart';
import 'package:drag_drop/GridViewDrag/widgets/grid_container.dart';
import 'package:drag_drop/GridViewDrag/widgets/seat_type_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (builder) => DragDropCubit(context)..loadData(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F4F7),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: const Color(0xFFF2F4F7),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          actions: [
            Builder(builder: (context) {
              return IconButton(
                onPressed: () =>
                    BlocProvider.of<DragDropCubit>(context)..clearData(),
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.black,
                ),
              );
            }),
          ],
        ),
        body: BlocBuilder<DragDropCubit, DragDropState>(
          builder: (context, state) {
            if (state is DragDrop) {
              return Column(
                children: [
                  SeatTypeContainer(
                    crossAxisCount: state.crossAxisCount,
                    paddingH: state.paddingH,
                    gridGap: state.gridGap,
                    vWidth: state.vWidth,
                    height: state.seatTypeH,
                    angle: state.angle,
                    sTypes: state.sTypes,
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    height: state.gridHeight + state.gridTM,
                    child: SingleChildScrollView(
                      controller: state.sController,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GridContainer(
                            sController: state.sController,
                            gridTM: state.gridTM,
                            paddingH: state.paddingH,
                            gridGap: state.gridGap,
                            crossAxisCount: state.crossAxisCount,
                            mainAxisCount: state.mainAxisCount,
                            angle: state.angle,
                            sections: state.sections,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: InkWell(
                              onTap: () => addSection(context),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    "Add Section",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: state.gridBM / 2),
                    child: GridButtons(height: state.buttonH),
                  ),
                ],
              );
            }

            return Container();
          },
        ),
      ),
    );
  }
}
