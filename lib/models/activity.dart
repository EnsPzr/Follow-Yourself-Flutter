class Activity {
  int _activityId;
  String _activityName;
  DateTime _activityRegisterDate = DateTime.now();
  bool _isActive = true;

  bool get isActive => _isActive;
  set isActive(bool isActive) => _isActive = isActive;

  DateTime get activityRegisterDate => _activityRegisterDate;
  set activityRegisterDate(DateTime activityRegisterDate) =>
      _activityRegisterDate = activityRegisterDate;

  int get activityId => _activityId;
  set activityId(int activityId) => _activityId = activityId;

  String get activityName => _activityName;
  set activityName(String activityName) => _activityName = activityName;

  Activity(this._activityName, this._isActive);

  Activity.withId(this._activityId, this._activityName, this._isActive);
  Activity.withIdAndWithDate(this._activityId, this._activityName,
      this._isActive, this._activityRegisterDate);
  Activity.withDate(this._activityName,
      this._isActive, this._activityRegisterDate);
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['activityId'] = _activityId;
    map['activityName'] = _activityName;
    map['activityRegisterDate'] = _activityRegisterDate.toIso8601String() ??
        DateTime.now().toIso8601String();
    map['isActive'] = _isActive ?? true;
    return map;
  }

  Activity.fromMap(Map<String, dynamic> map) {
    this._activityId = map['activityId'];
    this._activityName = map['activityName'];
    this._activityRegisterDate = DateTime.parse(map['activityRegisterDate']);
    this._isActive = map['isActive'] == 0 ? false : true;
  }
}
