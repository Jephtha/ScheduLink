import 'package:flutter/material.dart';

class Course {
  String name;
  int section;
  String description;
  String location;
  List<List<int>> classSections;
  Color color;

  Course(this.name, this.section, this.description, this.location, this.classSections, this.color);
}