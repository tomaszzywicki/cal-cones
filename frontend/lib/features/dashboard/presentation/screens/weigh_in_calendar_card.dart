import 'package:flutter/material.dart';

class WeighInCalendarCard extends StatelessWidget {
  const WeighInCalendarCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<int> weighInData = List.generate(24, (index) => index % 5 < 3 ? 1 : 0)
      ..addAll(List.filled(4, -1));

    return Card(
      child: Padding(
        padding: const EdgeInsetsGeometry.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Your Weigh-Ins", style: Theme.of(context).textTheme.titleSmall),
            GridView.count(
              crossAxisCount: 7,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 10.0,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 10 / 8,
              children: _generateDayTiles(weighInData),
            ),
          ],
        ),
      ),
    );
  }
}

_generateDayTiles(List<int> data) {
  return List<Widget>.generate(data.length, (index) {
    final dayStatus = data[index];
    Color bgColor;

    if (dayStatus == 1) {
      bgColor = Colors.green;
    } else if (dayStatus == 0) {
      bgColor = Colors.red;
    } else {
      bgColor = Colors.grey.shade300;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
        border: Border.all(color: Colors.black12, width: 2.0),
        // color: Colors.black12,
        // borderRadius: BorderRadius.all(Radius.circular(2.0)),
        // border: Border.all(color: bgColor, width: 2.0),
      ),
    );

    // return Card(
    //   color: bgColor,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(2.0),
    //     side: BorderSide(color: Colors.black12, width: 1.5),
    //   ),
    // );
  });
}

// class _DayTile
