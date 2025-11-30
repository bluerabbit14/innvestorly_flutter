/// Hardcoded data service that replaces all API calls
/// This service maintains in-memory data that can be updated for profile changes
class HardCodedDataService {
  // Singleton pattern
  static final HardCodedDataService _instance = HardCodedDataService._internal();
  factory HardCodedDataService() => _instance;
  HardCodedDataService._internal();

  // Hardcoded user credentials for login
  static const String _hardcodedPhone = '(123) 456-7890';
  static const String _hardcodedPassword = 'password123';
  static const String _hardcodedJwtToken = 'hardcoded_jwt_token_12345';

  // Hardcoded user profile data (can be updated)
  Map<String, dynamic> _userProfile = {
    'firstName': 'John',
    'lastName': 'Doe',
    'phoneNumber': '(123) 456-7890',
    'email': 'john.doe@example.com',
  };

  // Hardcoded revenue data
  List<Map<String, dynamic>> _dailyRevenue = [
    {
      'hotelName': 'Grand Plaza Hotel',
      'totalGrossRev': 125000.0,
      'myPercentageShare': 15.5,
      'myGrossShare': 19375.0,
    },
    {
      'hotelName': 'Ocean View Resort',
      'totalGrossRev': 98000.0,
      'myPercentageShare': 20.0,
      'myGrossShare': 19600.0,
    },
    {
      'hotelName': 'Mountain Peak Inn',
      'totalGrossRev': 75000.0,
      'myPercentageShare': 12.0,
      'myGrossShare': 9000.0,
    },
  ];

  List<Map<String, dynamic>> _weeklyRevenue = [
    {
      'hotelName': 'Grand Plaza Hotel',
      'totalGrossRev': 875000.0,
      'myPercentageShare': 15.5,
      'myGrossShare': 135625.0,
    },
    {
      'hotelName': 'Ocean View Resort',
      'totalGrossRev': 686000.0,
      'myPercentageShare': 20.0,
      'myGrossShare': 137200.0,
    },
    {
      'hotelName': 'Mountain Peak Inn',
      'totalGrossRev': 525000.0,
      'myPercentageShare': 12.0,
      'myGrossShare': 63000.0,
    },
  ];

  List<Map<String, dynamic>> _monthlyRevenue = [
    {
      'hotelName': 'Grand Plaza Hotel',
      'totalGrossRev': 3750000.0,
      'myPercentageShare': 15.5,
      'myGrossShare': 581250.0,
    },
    {
      'hotelName': 'Ocean View Resort',
      'totalGrossRev': 2940000.0,
      'myPercentageShare': 20.0,
      'myGrossShare': 588000.0,
    },
    {
      'hotelName': 'Mountain Peak Inn',
      'totalGrossRev': 2250000.0,
      'myPercentageShare': 12.0,
      'myGrossShare': 270000.0,
    },
  ];

  List<Map<String, dynamic>> _yearlyRevenue = [
    {
      'hotelName': 'Grand Plaza Hotel',
      'yearWiseData': [
        {
          'year': 2022,
          'totalGrossRev': 45000000.0,
          'myPercentageShare': 15.5,
          'myGrossShare': 6975000.0,
        },
        {
          'year': 2023,
          'totalGrossRev': 48000000.0,
          'myPercentageShare': 15.5,
          'myGrossShare': 7440000.0,
        },
        {
          'year': 2024,
          'totalGrossRev': 51000000.0,
          'myPercentageShare': 15.5,
          'myGrossShare': 7905000.0,
        },
        {
          'year': 2025,
          'totalGrossRev': 54000000.0,
          'myPercentageShare': 15.5,
          'myGrossShare': 8370000.0,
        },
      ],
    },
    {
      'hotelName': 'Ocean View Resort',
      'yearWiseData': [
        {
          'year': 2022,
          'totalGrossRev': 35280000.0,
          'myPercentageShare': 20.0,
          'myGrossShare': 7056000.0,
        },
        {
          'year': 2023,
          'totalGrossRev': 37800000.0,
          'myPercentageShare': 20.0,
          'myGrossShare': 7560000.0,
        },
        {
          'year': 2024,
          'totalGrossRev': 40320000.0,
          'myPercentageShare': 20.0,
          'myGrossShare': 8064000.0,
        },
        {
          'year': 2025,
          'totalGrossRev': 42840000.0,
          'myPercentageShare': 20.0,
          'myGrossShare': 8568000.0,
        },
      ],
    },
    {
      'hotelName': 'Mountain Peak Inn',
      'yearWiseData': [
        {
          'year': 2022,
          'totalGrossRev': 27000000.0,
          'myPercentageShare': 12.0,
          'myGrossShare': 3240000.0,
        },
        {
          'year': 2023,
          'totalGrossRev': 28800000.0,
          'myPercentageShare': 12.0,
          'myGrossShare': 3456000.0,
        },
        {
          'year': 2024,
          'totalGrossRev': 30600000.0,
          'myPercentageShare': 12.0,
          'myGrossShare': 3672000.0,
        },
        {
          'year': 2025,
          'totalGrossRev': 32400000.0,
          'myPercentageShare': 12.0,
          'myGrossShare': 3888000.0,
        },
      ],
    },
  ];

