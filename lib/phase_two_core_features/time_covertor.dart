// import 'package:cloud_firestore/cloud_firestore.dart';

// DateTime timestampFromJson(dynamic timestamp) {
//   if (timestamp is Timestamp) {
//     return timestamp.toDate();
//   } else if (timestamp is String) {
//     return DateTime.parse(timestamp);
//   } else if (timestamp is DateTime) {
//     return timestamp;
//   }
//   return DateTime.now();
// }

// DateTime? nullableTimestampFromJson(dynamic timestamp) {
//   if (timestamp == null) return null;
//   if (timestamp is Timestamp) {
//     return timestamp.toDate();
//   } else if (timestamp is String) {
//     return DateTime.parse(timestamp);
//   } else if (timestamp is DateTime) {
//     return timestamp;
//   }
//   return null;
// }

// Timestamp timestampToJson(DateTime dateTime) => Timestamp.fromDate(dateTime);

// Timestamp? nullableTimestampToJson(DateTime? dateTime) =>
//     dateTime != null ? Timestamp.fromDate(dateTime) : null;

import 'package:cloud_firestore/cloud_firestore.dart';

// Non-null timestamp
DateTime timestampFromJson(dynamic timestamp) {
  if (timestamp is Timestamp) return timestamp.toDate();
  if (timestamp is String) return DateTime.parse(timestamp);
  if (timestamp is DateTime) return timestamp;
  return DateTime.now();
}

Timestamp timestampToJson(DateTime dateTime) => Timestamp.fromDate(dateTime);

// Nullable timestamp
DateTime? nullableTimestampFromJson(dynamic timestamp) {
  if (timestamp == null) return null;
  if (timestamp is Timestamp) return timestamp.toDate();
  if (timestamp is String) return DateTime.parse(timestamp);
  if (timestamp is DateTime) return timestamp;
  return null;
}

Timestamp? nullableTimestampToJson(DateTime? dateTime) =>
    dateTime != null ? Timestamp.fromDate(dateTime) : null;
