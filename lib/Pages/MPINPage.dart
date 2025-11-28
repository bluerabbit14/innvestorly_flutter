import 'package:flutter/material.dart';
import 'package:innvestorly_flutter/services/AuthService.dart';

class MPINPage extends StatefulWidget {
  const MPINPage({super.key});

  @override
  State<MPINPage> createState() => _MPINPageState();
}

class _MPINPageState extends State<MPINPage> {
  String _pin = '';
  bool _isError = false;
  String _errorMessage = '';
  bool _isMPINSet = false;

  @override
  void initState() {
    super.initState();
    _checkMPINStatus();
  }

  Future<void> _checkMPINStatus() async {
    final isSet = await AuthService.isMPINSet();
    setState(() {
      _isMPINSet = isSet;
    });
  }

  // List of common PINs to avoid
  final List<String> _commonPins = [
    '1234', '0000','1111', '2222','3333','4444','5555',
    '6666','7777','8888','9999','0123','1230','4321',
    '1357','2468','1010','2020','1212','1313','1414',
    '1515','1616','1717','1818','1919','2000','2019',
    '2021','2022','2023','2024',
  ];

  void _onNumberPressed(String number) {
    if (_pin.length < 4) {
      setState(() {
        _pin += number;
        _isError = false;
        _errorMessage = '';
      });

      // Validate when 4 digits are entered
      if (_pin.length == 4) {
        _validatePin();
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _isError = false;
        _errorMessage = '';
      });
    }
  }

  void _validatePin() async {
    // If MPIN is already set, verify the entered PIN
    if (_isMPINSet) {
      final isValid = await AuthService.verifyMPIN(_pin);
      if (isValid) {
        // PIN is correct - navigate to main app
        setState(() {
          _isError = false;
          _errorMessage = '';
        });
        // Navigate to dashboard or main app
        Navigator.pushReplacementNamed(context, '/DashboardPage');
      } else {
        // PIN is incorrect
        setState(() {
          _isError = true;
          _errorMessage = 'Incorrect PIN. Please try again';
        });
        _showErrorDialog('Incorrect PIN. Please try again');
        _clearPinAfterDelay();
      }
      return;
    }

    // If MPIN is not set, validate new PIN (shouldn't happen in normal flow, but keeping for safety)
    // Check for repeated numbers (e.g., 1111, 2222)
    if (_pin[0] == _pin[1] && _pin[1] == _pin[2] && _pin[2] == _pin[3]) {
      setState(() {
        _isError = true;
        _errorMessage = 'PIN cannot have repeated numbers';
      });
      _showErrorDialog('PIN cannot have repeated numbers');
      _clearPinAfterDelay();
      return;
    }

    // Check for common PINs
    if (_commonPins.contains(_pin)) {
      setState(() {
        _isError = true;
        _errorMessage = 'This PIN is too common. Please choose a different one';
      });
      _showErrorDialog('This PIN is too common. Please choose a different one');
      _clearPinAfterDelay();
      return;
    }

    // Check for sequential numbers (e.g., 1234, 4321)
    if (_isSequential(_pin)) {
      setState(() {
        _isError = true;
        _errorMessage = 'PIN cannot be sequential';
      });
      _showErrorDialog('PIN cannot be sequential');
      _clearPinAfterDelay();
      return;
    }

    // Valid PIN - proceed (placeholder for navigation)
    setState(() {
      _isError = false;
      _errorMessage = '';
    });
  }

  bool _isSequential(String pin) {
    List<int> digits = pin.split('').map((e) => int.parse(e)).toList();
    
    // Check ascending sequence
    bool ascending = true;
    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] + 1) {
        ascending = false;
        break;
      }
    }
    
    // Check descending sequence
    bool descending = true;
    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] - 1) {
        descending = false;
        break;
      }
    }
    
    return ascending || descending;
  }

  void _clearPinAfterDelay() {
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _pin = '';
          _isError = false;
          _errorMessage = '';
        });
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Color(0xFF1E3A5F)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
    
    // Auto-dismiss after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  void _showForgotMPINDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Color(0xFF1E3A5F)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Forgot MPIN?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: Text(
            'This will log you out and reset the app. You will need to login again and set up MPIN.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Reset all app data
                await AuthService.resetAllData();
                // Navigate to login page and clear navigation stack
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/LoginPage',
                  (route) => false,
                );
              },
              child: Text(
                'Logout & Reset',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Logo with opacity
            Center(
              child: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  'assets/innvestorly_logo.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Main Content
            Column(
              children: [
                // Top spacing
                SizedBox(height: 40),
                
                // Logo or Icon Section
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 50,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Color(0xFF4A90E2),
                  ),
                ),
                
                SizedBox(height: 30),
                
                // Title
                Text(
                  'Enter MPIN',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color ?? Color(0xFF1A1A1A),
                  ),
                ),
                
                SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Enter your 4-digit PIN to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Color(0xFF666666),
                  ),
                ),
                
                SizedBox(height: 30),
                
                // PIN Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    final filledColor = _isError 
                        ? Colors.red 
                        : (isDark ? Colors.white : Color(0xFF4A90E2));
                    final emptyBorderColor = isDark ? Colors.white : Color(0xFFCCCCCC);
                    
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _pin.length
                            ? filledColor
                            : Colors.transparent,
                        border: Border.all(
                          color: index < _pin.length
                              ? filledColor
                              : emptyBorderColor,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
                
                // Expanded(child: SizedBox()),
                SizedBox(height: 30),
                
                // Numeric Keypad
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Row 1: 1, 2, 3
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKeypadButton('1'),
                          _buildKeypadButton('2'),
                          _buildKeypadButton('3'),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Row 2: 4, 5, 6
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKeypadButton('4'),
                          _buildKeypadButton('5'),
                          _buildKeypadButton('6'),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Row 3: 7, 8, 9
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKeypadButton('7'),
                          _buildKeypadButton('8'),
                          _buildKeypadButton('9'),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Row 4: Empty, 0, Delete
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(width: 80, height: 80), // Empty space
                          _buildKeypadButton('0'),
                          _buildDeleteButton(),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                
                // Forgot MPIN Option
                TextButton(
                  onPressed: _showForgotMPINDialog,
                  child: Text(
                    'Forgot MPIN?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Color(0xFF4A90E2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberPressed(number),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _onDeletePressed,
      onLongPress: () {
        // Clear all on long press
        setState(() {
          _pin = '';
          _isError = false;
          _errorMessage = '';
        });
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 28,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }
}
