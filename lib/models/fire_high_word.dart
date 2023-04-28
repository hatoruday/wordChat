class FireHighWord {
  String highWord;
  String wordMeaning;
  String user;
  String date;
  String level;
  String group;

  FireHighWord({
    required this.highWord,
    required this.wordMeaning,
    required this.user,
    required this.date,
    required this.level,
    required this.group,
  });

  FireHighWord.fromJson(Map<String, dynamic> json)
      : highWord = json['highWord'],
        wordMeaning = json['wordMeaning'] ?? "모르겠어요",
        user = json['user'],
        date = json['date'],
        level = json['level'] ?? "어려워요",
        group = json['group'] ?? "non-selected";
  Map<String, dynamic> toJson() => {
        'highWord': highWord,
        'user': user,
        'date': date,
        'level': level,
        'group': group,
        'wordMeaning': wordMeaning,
      };
}
