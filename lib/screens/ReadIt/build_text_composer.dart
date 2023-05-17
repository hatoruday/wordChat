import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class BuildTextComposer extends StatefulWidget {
  final Function createChats, createBlock;
  final TextEditingController controller;
  const BuildTextComposer(
      {super.key,
      required this.isGenerating,
      required this.createChats,
      required this.createBlock,
      required this.controller});
  final bool isGenerating;
  @override
  State<BuildTextComposer> createState() => _BuildTextComposerState();
}

class _BuildTextComposerState extends State<BuildTextComposer> {
  late bool insideBuffering;

  @override
  Widget build(BuildContext context) {
    insideBuffering = widget.isGenerating;
    return insideBuffering
        ? Row(
            children: const [
              Expanded(
                  child: Center(
                      child: CircularProgressIndicator(
                color: Colors.white,
              )))
            ],
          )
        : Row(children: [
            Expanded(
              child: TextField(
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                controller: widget.controller,
                onSubmitted: (value) => widget.createChats(),
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide:
                            BorderSide(color: Colors.grey.shade700, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide:
                            BorderSide(color: Colors.grey.shade700, width: 2)),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                    //filled: true,
                    //fillColor: Colors.black,
                    hintText: "Send a Message",
                    hintStyle: const TextStyle(
                      color: Colors.white,
                    )),
                minLines: 1,
                maxLines: 3,
              ),
            ),
            IconButton(
                onPressed: () => widget.createChats(),
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () => widget.createBlock(),
                icon: const Icon(
                  Icons.ad_units,
                  color: Colors.white,
                )),
          ]).px12();
  }
}
