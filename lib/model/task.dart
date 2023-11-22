

// abstract class Task {
//   String name;
//   Task(this.name);
//
//   fromMap
//
//   factory Task.createMap({required String name,bool guardDog=false}){
//     if(guardDog){
//       return DeadlineTask(name);
//     }
//     else{
//       return DeadlineTask(name);
//     }
//   }
//   // Map<String, dynamic> toMap();
//   // CourseTask fromMap(Map<dynamic, dynamic> map);
//   // DeadlineTask fromMap(Map<dynamic, dynamic> map);
//   //fromMap(Map<dynamic, dynamic> map); //{return UnimplementedError()};
// }

class DeadlineTask {
  final String name;
  final DateTime dueDate;
  final String description;
  final int priority;
  final String status;

  DeadlineTask({
    required this.name,
    required this.dueDate,
    required this.description,
    required this.priority,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dueDate': dueDate,
      'description': description,
      'priority': priority,
      'status': status,
    };
  }

  static DeadlineTask fromMap(Map<dynamic, dynamic> map) {
    return DeadlineTask(
      name: map['description'] ?? '',
      dueDate: map['dueDate'].toDate() ?? DateTime.now(),
      description: map['description'] ?? '',
      priority: map['priority'] ?? 1,
      status: map['status'] ?? '',
    );
  }
}

class CourseTask {
  final String id;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final String description;

  CourseTask({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'description': description,
    };
  }

  static CourseTask fromMap(Map<dynamic, dynamic> map) {
    return CourseTask(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      startTime: map['startTime'].toDate() ?? DateTime.now(),
      endTime: map['endTime'].toDate() ?? DateTime.now(),
      description: map['description'] ?? '',
    );
  }
}