import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  Loading(this.reason);

  final String reason;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Text(
                reason == null ? "" : reason,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