  List<Map<String, dynamic>> _yoyRevenue = [
    {
      'month': 'January',
      'leftYearRevenue': 4250000.0,
      'rightYearRevenue': 4500000.0,
      'investorRevenue': 697500.0,
    },
    {
      'month': 'February',
      'leftYearRevenue': 4000000.0,
      'rightYearRevenue': 4250000.0,
      'investorRevenue': 658750.0,
    },
    {
      'month': 'March',
      'leftYearRevenue': 4500000.0,
      'rightYearRevenue': 4750000.0,
      'investorRevenue': 736250.0,
    },
    {
      'month': 'April',
      'leftYearRevenue': 4200000.0,
      'rightYearRevenue': 4450000.0,
      'investorRevenue': 689750.0,
    },
    {
      'month': 'May',
      'leftYearRevenue': 4800000.0,
      'rightYearRevenue': 5050000.0,
      'investorRevenue': 782750.0,
    },
    {
      'month': 'June',
      'leftYearRevenue': 5000000.0,
      'rightYearRevenue': 5250000.0,
      'investorRevenue': 813750.0,
    },
    {
      'month': 'July',
      'leftYearRevenue': 5200000.0,
      'rightYearRevenue': 5450000.0,
      'investorRevenue': 844750.0,
    },
    {
      'month': 'August',
      'leftYearRevenue': 5100000.0,
      'rightYearRevenue': 5350000.0,
      'investorRevenue': 829250.0,
    },
    {
      'month': 'September',
      'leftYearRevenue': 4600000.0,
      'rightYearRevenue': 4850000.0,
      'investorRevenue': 751750.0,
    },
    {
      'month': 'October',
      'leftYearRevenue': 4400000.0,
      'rightYearRevenue': 4650000.0,
      'investorRevenue': 720750.0,
    },
    {
      'month': 'November',
      'leftYearRevenue': 4200000.0,
      'rightYearRevenue': 4450000.0,
      'investorRevenue': 689750.0,
    },
    {
      'month': 'December',
      'leftYearRevenue': 4800000.0,
      'rightYearRevenue': 5050000.0,
      'investorRevenue': 782750.0,
    },
  ];

  // Hardcoded occupancy data
  List<Map<String, dynamic>> _dailyOccupancy = [
    {
      'hotelName': 'Grand Plaza Hotel',
      'hotelShortName': 'GPH',
      'totalRooms': 250.0,
      'occupiedRooms': 200.0,
    },
    {
      'hotelName': 'Ocean View Resort',
      'hotelShortName': 'OVR',
      'totalRooms': 180.0,
      'occupiedRooms': 150.0,
    },
    {
      'hotelName': 'Mountain Peak Inn',
      'hotelShortName': 'MPI',
      'totalRooms': 120.0,
      'occupiedRooms': 95.0,
    },
  ];

  List<Map<String, dynamic>> _weeklyOccupancy = [
    {
      'hotelName': 'Grand Plaza Hotel',
      'hotelShortName': 'GPH',
      'totalRooms': 1750.0,
      'occupiedRooms': 1400.0,
    },
    {
      'hotelName': 'Ocean View Resort',
      'hotelShortName': 'OVR',
      'totalRooms': 1260.0,
      'occupiedRooms': 1050.0,
    },
    {
      'hotelName': 'Mountain Peak Inn',
      'hotelShortName': 'MPI',
      'totalRooms': 840.0,
      'occupiedRooms': 665.0,
    },
  ];

  List<Map<String, dynamic>> _monthlyOccupancy = [
    {
      'hotelName': 'Grand Plaza Hotel',
      'hotelShortName': 'GPH',
      'totalRooms': 7500.0,
      'occupiedRooms': 6000.0,
    },
    {
      'hotelName': 'Ocean View Resort',
      'hotelShortName': 'OVR',
      'totalRooms': 5400.0,
      'occupiedRooms': 4500.0,
    },
    {
      'hotelName': 'Mountain Peak Inn',
      'hotelShortName': 'MPI',
      'totalRooms': 3600.0,
      'occupiedRooms': 2850.0,
    },
  ];

