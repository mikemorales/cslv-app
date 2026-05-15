import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

class HtmlEditorScreen extends StatefulWidget {
  final String title;
  final String initialText;
  final String hint;

  const HtmlEditorScreen({
    super.key,
    required this.title,
    required this.initialText,
    required this.hint,
  });

  @override
  State<HtmlEditorScreen> createState() => _HtmlEditorScreenState();
}

class _HtmlEditorScreenState extends State<HtmlEditorScreen> {
  static const _navy = Color(0xFF252B5A);
  static const _gold = Color(0xFFB39123);

  late final QuillController _controller;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: _documentFromHtml(widget.initialText),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _focusNode = FocusNode();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: GoogleFonts.notoSerif(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              'Save',
              style: GoogleFonts.raleway(
                color: _gold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _gold.withValues(alpha: 0.8)),
                ),
                child: QuillSimpleToolbar(
                  controller: _controller,
                  config: QuillSimpleToolbarConfig(
                    color: Colors.white,
                    multiRowsDisplay: true,
                    showDividers: false,
                    toolbarSectionSpacing: 10,
                    showFontFamily: false,
                    showFontSize: false,
                    showBackgroundColorButton: false,
                    showColorButton: false,
                    showSearchButton: false,
                    showSubscript: false,
                    showSuperscript: false,
                    showInlineCode: false,
                    showDirection: false,
                    showAlignmentButtons: false,
                    showClearFormat: true,
                    showUndo: true,
                    showRedo: true,
                    showCodeBlock: true,
                    showQuote: true,
                    showLink: true,
                    showListBullets: true,
                    showListNumbers: true,
                    showListCheck: false,
                    showHeaderStyle: true,
                    showIndent: false,
                    iconTheme: QuillIconTheme(
                      iconButtonUnselectedData: IconButtonData(
                        color: _navy,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: _gold.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                      iconButtonSelectedData: IconButtonData(
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: _gold,
                          side: const BorderSide(color: _gold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _gold, width: 1.2),
                  ),
                  child: QuillEditor(
                    controller: _controller,
                    focusNode: _focusNode,
                    scrollController: _scrollController,
                    config: QuillEditorConfig(
                      placeholder: widget.hint,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Document _documentFromHtml(String html) {
    if (html.trim().isEmpty) {
      return Document();
    }

    final delta = HtmlToDelta().convert(html);
    if (delta.isEmpty) {
      return Document();
    }

    return Document.fromDelta(delta);
  }

  String _deltaToHtml() {
    final ops = _controller.document
        .toDelta()
        .toJson()
        .cast<Map<String, dynamic>>();
    final converter = QuillDeltaToHtmlConverter(
      ops,
      ConverterOptions(
        converterOptions: OpConverterOptions(inlineStylesFlag: true),
      ),
    );
    return converter.convert();
  }

  Future<void> _save() async {
    final plainText = _controller.document.toPlainText().trim();
    final html = plainText.isEmpty ? '' : _deltaToHtml();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(html);
  }
}
