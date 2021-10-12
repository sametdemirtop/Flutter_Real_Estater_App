import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

circularProgress<Widget>() {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
    ),
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 12.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.white),
    ),
  );
}

linearProgress() {
  return Container(
    color: Colors.white,
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 12.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.cyan),
    ),
  );
}
