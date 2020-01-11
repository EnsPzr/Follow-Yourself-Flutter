class ActivityStatus {
  int _activityStatusId;
  int _activityId;
  double _activityValue;
  int _year;
  int _month;
  int _day;

  int get year => _year;
  set year(int year) {
    _year = year;
  }

  int get day => _day;
  set day(int day) {
    _day = day;
  }

  int get month => _month;
  set month(int month) {
    _month = month;
  }

  double get activityValue => _activityValue;
  set activityValue(double activityValue) => _activityValue = activityValue;

  int get activityId => _activityId;
  set activityId(int activityId) => _activityId = activityId;

  int get activityStatusId => _activityStatusId;
  set activityStatusId(int activityStatusId) =>
      _activityStatusId = activityStatusId;

  ActivityStatus(this._activityId, this._activityValue, this._year,
      this._month, this._day);

  ActivityStatus.withId(this._activityStatusId, this._activityId,
      this._activityValue, this._year, this._month, this._day);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['activityStatusId'] = _activityStatusId;
    map['activityId'] = _activityId;
    map['activityValue'] = _activityValue;
    map['year'] = _year;
    map['month'] = _month;
    map['day'] = _day;
    return map;
  }

  ActivityStatus.fromMap(Map<String, dynamic> map) {
    this._activityStatusId = map['activityStatusId'];
    this._activityId = map['activityId'];
    this._activityValue = (map['activityValue'] as double);
    this.year = (map['year']);
    this.month = map['month'];
    this.day = map['day'];
  }
}
