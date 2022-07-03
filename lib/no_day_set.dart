import 'package:flutter/material.dart';

class NoDaySet extends StatefulWidget {
  const NoDaySet({Key? key}) : super(key: key);

  @override
  State<NoDaySet> createState() => _NoDaySetState();
}

class _NoDaySetState extends State<NoDaySet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.png"),
          ),
        ),
      ),
    );
  }
}
