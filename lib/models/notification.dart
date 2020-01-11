class NotificationModel {
  int _notificationId;
  String _notificationBody;
  int _notificationHour;
  int _notificationMinute;
  bool _isActive;

  bool get isActive => _isActive;
  set isActive(bool isActive) => _isActive = isActive;

  int get notificationId => _notificationId;
  set notificationId(int notificationId) => _notificationId = notificationId;

  String get notificationBody => _notificationBody;
  set notificationBody(String notificationBody) =>
      _notificationBody = notificationBody;

  int get notificationHour => _notificationHour;
  set notificationTime(int notificationHour) =>
      _notificationHour = notificationHour;

  int get notificationMinute => _notificationMinute;
  set notificationMinute(int notificationMinute) =>
      _notificationMinute = notificationMinute;

  NotificationModel.fromMap(Map<String, dynamic> map) {
    this._notificationId = map['notificationId'];
    this._notificationBody = map['notificationBody'];
    this._notificationHour = map['notificationHour'];
    this.notificationMinute = map['notificationMinute'];
    this._isActive = map['isActive'] == 0 ? false : true;
  }
}
