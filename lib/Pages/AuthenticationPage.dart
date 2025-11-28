import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:innvestorly_flutter/services/AuthService.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  String? selectedAuthMethod;
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
      // If MPIN is already set, automatically select it
      if (isSet) {
        selectedAuthMethod = 'mpin';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Authentication',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              SizedBox(height: 20),
              Text(
                'Choose Your Authentication Method',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Select your preferred method to secure your account',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Color(0xFF666666),
                ),
              ),
              SizedBox(height: 40),

              // Biometric Authentication Card
              _buildAuthCard(
                title: 'Biometric Authentication',
                subtitle: 'Use fingerprint or face recognition',
                icon: Icons.fingerprint,
                secondaryIcon: Icons.face,
                method: 'biometric',
                color: Color(0xFF50C878),
              ),
              SizedBox(height: 24),

              // MPIN Authentication Card
              _buildAuthCard(
                title: 'MPIN Authentication',
                subtitle: 'Use a 4 digit PIN',
                icon: Icons.lock_outline,
                method: 'mpin',
                color: Color(0xFF50C878),
              ),
              SizedBox(height: 40),

              // Continue Button
              if (selectedAuthMethod != null)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedAuthMethod == 'mpin') {
                        if (_isMPINSet) {
                          // Navigate to MPINPage for verification
                          Navigator.pushNamed(context, '/MPINPage');
                        } else {
                          // Show PIN setup dialog
                          _showPINSetupDialog();
                        }
                      } else {
                        // Handle biometric authentication
                        // Placeholder for navigation
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      selectedAuthMethod == 'mpin' && _isMPINSet
                          ? 'Verify MPIN'
                          : 'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        //color: Theme.of(context).colorScheme.surface,
                        color:Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.white,
                      ),
                    ),
                  ),
                ),

              // Remove MPIN Button (only show when MPIN is set and selected)
              if (selectedAuthMethod == 'mpin' && _isMPINSet) ...[
                SizedBox(height: 16),
                TextButton(
                  onPressed: _showRemoveMPINDialog,
                  child: Text(
                    'Remove MPIN Authentication',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthCard({
    required String title,
    required String subtitle,
    required IconData icon,
    IconData? secondaryIcon,
    required String method,
    required Color color,
  }) {
    bool isSelected = selectedAuthMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAuthMethod = method;
        });
      },
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Color(0xFFE0E0E0),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? color.withOpacity(0.2) 
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                  if (secondaryIcon != null)
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Icon(
                        secondaryIcon,
                        size: 20,
                        color: color.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 20),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color ?? Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color ?? Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            // Selection Indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Color(0xFFCCCCCC),
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Theme.of(context).colorScheme.surface,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showPINSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PINSetupDialog(
        onPINSet: () {
          setState(() {
            _isMPINSet = true;
            selectedAuthMethod = 'mpin'; // Highlight MPIN method
          });
          Navigator.of(context).pop();
          // Show success message
          _showSuccessDialog('MPIN has been set successfully!');
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showRemoveMPINDialog() {
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
            'Remove MPIN?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: Text(
            'Are you sure you want to remove MPIN authentication? You will need to set it up again if you want to use it.',
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
                // Clear MPIN
                await AuthService.clearMPIN();
                setState(() {
                  _isMPINSet = false;
                  selectedAuthMethod = null; // Deselect MPIN
                });
                Navigator.of(context).pop();
                // Show success message
                _showSuccessDialog('MPIN has been removed successfully!');
              },
              child: Text(
                'Remove',
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

  void _showSuccessDialog(String message) {
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
                Icons.check_circle_outline,
                color: Color(0xFF50C878),
                size: 28,
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
}

// PIN Setup Dialog Widget
class PINSetupDialog extends StatefulWidget {
  final VoidCallback onPINSet;
  final VoidCallback onCancel;

  const PINSetupDialog({
    super.key,
    required this.onPINSet,
    required this.onCancel,
  });

  @override
  State<PINSetupDialog> createState() => _PINSetupDialogState();
}

class _PINSetupDialogState extends State<PINSetupDialog> {
  String _pin = '';
  String _confirmPin = '';
  bool _isSettingPin = true; // true = setting PIN, false = confirming PIN
  bool _isError = false;
  String _errorMessage = '';
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;
  
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  final FocusNode _confirmPinFocusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _pinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
    super.dispose();
  }

  // List of common PINs to avoid
  final List<String> _commonPins = [
    '1234', '0000', '1111', '2222', '3333', '4444', '5555',
    '6666', '7777', '8888', '9999', '0123', '1230', '4321',
    '1357', '2468', '1010', '2020', '1212', '1313', '1414',
    '1515', '1616', '1717', '1818', '1919', '2000', '2019',
    '2021', '2022', '2023', '2024',
  ];

  void _onPinChanged(String value) {
    // Only allow numeric input and max 4 digits
    String numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericValue.length > 4) {
      numericValue = numericValue.substring(0, 4);
    }
    
    setState(() {
      _pin = numericValue;
      _pinController.text = numericValue;
      _pinController.selection = TextSelection.fromPosition(
        TextPosition(offset: numericValue.length),
      );
      _isError = false;
      _errorMessage = '';
    });

    // Validate when 4 digits are entered
    if (_pin.length == 4) {
      _validatePin(_pin);
    }
  }

  void _onConfirmPinChanged(String value) {
    // Only allow numeric input and max 4 digits
    String numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericValue.length > 4) {
      numericValue = numericValue.substring(0, 4);
    }
    
    setState(() {
      _confirmPin = numericValue;
      _confirmPinController.text = numericValue;
      _confirmPinController.selection = TextSelection.fromPosition(
        TextPosition(offset: numericValue.length),
      );
      _isError = false;
      _errorMessage = '';
    });

    // Validate when 4 digits are entered
    if (_confirmPin.length == 4) {
      _validateConfirmPin();
    }
  }

  void _validatePin(String pin) {
    // Check for repeated numbers (e.g., 1111, 2222)
    if (pin[0] == pin[1] && pin[1] == pin[2] && pin[2] == pin[3]) {
      setState(() {
        _isError = true;
        _errorMessage = 'PIN cannot have repeated numbers';
      });
      _clearPinAfterDelay();
      return;
    }

    // Check for common PINs
    if (_commonPins.contains(pin)) {
      setState(() {
        _isError = true;
        _errorMessage = 'This PIN is too common. Please choose a different one';
      });
      _clearPinAfterDelay();
      return;
    }

    // Check for sequential numbers (e.g., 1234, 4321)
    if (_isSequential(pin)) {
      setState(() {
        _isError = true;
        _errorMessage = 'PIN cannot be sequential';
      });
      _clearPinAfterDelay();
      return;
    }

    // Valid PIN - proceed to confirmation
    setState(() {
      _isError = false;
      _errorMessage = '';
      _isSettingPin = false;
    });
    // Move focus to confirm PIN field
    Future.delayed(Duration(milliseconds: 100), () {
      _confirmPinFocusNode.requestFocus();
    });
  }

  void _validateConfirmPin() {
    if (_confirmPin != _pin) {
      setState(() {
        _isError = true;
        _errorMessage = 'PINs do not match. Please try again';
      });
      _clearPinAfterDelay();
      return;
    }

    // PINs match - save and close
    AuthService.saveMPIN(_pin).then((_) {
      widget.onPINSet();
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
          if (_isSettingPin) {
            _pin = '';
            _pinController.clear();
          } else {
            _confirmPin = '';
            _confirmPinController.clear();
          }
          _isError = false;
          _errorMessage = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set MPIN',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color ?? Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Enter a secure 4-digit PIN',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color ?? Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onCancel,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Theme.of(context).textTheme.bodyMedium?.color ?? Color(0xFF666666),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // PIN Input Field
            TextField(
              controller: _pinController,
              focusNode: _pinFocusNode,
              obscureText: _obscurePin,
              keyboardType: TextInputType.number,
              maxLength: 4,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                color: Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1A1A1A),
              ),
              decoration: InputDecoration(
                labelText: 'Enter PIN',
                labelStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Color(0xFF666666),
                  fontSize: 14,
                ),
                hintText: '••••',
                hintStyle: TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  color: Color(0xFFCCCCCC),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Color(0xFF666666),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePin = !_obscurePin;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _isError && _isSettingPin
                        ? Colors.red
                        : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade700
                            : Color(0xFFE0E0E0)),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _isError && _isSettingPin
                        ? Colors.red
                        : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade700
                            : Color(0xFFE0E0E0)),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _isError && _isSettingPin
                        ? Colors.red
                        : Color(0xFF4A90E2),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                counterText: '',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onChanged: _onPinChanged,
            ),

            SizedBox(height: 20),

            // Confirm PIN Input Field
            TextField(
              controller: _confirmPinController,
              focusNode: _confirmPinFocusNode,
              obscureText: _obscureConfirmPin,
              keyboardType: TextInputType.number,
              maxLength: 4,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                color: Theme.of(context).textTheme.bodyLarge?.color ?? Color(0xFF1A1A1A),
              ),
              decoration: InputDecoration(
                labelText: 'Confirm PIN',
                labelStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? Color(0xFF666666),
                  fontSize: 14,
                ),
                hintText: '••••',
                hintStyle: TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  color: Color(0xFFCCCCCC),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Color(0xFF666666),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPin = !_obscureConfirmPin;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _isError && !_isSettingPin
                        ? Colors.red
                        : Color(0xFFE0E0E0),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _isError && !_isSettingPin
                        ? Colors.red
                        : Color(0xFFE0E0E0),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _isError && !_isSettingPin
                        ? Colors.red
                        : Color(0xFF4A90E2),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                counterText: '',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onChanged: _onConfirmPinChanged,
            ),

            // Error Message
            if (_isError && _errorMessage.isNotEmpty) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

}

