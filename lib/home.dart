import 'package:flutter/material.dart';

import 'tape.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfff9bf44),
      child: Center(
        child: Tape()
      ),
    );
  }

}