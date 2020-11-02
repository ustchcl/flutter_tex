import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutter_tex/src/models/tex_view_widget_meta.dart';
import 'package:flutter_tex/src/utils/style_utils.dart';

class TeXViewDocument extends TeXViewWidget {
  String id;

  /// Raw String containing HTML and TEX Code e.g. r"""$$x = {-b \pm \sqrt{b^2-4ac} \over 2a}.$$<br> """
  String data;

  /// Style TeXView Widget with [TeXViewStyle].
  TeXViewStyle style;

  TeXViewDocument(String data, {String id, TeXViewStyle style}) {
    this.id = id;
    this.style = style;
    this.data = data
        .replaceAll(new RegExp(r"&lt;dot&gt;", multiLine: true),
            '<font class="question_dot_underline">')
        .replaceAll(new RegExp(r"&lt;\/dot&gt;", multiLine: true), "</font>");
  }

  @override
  TeXViewWidgetMeta meta() {
    return TeXViewWidgetMeta(
        id: this.id,
        tag: 'div',
        classList: 'tex-view-document',
        node: Node.Leaf);
  }

  @override
  Map toJson() => {
        'meta': meta().toJson(),
        'data': this.data,
        'style': this.style?.initStyle() ?? teXViewDefaultStyle,
      };
}
