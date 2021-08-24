class ReceivedNotification {
  final id;
  String? title;
  String? body;
  String? payload;
  ReceivedNotification(
      {required this.id,
      required this.title,
      required this.body,
      required this.payload});
}
