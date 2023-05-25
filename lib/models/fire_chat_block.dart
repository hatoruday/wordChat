class FireChatBlock {
  String chatBlock;
  String user;
  String date;
  String uid;

  FireChatBlock({
    required this.chatBlock,
    required this.user,
    required this.date,
    required this.uid,
  });

  FireChatBlock.fromJson(Map<String, dynamic> json)
      : chatBlock = json['chatBlock'],
        user = json['user'],
        date = json['date'],
        uid = json['uid'];
  Map<String, dynamic> toJson() => {
        'chatBlock': chatBlock,
        'user': user,
        'date': date,
        'uid': uid,
      };
}
