import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:innvestorly_flutter/services/AuthService.dart';
import 'package:innvestorly_flutter/services/BiometricService.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  String? selectedAuthMethod;
  bool _isMPINSet = false;
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  bool _isCheckingBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkMPINStatus();
    _checkBiometricStatus();
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

  Future<void> _checkBiometricStatus() async {
    setState(() {
      _isCheckingBiometric = true;
    });

    final isEnabled = await AuthService.isBiometricEnabled();
    final isAvailable = await BiometricService.isBiometricAvailable();

    setState(() {
      _isBiometricEnabled = isEnabled;
      _isBiometricAvailable = isAvailable;
      _isCheckingBiometric = false;
      // If biometric is enabled, automatically select it
      if (isEnabled && isAvailable) {
        selectedAuthMethod = 'biometric';
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
                subtitle: _isCheckingBiometric
                    ? 'Checking availability...'
                    : _isBiometricAvailable
                        ? 'Use fingerprint or face recognition'
                        : 'Not available on this device',
                icon: Icons.fingerprint,
                secondaryIcon: Icons.face,
                method: 'biometric',
                color: Color(0xFF50C878),
                isEnabled: _isBiometricAvailable && !_isCheckingBiometric,
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
                    onPressed: () async {
                      if (selectedAuthMethod == 'mpin') {
                        if (_isMPINSet) {
                          // Navigate to MPINPage for verification
                          Navigator.pushNamed(context, '/MPINPage');
                        } else {
                          // Show PIN setup dialog
                          _showPINSetupDialog();
                        }
                      } else if (selectedAuthMethod == 'biometric') {
                        // Handle biometric authentication setup
                        await _handleBiometricSetup();
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

              // Remove Biometric Button (only show when biometric is enabled and selected)
              if (selectedAuthMethod == 'biometric' && _isBiometricEnabled) ...[
                SizedBox(height: 16),
                TextButton(
                  onPressed: _showRemoveBiometricDialog,
                  child: Text(
                    'Remove Biometric Authentication',
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
    bool isEnabled = true,
  }) {
    bool isSelected = selectedAuthMethod == method;
    
    return GestureDetector(
      onTap: isEnabled
          ? () {
              setState(() {
                selectedAuthMethod = method;
              });
            }
          : null,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isEnabled
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled
                ? (isSelected ? color : Color(0xFFE0E0E0))
                : Color(0xFFCCCCCC),
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark
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
              color: isDark ? Colors.white : Color(0xFF1A1A1A),
            ),
          ),
          content: Text(
            'Are you sure you want to remove MPIN authentication? You will need to set it up again if you want to use it.',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Color(0xFF666666),
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
                  color: isDark ? Colors.white : Color(0xFF666666),
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

  Future<void> _handleBiometricSetup() async {
    // Check device compatibility
    final isCompatible = await BiometricService.isDeviceCompatible();
    if (!isCompatible) {
      _showErrorDialog('Biometric authentication is not supported on this device.');
      return;
    }

    // Check if biometric is available
    final isAvailable = await BiometricService.isBiometricAvailable();
    if (!isAvailable) {
      _showErrorDialog(
          'No biometric authentication is set up on this device. Please set up fingerprint or face recognition in your device settings.');
      return;
    }

    // Get available biometric types
    final availableBiometrics = await BiometricService.getAvailableBiometrics();
    String biometricType = 'biometric';
    if (availableBiometrics.isNotEmpty) {
      biometricType = BiometricService.getBiometricTypeName(availableBiometrics.first);
    }

    // Authenticate with biometric
    final authenticated = await BiometricService.authenticate(
      reason: 'Please authenticate to enable biometric login',
    );

    if (authenticated) {
      // Enable biometric authentication
      await AuthService.enableBiometric();
      setState(() {
        _isBiometricEnabled = true;
      });
      _showSuccessDialog('Biometric authentication has been enabled successfully!');
    } else {
      _showErrorDialog('Biometric authentication failed. Please try again.');
    }
  }

  void _showRemoveBiometricDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark
              ? Color(0xFF1E3A5F)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Remove Biometric?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Color(0xFF1A1A1A),
            ),
          ),
          content: Text(
            'Are you sure you want to remove biometric authentication? You will need to set it up again if you want to use it.',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Color(0xFF666666),
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
                  color: isDark ? Colors.white : Color(0xFF666666),
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Disable biometric
                await AuthService.disableBiometric();
                setState(() {
                  _isBiometricEnabled = false;
                  selectedAuthMethod = null; // Deselect biometric
                });
                Navigator.of(context).pop();
                // Show success message
                _showSuccessDialog('Biometric authentication has been removed successfully!');
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark
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
                size: 28,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Color(0xFF1A1A1A),
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
                  color: isDark ? Colors.white : Color(0xFF3AB7BF),
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark
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
                    color: isDark ? Colors.white : Color(0xFF1A1A1A),
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
                  color: isDark ? Colors.white : Color(0xFF3AB7BF),
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

