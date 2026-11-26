import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// 서버(Python)는 문자열 길이를 유니코드 코드 포인트 수로 셉니다.
// 그런데 화면의 한 글자는 코드 포인트 여러 개일 수 있습니다. 예: 👍🏽 = 👍 + 피부색(2개)
// 그래서 길이는 코드 포인트로 세고, 자를 때는 화면의 글자(grapheme cluster) 단위로 잘라
// 이모지 조합이 중간에서 쪼개지지 않게 합니다.

/// [text]를 코드 포인트 [max]개 이내로 자릅니다. 화면의 글자 중간에서는 자르지 않으므로
/// 마지막 글자가 경계에 걸리면 그 글자는 통째로 뺍니다. (결과가 [max]보다 짧을 수 있습니다)
String truncateToCodePoints(String text, int max) {
  if (text.runes.length <= max) return text;
  final buffer = StringBuffer();
  var count = 0;
  for (final char in text.characters) {
    final length = char.runes.length;
    if (count + length > max) break;
    buffer.write(char);
    count += length;
  }
  return buffer.toString();
}

/// 입력을 코드 포인트 [max]개까지만 받습니다. 넘치면(붙여넣기 등) 글자 단위로 넘는 부분을 자릅니다.
/// 서버와 같은 기준으로 세기 때문에, 입력할 수 있었던 값은 서버로 보낼 때 잘리지 않습니다.
class CodePointLimitingTextInputFormatter extends TextInputFormatter {
  const CodePointLimitingTextInputFormatter(this.max);

  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.runes.length <= max) return newValue;
    final truncated = truncateToCodePoints(newValue.text, max);
    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}
