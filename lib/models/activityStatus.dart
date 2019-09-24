class ActivityStatus {
  int _activityStatusId;
  int _activityId;
  double _activityValue;
  DateTime _date;

  DateTime get date => _date;
  set date(DateTime date) => _date = date;

  double get activityValue => _activityValue;
  set activityValue(double activityValue) => _activityValue = activityValue;

  int get activityId => _activityId;
  set activityId(int activityId) => _activityId = activityId;

  int get activityStatusId => _activityStatusId;
  set activityStatusId(int activityStatusId) =>
      _activityStatusId = activityStatusId;

  ActivityStatus(this._activityId, this._activityValue, this._date);

  ActivityStatus.withId(this._activityStatusId, this._activityId,
      this._activityValue, this._date);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['activityStatusId'] = _activityStatusId;
    map['activityId'] = _activityId;
    map['activityValue'] = _activityValue;
    map['date'] = _date;
    return map;
  }

  ActivityStatus.fromMap(Map<String, dynamic> map) {
    this._activityStatusId = map['activityStatusId'];
    this._activityId = map['activityId'];
    this._activityValue = (map['activityValue'] as double);
    this._date = (map['date'] as DateTime);
  }
}
