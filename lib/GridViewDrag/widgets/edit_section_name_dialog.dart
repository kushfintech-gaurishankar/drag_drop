import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/drag_drop_cubit.dart';

editSectionName({
  required BuildContext context,
  required int sectionIndex,
  required String name,
}) {
  TextEditingController nameC = TextEditingController();
  nameC.text = name;

  showDialog(
    context: context,
    builder: (context2) {
      return AlertDialog(
        scrollable: true,
        titlePadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Name"),
            const SizedBox(height: 5),
            TextFormField(
              keyboardType: TextInputType.name,
              controller: nameC,
              decoration: const InputDecoration(
                isDense: true,
                hintText: "Enter the section name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (name != nameC.text) {
                    BlocProvider.of<DragDropCubit>(context).editSectionName(
                      sectionIndex: sectionIndex,
                      newName: nameC.text,
                    );
                  }
                },
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      );
    },
  );
}
