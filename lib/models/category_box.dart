import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryBoxModel extends StatefulWidget {
  final List<List<dynamic>> categories;
  const CategoryBoxModel({
    super.key,
    required this.categories,
  });

  @override
  State<CategoryBoxModel> createState() => _CategoryBoxModelState();
}

class _CategoryBoxModelState extends State<CategoryBoxModel> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: widget.categories.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (context, index) {
        return CategoryBox(
          category: widget.categories[index][0],
          categoryIcon: widget.categories[index][1],
        );
      },
    );
  }
}

class CategoryBox extends StatefulWidget {
  const CategoryBox({
    super.key,
    required this.category,
    required this.categoryIcon,
  });

  final String category;
  final IconData categoryIcon;

  static List<String>? categoryList;

  @override
  State<CategoryBox> createState() => _CategoryBoxState();
}

class _CategoryBoxState extends State<CategoryBox> {
  bool isSelected = false;
  late final SharedPreferences pref;
  Future initPref() async {
    pref = await SharedPreferences.getInstance();
    CategoryBox.categoryList = pref.getStringList('categoryList');
    if (CategoryBox.categoryList == null) {
      await pref.setStringList('categoryList', []);
      CategoryBox.categoryList = pref.getStringList("categoryList");
    }
    if (CategoryBox.categoryList!.contains(widget.category)) {
      isSelected = true;
      setState(() {});
    }
  }

  @override
  void initState() {
    initPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          setState(() {
            isSelected = false;
            CategoryBox.categoryList!.remove(widget.category);
            pref.setStringList('categoryList', CategoryBox.categoryList!);
          });
        } else {
          setState(() {
            isSelected = true;
            CategoryBox.categoryList!.add(widget.category);
            pref.setStringList('categoryList', CategoryBox.categoryList!);
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        child: Container(
          decoration: BoxDecoration(
              color: isSelected ? Colors.grey[700] : Colors.grey[100],
              border: Border.all(color: Colors.black)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    widget.categoryIcon,
                    size: 40,
                  ),
                  Text(
                    widget.category,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