  List<Map<String, dynamic>> _yearlyOccupancy = [
    {
      'hotelName': 'Grand Plaza Hotel',
      'hotelShortName': 'GPH',
      'yearWiseData': [
        {
          'year': 2022,
          'totalRooms': 91250.0,
          'occupiedRooms': 73000.0,
        },
        {
          'year': 2023,
          'totalRooms': 91250.0,
          'occupiedRooms': 75000.0,
        },
        {
          'year': 2024,
          'totalRooms': 91250.0,
          'occupiedRooms': 77000.0,
        },
        {
          'year': 2025,
          'totalRooms': 91250.0,
          'occupiedRooms': 79000.0,
        },
      ],
    },
    {
      'hotelName': 'Ocean View Resort',
      'hotelShortName': 'OVR',
      'yearWiseData': [
        {
          'year': 2022,
          'totalRooms': 65700.0,
          'occupiedRooms': 54000.0,
        },
        {
          'year': 2023,
          'totalRooms': 65700.0,
          'occupiedRooms': 55000.0,
        },
        {
          'year': 2024,
          'totalRooms': 65700.0,
          'occupiedRooms': 56000.0,
        },
        {
          'year': 2025,
          'totalRooms': 65700.0,
          'occupiedRooms': 57000.0,
        },
      ],
    },
    {
      'hotelName': 'Mountain Peak Inn',
      'hotelShortName': 'MPI',
      'yearWiseData': [
        {
          'year': 2022,
          'totalRooms': 43800.0,
          'occupiedRooms': 34200.0,
        },
        {
          'year': 2023,
          'totalRooms': 43800.0,
          'occupiedRooms': 35000.0,
        },
        {
          'year': 2024,
          'totalRooms': 43800.0,
          'occupiedRooms': 35800.0,
        },
        {
          'year': 2025,
          'totalRooms': 43800.0,
          'occupiedRooms': 36600.0,
        },
      ],
    },
  ];

  /// Validates login credentials against hardcoded data
  Future<Map<String, dynamic>> authenticate(String phoneNumber, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    // Normalize phone number for comparison (remove formatting)
    String normalizedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    String normalizedHardcoded = _hardcodedPhone.replaceAll(RegExp(r'[^\d]'), '');

    if (normalizedPhone == normalizedHardcoded && password == _hardcodedPassword) {
      return {
        'success': true,
        'token': _hardcodedJwtToken,
        'message': 'Login successful',
      };
    } else {
      throw Exception('Invalid credentials. Please check your phone number and password.');
    }
  }

  /// Gets user profile data
  Future<Map<String, dynamic>> getUserProfile() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));
    return Map<String, dynamic>.from(_userProfile);
  }

  /// Updates user profile data (but not phone number or password)
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber, // Ignored - cannot be changed
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    // Update profile data (phone number is not updated)
    _userProfile['firstName'] = firstName;
    _userProfile['lastName'] = lastName;
    _userProfile['email'] = email;
    // phoneNumber is intentionally not updated

    return {
      'success': true,
      'message': 'Profile updated successfully',
      'data': Map<String, dynamic>.from(_userProfile),
    };
  }

  /// Gets daily revenue data
  Future<List<Map<String, dynamic>>> getDailyRevenue() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List<Map<String, dynamic>>.from(_dailyRevenue);
  }

  /// Gets weekly revenue data
  Future<List<Map<String, dynamic>>> getWeeklyRevenue() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List<Map<String, dynamic>>.from(_weeklyRevenue);
  }

  /// Gets monthly revenue data
  Future<List<Map<String, dynamic>>> getMonthlyRevenue() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List<Map<String, dynamic>>.from(_monthlyRevenue);
  }

  /// Gets yearly revenue data
  Future<List<Map<String, dynamic>>> getYearlyRevenue() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List<Map<String, dynamic>>.from(_yearlyRevenue);
  }

  /// Gets YoY revenue data
  Future<List<Map<String, dynamic>>> getYoYRevenue() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List<Map<String, dynamic>>.from(_yoyRevenue);
  }

  /// Gets daily occupancy data
  Future<List<Map<String, dynamic>>> getDailyOccupancy() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List<Map<String, dynamic>>.from(_dailyOccupancy);
  }

  /// Gets weekly occupancy data
  Future<List<Map<String, dynamic>>> getWeeklyOccupancy() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List<Map<String, dynamic>>.from(_weeklyOccupancy);
  }

  /// Gets monthly occupancy data
  Future<List<Map<String, dynamic>>> getMonthlyOccupancy() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List<Map<String, dynamic>>.from(_monthlyOccupancy);
  }

  /// Gets yearly occupancy data
  Future<List<Map<String, dynamic>>> getYearlyOccupancy() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List<Map<String, dynamic>>.from(_yearlyOccupancy);
  }
}

