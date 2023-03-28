import 'package:flutter/material.dart';
import 'package:milchat/models/category_box.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({super.key});
  final TextEditingController _controller = TextEditingController();

  void searchCategory() {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("관심 주제 추가")),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey.shade300),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 15,
              left: 10,
              right: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 10.0, right: 5.0),
                            child: Icon(
                              Icons.search_outlined,
                              size: 30,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              onSubmitted: (value) => searchCategory(),
                              style: const TextStyle(fontSize: 28),
                              decoration: const InputDecoration.collapsed(
                                hintText: "검색",
                                fillColor: Colors.white,
                                filled: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20, bottom: 10),
                  child: Text(
                    "학문",
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const Flexible(
                  child: CategoryBoxModel(categories: [
                    ['수학', Icons.calculate],
                    ['과학', Icons.science],
                    ['역사', Icons.menu_book_sharp],
                    ['공학', Icons.flash_auto_outlined],
                    ['음악', Icons.music_note_outlined]
                  ]),
                )
              ],
            ),
          ),
        ));
  }
}
