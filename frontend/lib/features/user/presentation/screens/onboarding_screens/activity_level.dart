import 'package:flutter/material.dart';

class ActivityLevel extends StatelessWidget {
  const ActivityLevel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('What is your activity level?'),
              SizedBox(height: 20),
              _activityCard(
                title: 'Mostly Setendary',
                text: 'In many cases that corresponds to less than 5,000 steps a day',
              ),
              SizedBox(height: 15),
              _activityCard(
                title: 'Moderately Active',
                text: 'In many cases that would correspond to 5,000 - 15,000 steps a day',
              ),
              SizedBox(height: 15),
              _activityCard(
                title: 'Very Active',
                text: 'In many cases that would correspond to more than 15,000 steps a day',
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class _activityCard extends StatefulWidget {
  String? title;
  String? text;
  _activityCard({this.title, this.text});

  @override
  State<_activityCard> createState() => _activityCardState();
}

class _activityCardState extends State<_activityCard> {
  bool _isActive = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: BoxBorder.all(color: Colors.grey, width: 1.5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell(
        onTap: () {
          setState(() => _isActive = !_isActive);
          print('tapped');
        },
        onLongPress: () {},
        child: ListTile(
          title: Text(widget.title ?? '', style: TextStyle(fontSize: 18)),
          subtitle: Text(widget.text ?? ''),
        ),
      ),
    );
  }
}
