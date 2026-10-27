/// The expression language of FieldQuire forms (ADR-030 §4): a safe subset
/// of XLSForm/XPath for skip logic (`relevant`), validation (`constraint`)
/// and calculations.
///
/// ```text
/// ${B2} = 'boiling' and ${A2} > 0
/// selected(${B2}, 'none') or count-selected(${B2}) >= 2
/// . >= 0 and . <= 30
/// if(${C5} = '1', 'correct', 'wrong')
/// ```
///
/// Values follow XLSForm: an empty or missing answer is `''`; a
/// choose-many answer reads as its values joined by spaces; `=` and the
/// comparisons work on numbers when both sides are numbers, otherwise on
/// text. Nothing can reach outside the record: there are no variables but
/// the form's own fields, and no loops.
library;

/// A problem in an expression's text, with where it is.
class ExpressionError implements Exception {
  const ExpressionError(this.message, this.position);

  final String message;
  final int position;

  @override
  String toString() => 'ExpressionError($message at $position)';
}

/// Where an expression reads answers: by field name, and `.` (the answer
/// being checked).
abstract interface class ExpressionContext {
  Object? value(String name);
  Object? get current;
}

/// A parsed expression, ready to evaluate any number of times.
class Expression {
  Expression._(this.source, this._root);

  /// Parses [source]; throws [ExpressionError] when it is not valid.
  factory Expression.parse(String source) {
    final parser = _Parser(source);
    final root = parser.parseAll();
    return Expression._(source, root);
  }

  final String source;
  final _Node _root;

  /// The field names the expression reads (`${name}`).
  Set<String> get references {
    final names = <String>{};
    void walk(_Node n) {
      switch (n) {
        case _Ref(:final name):
          names.add(name);
        case _Binary(:final left, :final right):
          walk(left);
          walk(right);
        case _Negate(:final operand):
          walk(operand);
        case _Call(:final args):
          args.forEach(walk);
        case _Literal() || _Current():
          break;
      }
    }

    walk(_root);
    return names;
  }

  /// The value: a [String], [num] or [bool].
  Object evaluate(ExpressionContext context) => _eval(_root, context);

  /// The value read as true or false (non-empty text, non-zero number).
  bool test(ExpressionContext context) => truthy(evaluate(context));
}

/// XLSForm truthiness.
bool truthy(Object? v) => switch (v) {
  null => false,
  bool b => b,
  num n => n != 0 && !n.isNaN,
  String s => s.isNotEmpty,
  _ => true,
};

/// An answer as the expression sees it.
Object _normal(Object? v) => switch (v) {
  null => '',
  List<Object?> l => l.where((e) => e != null).join(' '),
  bool b => b,
  num n => n,
  DateTime d => d.toIso8601String(),
  _ => v.toString(),
};

num? _number(Object v) => switch (v) {
  num n => n,
  bool b => b ? 1 : 0,
  String s when s.trim().isEmpty => null,
  String s => num.tryParse(s.trim()),
  _ => null,
};

String _text(Object v) => switch (v) {
  double d when d == d.roundToDouble() && d.isFinite => d.toInt().toString(),
  _ => v.toString(),
};

bool _equal(Object a, Object b) {
  final x = _number(a), y = _number(b);
  if (x != null && y != null) return x == y;
  if (a is bool || b is bool) return truthy(a) == truthy(b);
  return _text(a) == _text(b);
}

int? _compare(Object a, Object b) {
  final x = _number(a), y = _number(b);
  if (x != null && y != null) return x.compareTo(y);
  final s = _text(a), t = _text(b);
  if (s.isEmpty || t.isEmpty) return null;
  return s.compareTo(t);
}

