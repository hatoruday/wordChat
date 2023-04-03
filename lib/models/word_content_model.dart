class FireHighWord {
  String highWord;
  String user;
  String date;

  FireHighWord({
    required this.highWord,
    required this.user,
    required this.date,
  });

  FireHighWord.fromJson(Map<String, dynamic> json)
      : highWord = json['highWord'],
        user = json['user'],
        date = json['date'];
  Map<String, dynamic> toJson() => {
        'highWord': highWord,
        'user': user,
        'date': date,
      };
}
