class FireChatBlock {
  String chatBlock;
  String user;
  String date;

  FireChatBlock({
    required this.chatBlock,
    required this.user,
    required this.date,
  });

  FireChatBlock.fromJson(Map<String, dynamic> json)
      : chatBlock = json['chatBlock'],
        user = json['user'],
        date = json['date'];
  Map<String, dynamic> toJson() => {
        'chatBlock': chatBlock,
        'user': user,
        'date': date,
      };
}