String _today() {
  final d = DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

Object _eval(_Node n, ExpressionContext c) {
  switch (n) {
    case _Literal(:final value):
      return value;
    case _Ref(:final name):
      return _normal(c.value(name));
    case _Current():
      return _normal(c.current);
    case _Negate(:final operand):
      final v = _number(_eval(operand, c));
      return v == null ? double.nan : -v;
    case _Binary(:final op, :final left, :final right):
      if (op == 'and') return truthy(_eval(left, c)) && truthy(_eval(right, c));
      if (op == 'or') return truthy(_eval(left, c)) || truthy(_eval(right, c));
      final a = _eval(left, c), b = _eval(right, c);
      switch (op) {
        case '=':
          return _equal(a, b);
        case '!=':
          return !_equal(a, b);
        case '<' || '<=' || '>' || '>=':
          final r = _compare(a, b);
          if (r == null) return false;
          return switch (op) {
            '<' => r < 0,
            '<=' => r <= 0,
            '>' => r > 0,
            _ => r >= 0,
          };
      }
      final x = _number(a), y = _number(b);
      if (x == null || y == null) return double.nan;
      return switch (op) {
        '+' => x + y,
        '-' => x - y,
        '*' => x * y,
        'div' => y == 0 ? double.nan : x / y,
        _ => y == 0 ? double.nan : x % y,
      };
    case _Call(:final name, :final args):
      Object arg(int i) => _eval(args[i], c);
      switch (name) {
        case 'selected':
          final values = _text(arg(0)).split(' ');
          return values.contains(_text(arg(1)));
        case 'count-selected':
          final s = _text(arg(0)).trim();
          return s.isEmpty ? 0 : s.split(RegExp(r'\s+')).length;
        case 'string-length':
          return _text(arg(0)).length;
        case 'regex':
          return RegExp(_text(arg(1))).hasMatch(_text(arg(0)));
        case 'contains':
          return _text(arg(0)).contains(_text(arg(1)));
        case 'starts-with':
          return _text(arg(0)).startsWith(_text(arg(1)));
        case 'if':
          return truthy(arg(0)) ? arg(1) : arg(2);
        case 'not':
          return !truthy(arg(0));
        case 'coalesce':
          final a = arg(0);
          return _text(a).isEmpty ? arg(1) : a;
        case 'concat':
          return [for (var i = 0; i < args.length; i++) _text(arg(i))].join();
        case 'number':
          return _number(arg(0)) ?? double.nan;
        case 'int':
          final v = _number(arg(0));
          return v == null || v.isNaN ? double.nan : v.truncate();
        case 'round':
          final v = _number(arg(0));
          final places = args.length > 1 ? (_number(arg(1)) ?? 0).toInt() : 0;
          if (v == null) return double.nan;
          final f = _pow10(places);
          return (v * f).round() / f;
        case 'today':
          return _today();
        case 'now':
          return DateTime.now().toIso8601String();
        case 'true':
          return true;
        case 'false':
          return false;
      }
      throw ExpressionError('unknown function $name', 0);
  }
}

num _pow10(int n) {
  var f = 1;
  for (var i = 0; i < n; i++) {
    f *= 10;
  }
  return f;
}

/// Functions and how many arguments each takes (min, max).
const _functions = <String, (int, int)>{
  'selected': (2, 2),
  'count-selected': (1, 1),
  'string-length': (1, 1),
  'regex': (2, 2),
  'contains': (2, 2),
  'starts-with': (2, 2),
  'if': (3, 3),
  'not': (1, 1),
  'coalesce': (2, 2),
  'concat': (1, 20),
  'number': (1, 1),
  'int': (1, 1),
  'round': (1, 2),
  'today': (0, 0),
  'now': (0, 0),
  'true': (0, 0),
  'false': (0, 0),
};

// ------------------------------------------------------------------ syntax

sealed class _Node {}

class _Literal extends _Node {
  _Literal(this.value);
  final Object value;
}

class _Ref extends _Node {
  _Ref(this.name);
  final String name;
}

class _Current extends _Node {}

class _Negate extends _Node {
  _Negate(this.operand);
  final _Node operand;
}

class _Binary extends _Node {
  _Binary(this.op, this.left, this.right);
  final String op;
  final _Node left;
  final _Node right;
}

class _Call extends _Node {
  _Call(this.name, this.args);
  final String name;
  final List<_Node> args;
}

enum _Kind { number, text, ref, dot, name, op, lparen, rparen, comma, end }

class _Token {
  _Token(this.kind, this.text, this.position);
  final _Kind kind;
  final String text;
  final int position;
}

List<_Token> _tokens(String s) {
  final out = <_Token>[];
  var i = 0;
  bool isNameChar(String ch) => RegExp(r'[A-Za-z0-9_\-]').hasMatch(ch);
  while (i < s.length) {
    final ch = s[i];
    if (ch.trim().isEmpty) {
      i++;
      continue;
    }
    final start = i;
    if (ch == r'$' && i + 1 < s.length && s[i + 1] == '{') {
      final end = s.indexOf('}', i);
      if (end < 0) throw ExpressionError('unclosed \${', i);
      final name = s.substring(i + 2, end).trim();
      if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_\-]*$').hasMatch(name)) {
        throw ExpressionError('bad field name "$name"', i);
      }
      out.add(_Token(_Kind.ref, name, start));
      i = end + 1;
    } else if (ch == "'" || ch == '"') {
      final end = s.indexOf(ch, i + 1);
      if (end < 0) throw ExpressionError('unclosed text', i);
      out.add(_Token(_Kind.text, s.substring(i + 1, end), start));
      i = end + 1;
    } else if (RegExp(r'[0-9]').hasMatch(ch) ||
        (ch == '.' &&
            i + 1 < s.length &&
            RegExp(r'[0-9]').hasMatch(s[i + 1]))) {
      var j = i;
      while (j < s.length && RegExp(r'[0-9.]').hasMatch(s[j])) {
        j++;
      }
      out.add(_Token(_Kind.number, s.substring(i, j), start));
      i = j;
    } else if (ch == '.') {
      out.add(_Token(_Kind.dot, '.', start));
      i++;
    } else if (ch == '(') {
      out.add(_Token(_Kind.lparen, ch, start));
      i++;
    } else if (ch == ')') {
      out.add(_Token(_Kind.rparen, ch, start));
      i++;
    } else if (ch == ',') {
      out.add(_Token(_Kind.comma, ch, start));
      i++;
    } else if ('=<>!+-*'.contains(ch)) {
      final two = i + 1 < s.length ? s.substring(i, i + 2) : ch;
      if (two == '<=' || two == '>=' || two == '!=') {
        out.add(_Token(_Kind.op, two, start));
        i += 2;
      } else if (ch == '!') {
        throw ExpressionError('use != or not()', i);
      } else {
        out.add(_Token(_Kind.op, ch, start));
        i++;
      }
    } else if (RegExp(r'[A-Za-z_]').hasMatch(ch)) {
      var j = i;
      while (j < s.length && isNameChar(s[j])) {
        j++;
      }
      final word = s.substring(i, j);
      out.add(
        _Token(
          const {'and', 'or', 'div', 'mod'}.contains(word)
              ? _Kind.op
              : _Kind.name,
          word,
          start,
        ),
      );
      i = j;
    } else {
      throw ExpressionError('unexpected "$ch"', i);
    }
  }
  out.add(_Token(_Kind.end, '', s.length));
  return out;
}

