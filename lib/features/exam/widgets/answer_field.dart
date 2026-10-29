import 'package:flutter/material.dart';
import 'package:ielts_simulator/app.dart';

/// Small inline text box for one completion blank, labelled with its number.
class AnswerField extends StatefulWidget {
  const AnswerField({
    required this.number,
    required this.value,
    required this.onChanged,
    this.readOnly = false,
    super.key,
  });

  final int number;
  final String value;
  final ValueChanged<String> onChanged;
  final bool readOnly;

  @override
  State<AnswerField> createState() => _AnswerFieldState();
}

class _AnswerFieldState extends State<AnswerField> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(AnswerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 150,
    child: TextField(
      controller: _controller,
      readOnly: widget.readOnly,
      onChanged: widget.onChanged,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: '${widget.number}',
        semanticCounterText: context.l10n.questionNumber(widget.number),
      ),
    ),
  );
}
