import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'iOS Calculator Clone (Modulus)',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '0';
  String _result = '0';

  // Define custom colors for the iOS aesthetic
  final Color _darkGray = const Color(0xff333333); // Number buttons
  final Color _lightGray = const Color(0xffa6a6a6); // Utility buttons
  final Color _orange = const Color(0xffff9f0a); // Operator buttons

  // --- Calculation & Button Logic ---
  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        _expression = '0';
        _result = '0';
      } else if (buttonText == '+/-') {
        _toggleSign();
      } else if (buttonText == '=') {
        _calculateResult();
      } else if (buttonText == '⌫') {
        // Backspace functionality
        if (_expression.length > 1 && _expression != '0') {
          _expression = _expression.substring(0, _expression.length - 1);
        } else {
          _expression = '0';
        }
      } else if (['÷', 'x', '-', '+', '%', '.'].contains(buttonText)) {
        // Handle operators and decimal
        if (_expression == 'Error') {
          _expression = '0'; // Reset after error
        }

        // Prevent multiple operators or a leading operator (except minus sign)
        if (['÷', 'x', '-', '+', '%'].contains(_expression.characters.last) && ['÷', 'x', '-', '+', '%'].contains(buttonText)) {
          // Replace the last operator with the new one
          _expression = _expression.substring(0, _expression.length - 1) + buttonText;
        } else {
          _expression += buttonText;
        }

      } else {
        // Handle number input (0-9)
        if (_expression == '0' || _expression == 'Error') {
          _expression = buttonText;
          _result = '0';
        } else {
          _expression += buttonText;
        }
      }
    });
  }

  void _calculateResult() {
    try {
      // Replace display symbols with math operators for the parser
      String finalExpression = _expression
          .replaceAll('x', '*')
          .replaceAll('÷', '/');

      // Modulus operator is already '%' which works with math_expressions

      Parser p = Parser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();

      double evalResult = exp.evaluate(EvaluationType.REAL, cm);

      // Format result: remove trailing '.0' if integer, and limit precision
      _result = evalResult.toStringAsFixed(10);
      if (_result.contains('.')) {
        _result = _result.replaceAll(RegExp(r'0+$'), '');
        if (_result.endsWith('.')) {
          _result = _result.substring(0, _result.length - 1);
        }
      }
      _expression = _result;
    } catch (e) {
      _result = 'Error';
      _expression = 'Error';
    }
  }

  void _toggleSign() {
    if (_expression != '0' && !_expression.startsWith('Error')) {
      if (_expression.startsWith('-')) {
        _expression = _expression.substring(1);
      } else {
        _expression = '-$_expression';
      }
    }
  }

  // Helper functions for button styles
  Color _getButtonColor(String buttonText) {
    if (['÷', 'x', '-', '+', '='].contains(buttonText)) {
      return _orange;
    } else if (['AC', '+/-', '%'].contains(buttonText)) {
      return _lightGray;
    } else {
      return _darkGray;
    }
  }

  Color _getTextColor(String buttonText) {
    return ['AC', '+/-', '%'].contains(buttonText) ? Colors.black : Colors.white;
  }

  // Widget to build the calculator button with iOS styling
  Widget _buildButton(String buttonText, double widthFactor) {
    final Color buttonColor = _getButtonColor(buttonText);
    final Color textColor = _getTextColor(buttonText);
    final double buttonSize = MediaQuery.of(context).size.width / 4 - 10;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        width: buttonSize * widthFactor + (widthFactor > 1.0 ? 5.0 : 0),
        height: buttonSize,
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(buttonText),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            shape: widthFactor > 1.0
                ? const StadiumBorder() // Rounded rectangle for the '0' button
                : const CircleBorder(),
            padding: widthFactor > 1.0
                ? const EdgeInsets.only(right: 75.0, left: 20.0) // Left-align '0'
                : EdgeInsets.zero,
            alignment: widthFactor > 1.0 ? Alignment.centerLeft : Alignment.center,
          ),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 40.0,
              color: textColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Defines the button layout
    final List<List<dynamic>> buttonLayout = [
      ['AC', '+/-', '%', '÷'], // % is now Modulus
      ['7', '8', '9', 'x'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      [
        {'text': '0', 'factor': 2.0}, // '0' is double-width
        {'text': '.', 'factor': 1.0},
        {'text': '=', 'factor': 1.0},
      ],
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Display Area (Expression)
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.only(right: 20.0, left: 20.0, bottom: 20.0),
                alignment: Alignment.bottomRight,
                child: Text(
                  _expression,
                  style: const TextStyle(
                    fontSize: 90.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Button Grid
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: buttonLayout.map((row) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: row.map((item) {
                      String text;
                      double factor;

                      if (item is String) {
                        text = item;
                        factor = 1.0;
                      } else {
                        text = item['text'] as String;
                        factor = item['factor'] as double;
                      }

                      return _buildButton(text, factor);
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}