class _Parser {
  _Parser(String source) : _t = _tokens(source);

  final List<_Token> _t;
  var _i = 0;

  _Token get _peek => _t[_i];

  _Token _next() => _t[_i++];

  bool _isOp(String op) => _peek.kind == _Kind.op && _peek.text == op;

  _Node parseAll() {
    if (_peek.kind == _Kind.end) throw const ExpressionError('empty', 0);
    final n = _or();
    if (_peek.kind != _Kind.end) {
      throw ExpressionError('unexpected "${_peek.text}"', _peek.position);
    }
    return n;
  }

  _Node _or() {
    var n = _and();
    while (_isOp('or')) {
      _next();
      n = _Binary('or', n, _and());
    }
    return n;
  }

  _Node _and() {
    var n = _comparison();
    while (_isOp('and')) {
      _next();
      n = _Binary('and', n, _comparison());
    }
    return n;
  }

  _Node _comparison() {
    var n = _additive();
    while (_peek.kind == _Kind.op &&
        const {'=', '!=', '<', '<=', '>', '>='}.contains(_peek.text)) {
      final op = _next().text;
      n = _Binary(op, n, _additive());
    }
    return n;
  }

  _Node _additive() {
    var n = _multiplicative();
    while (_isOp('+') || _isOp('-')) {
      final op = _next().text;
      n = _Binary(op, n, _multiplicative());
    }
    return n;
  }

  _Node _multiplicative() {
    var n = _unary();
    while (_isOp('*') || _isOp('div') || _isOp('mod')) {
      final op = _next().text;
      n = _Binary(op, n, _unary());
    }
    return n;
  }

  _Node _unary() {
    if (_isOp('-')) {
      _next();
      return _Negate(_unary());
    }
    return _primary();
  }

  _Node _primary() {
    final t = _next();
    switch (t.kind) {
      case _Kind.number:
        final v = num.tryParse(t.text);
        if (v == null) throw ExpressionError('bad number', t.position);
        return _Literal(v);
      case _Kind.text:
        return _Literal(t.text);
      case _Kind.ref:
        return _Ref(t.text);
      case _Kind.dot:
        return _Current();
      case _Kind.lparen:
        final n = _or();
        if (_next().kind != _Kind.rparen) {
          throw ExpressionError('missing )', t.position);
        }
        return n;
      case _Kind.name:
        final arity = _functions[t.text];
        if (arity == null) {
          throw ExpressionError('unknown function "${t.text}"', t.position);
        }
        if (_next().kind != _Kind.lparen) {
          throw ExpressionError('expected ( after ${t.text}', t.position);
        }
        final args = <_Node>[];
        if (_peek.kind != _Kind.rparen) {
          args.add(_or());
          while (_peek.kind == _Kind.comma) {
            _next();
            args.add(_or());
          }
        }
        if (_next().kind != _Kind.rparen) {
          throw ExpressionError('missing ) after ${t.text}', t.position);
        }
        if (args.length < arity.$1 || args.length > arity.$2) {
          throw ExpressionError(
            '${t.text} takes ${arity.$1 == arity.$2 ? arity.$1 : '${arity.$1}–${arity.$2}'} '
            'value(s)',
            t.position,
          );
        }
        return _Call(t.text, args);
      default:
        throw ExpressionError(
          t.kind == _Kind.end ? 'unfinished' : 'unexpected "${t.text}"',
          t.position,
        );
    }
  }
}
