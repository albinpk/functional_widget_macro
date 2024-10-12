import 'package:flutter/material.dart';
import 'package:functional_widget_macro/functional_widget_macro.dart';

void main() {
  runApp(
    const Column(
      children: [
        Header(),
        // UserCard('John Doe'),
        // Footer(color: Colors.green),
      ],
    ),
  );
}

@FunctionalWidget()
Widget _header() => const Text("User Details");

// @FunctionalWidget()
// Widget _userCard(String name) => Center(child: Text(name));

// @FunctionalWidget()
// Widget _footer(BuildContext context, {Color? color}) {
//   return Container(
//     color: color ?? Theme.of(context).primaryColor,
//     child: const Icon(Icons.arrow_downward_rounded),
//   );
// }
