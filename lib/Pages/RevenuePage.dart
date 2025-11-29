import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/RevenueService.dart';

class RevenuePage extends StatefulWidget {
  const RevenuePage({super.key});

  @override
  State<RevenuePage> createState() => _RevenuePageState();
}

class _RevenuePageState extends State<RevenuePage> {
  // Time period selection
  String _selectedPeriod = 'Daily'; // Daily, Weekly, Monthly, Yearly
  
  // Dropdown values
  String? _selectedMonth;
  String? _selectedYear;
  
  // Selected month data (hotels for selected month)
  List<HotelRevenue> _selectedMonthHotelData = [];
  
  // Loading state
  bool _isLoading = false;
  
  // Sample data - this will be replaced with dynamic data from API
  List<HotelRevenue> _hotelData = [];
  
  // Monthly revenue data (aggregated by month)
  List<MonthRevenue> _monthlyData = [];
  
  // List of month names from API response
  List<String> _availableMonths = [];
  
  // Store raw monthly API response for filtering
  List<Map<String, dynamic>> _rawMonthlyResponse = [];
  
  // Yearly revenue data
  List<YearRevenue> _yearlyData = [];
  
  // Store raw yearly API response for filtering
  List<Map<String, dynamic>> _rawYearlyResponse = [];
  
  // Selected hotel for yearly view (null means "All Hotels")
  String? _selectedHotel;
  
  // List of available hotels from yearly API response
  List<String> _availableHotels = [];

  // Calculate totals
  double get _totalGrossRevenue {
    if (_selectedPeriod == 'Monthly') {
      if (_selectedMonth != null && _selectedMonthHotelData.isNotEmpty) {
        return _selectedMonthHotelData.fold(0.0, (sum, hotel) => sum + hotel.totalRevenue);
      }
      return _monthlyData.fold(0.0, (sum, month) => sum + month.totalRevenue);
    } else if (_selectedPeriod == 'Yearly') {
      return _yearlyData.fold(0.0, (sum, year) => sum + year.totalRevenue);
    }
    return _hotelData.fold(0.0, (sum, hotel) => sum + hotel.totalRevenue);
  }

  double get _myGrossShare {
    if (_selectedPeriod == 'Monthly') {
      if (_selectedMonth != null && _selectedMonthHotelData.isNotEmpty) {
        return _selectedMonthHotelData.fold(0.0, (sum, hotel) => sum + hotel.yourShare);
      }
      return _monthlyData.fold(0.0, (sum, month) => sum + month.yourShare);
    } else if (_selectedPeriod == 'Yearly') {
      return _yearlyData.fold(0.0, (sum, year) => sum + year.yourShare);
    }
    return _hotelData.fold(0.0, (sum, hotel) => sum + hotel.yourShare);
  }

  // Month options
  final List<String> _months = [
    'Jan 2025', 'Feb 2025', 'Mar 2025', 'Apr 2025',
    'May 2025', 'Jun 2025', 'Jul 2025', 'Aug 2025',
    'Sep 2025', 'Oct 2025', 'Nov 2025', 'Dec 2025'
  ];

  // Year options
  final List<String> _years = [
    '2025', '2024', '2023', '2022', '2021'
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = '2025';
    // Load daily revenue data on page load
    _fetchDailyRevenue();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call daily API each time the widget is loaded/becomes visible
    // This ensures fresh data when navigating back to the page or when tab is switched
    if (_selectedPeriod == 'Daily' && !_isLoading) {
      // Use WidgetsBinding to ensure this runs after the first frame
      // This prevents calling it multiple times in the same build cycle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedPeriod == 'Daily' && !_isLoading) {
          _fetchDailyRevenue();
        }
      });
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}k';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  String _formatFullCurrency(double amount) {
    return '\$${amount.toStringAsFixed(0)}';
  }

  /// Gets the current month abbreviation (Jan, Feb, Mar, etc.)
  String _getCurrentMonthAbbreviation() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[now.month - 1];
  }

  /// Converts API response to HotelRevenue model
  HotelRevenue _convertApiDataToHotelRevenue(Map<String, dynamic> apiData) {
    final hotelName = apiData['hotelName'] as String? ?? '';
    
    // Generate short name from hotel name (first 4-5 uppercase letters)
    String shortName = '';
    if (hotelName.isNotEmpty) {
      final words = hotelName.split(' ');
      if (words.length >= 2) {
        shortName = words.take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
      } else {
        shortName = hotelName.length >= 5 
            ? hotelName.substring(0, 5).toUpperCase() 
            : hotelName.toUpperCase();
      }
    }
    
    // Truncate full name if too long
    String fullName = hotelName.length > 20 
        ? '${hotelName.substring(0, 17)}...' 
        : hotelName;
    
    return HotelRevenue(
      shortName: shortName,
      fullName: fullName,
      totalRevenue: (apiData['totalGrossRev'] as num?)?.toDouble() ?? 0.0,
      investmentPercentage: (apiData['myPercentageShare'] as num?)?.toDouble() ?? 0.0,
      yourShare: (apiData['myGrossShare'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Fetches daily revenue data from API
  Future<void> _fetchDailyRevenue() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await RevenueService.getDailyRevenue();
      
      if (mounted) {
        setState(() {
          _hotelData = response.map((data) => _convertApiDataToHotelRevenue(data)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Fetches weekly revenue data from API
  Future<void> _fetchWeeklyRevenue() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await RevenueService.getWeeklyRevenue();
      
      if (mounted) {
        setState(() {
          _hotelData = response.map((data) => _convertApiDataToHotelRevenue(data)).toList();
          _monthlyData = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Fetches monthly revenue data from API
  Future<void> _fetchMonthlyRevenue() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await RevenueService.getMonthlyRevenue();
      
      if (mounted) {
        setState(() {
          // Store raw response for filtering
          _rawMonthlyResponse = response;
          
          // Extract month names from response
          _availableMonths = response
              .map((monthData) => monthData['monthName'] as String? ?? '')
              .where((name) => name.isNotEmpty)
              .toList();
          
          // Set selected month to current month if available, otherwise first available month
          if (_availableMonths.isNotEmpty) {
            final currentMonth = _getCurrentMonthAbbreviation();
            if (_availableMonths.contains(currentMonth)) {
              _selectedMonth = currentMonth;
            } else {
              _selectedMonth = _availableMonths.first;
            }
          }
          
          // Transform monthly API response to MonthRevenue list
          _monthlyData = response.map((monthData) {
            final monthName = monthData['monthName'] as String? ?? '';
            final monthWiseData = monthData['monthWiseData'] as List<dynamic>? ?? [];
            
            // Aggregate all hotels' data for this month
            double totalRevenue = 0.0;
            double totalYourShare = 0.0;
            double totalInvestmentPercentage = 0.0;
            int hotelCount = 0;
            
            for (var hotelData in monthWiseData) {
              if (hotelData is Map<String, dynamic>) {
                totalRevenue += (hotelData['totalGrossRev'] as num?)?.toDouble() ?? 0.0;
                totalYourShare += (hotelData['myGrossShare'] as num?)?.toDouble() ?? 0.0;
                totalInvestmentPercentage += (hotelData['myPercentageShare'] as num?)?.toDouble() ?? 0.0;
                hotelCount++;
              }
            }
            
            // Calculate average investment percentage
            double avgInvestmentPercentage = hotelCount > 0 
                ? totalInvestmentPercentage / hotelCount 
                : 0.0;
            
            return MonthRevenue(
              monthName: monthName,
              totalRevenue: totalRevenue,
              yourShare: totalYourShare,
              investmentPercentage: avgInvestmentPercentage,
            );
          }).toList();
          
          _hotelData = [];
          
          // Load selected month's hotel data
          _loadSelectedMonthData();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  /// Fetches yearly revenue data from API
  Future<void> _fetchYearlyRevenue() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await RevenueService.getYearlyRevenue();
      
      if (mounted) {
        setState(() {
          // Store raw response for filtering
          _rawYearlyResponse = response;
          
          // Extract hotel names from response
          _availableHotels = response
              .map((hotelData) => hotelData['hotelName'] as String? ?? '')
              .where((name) => name.isNotEmpty)
              .toList();
          
          // Set selected hotel to "All Hotels" by default
          _selectedHotel = null;
          
          // Load all hotels data (cumulative)
          _loadYearlyData();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  /// Loads yearly data based on selected hotel (null = All Hotels)
  void _loadYearlyData() {
    if (_rawYearlyResponse.isEmpty) {
      _yearlyData = [];
      return;
    }
    
    // Get all unique years from all hotels
    Set<int> allYears = {};
    for (var hotelData in _rawYearlyResponse) {
      final yearWiseData = hotelData['yearWiseData'] as List<dynamic>? ?? [];
      for (var yearData in yearWiseData) {
        if (yearData is Map<String, dynamic>) {
          final year = (yearData['year'] as num?)?.toInt();
          if (year != null) {
            allYears.add(year);
          }
        }
      }
    }
    
    final sortedYears = allYears.toList()..sort();
    
    if (_selectedHotel == null) {
      // All Hotels - aggregate data by year
      _yearlyData = sortedYears.map((year) {
        double totalRevenue = 0.0;
        double totalYourShare = 0.0;
        
        // Sum up all hotels' data for this year
        for (var hotelData in _rawYearlyResponse) {
          final yearWiseData = hotelData['yearWiseData'] as List<dynamic>? ?? [];
          for (var yearData in yearWiseData) {
            if (yearData is Map<String, dynamic>) {
              final dataYear = (yearData['year'] as num?)?.toInt();
              if (dataYear == year) {
                totalRevenue += (yearData['totalGrossRev'] as num?)?.toDouble() ?? 0.0;
                totalYourShare += (yearData['myGrossShare'] as num?)?.toDouble() ?? 0.0;
              }
            }
          }
        }
        
        return YearRevenue(
          year: year,
          totalRevenue: totalRevenue,
          yourShare: totalYourShare,
        );
      }).toList();
    } else {
      // Selected hotel - show only that hotel's data
      final selectedHotelData = _rawYearlyResponse.firstWhere(
        (hotelData) => (hotelData['hotelName'] as String? ?? '') == _selectedHotel,
        orElse: () => <String, dynamic>{},
      );
      
      if (selectedHotelData.isEmpty) {
        _yearlyData = [];
        return;
      }
      
      final yearWiseData = selectedHotelData['yearWiseData'] as List<dynamic>? ?? [];
      
      // Create YearRevenue list from yearWiseData
      _yearlyData = yearWiseData.map((yearData) {
        if (yearData is Map<String, dynamic>) {
          return YearRevenue(
            year: (yearData['year'] as num?)?.toInt() ?? 0,
            totalRevenue: (yearData['totalGrossRev'] as num?)?.toDouble() ?? 0.0,
            yourShare: (yearData['myGrossShare'] as num?)?.toDouble() ?? 0.0,
          );
        }
        return null;
      }).whereType<YearRevenue>().toList();
      
      // Sort by year
      _yearlyData.sort((a, b) => a.year.compareTo(b.year));
    }
  }

  /// Loads hotel data for the selected month
  void _loadSelectedMonthData() {
    if (_selectedMonth == null || _rawMonthlyResponse.isEmpty) {
      _selectedMonthHotelData = [];
      return;
    }
    
    // Find the selected month's data
    final selectedMonthData = _rawMonthlyResponse.firstWhere(
      (monthData) => (monthData['monthName'] as String? ?? '') == _selectedMonth,
      orElse: () => <String, dynamic>{},
    );
    
    if (selectedMonthData.isEmpty) {
      _selectedMonthHotelData = [];
      return;
    }
    
    final monthWiseData = selectedMonthData['monthWiseData'] as List<dynamic>? ?? [];
    
    // Convert to HotelRevenue list
    _selectedMonthHotelData = monthWiseData.map((hotelData) {
      if (hotelData is Map<String, dynamic>) {
        return _convertApiDataToHotelRevenue(hotelData);
      }
      return null;
    }).whereType<HotelRevenue>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F2F7),
      body: SafeArea(
          child: Column(
            children: [
            // Header with Logo
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/innvestorly_logo.png',
                    height: 45,
                    width: 45,
                  ),
                ],
              ),
            ),
            // Revenue Content (scrollable)
            Expanded(
              child: _isLoading
                  ? Center(
                      child: SpinKitFadingCircle(
                        color: Color(0xFF00BCD4),
                        size: 50.0,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 4 Time Period Buttons
                          _buildTimePeriodButtons(),
                          const SizedBox(height: 20),

                          // 2 Statistic Fields
                          _buildStatisticsSection(),
                          const SizedBox(height: 20),

                          // Dropdown Box (for Monthly/Yearly)
                          if (_selectedPeriod == 'Monthly' || _selectedPeriod == 'Yearly')
                            _buildDropdownSection(),
                          if (_selectedPeriod == 'Monthly' || _selectedPeriod == 'Yearly')
                            const SizedBox(height: 20),

                          // Horizontal Bar Chart
                          _buildChartSection(),
                          const SizedBox(height: 20),

                          // Static Table Section
                          _buildTableSection(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePeriodButtons() {
    final periods = ['Daily', 'Weekly', 'Monthly', 'Yearly'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: periods.map((period) {
        final isSelected = _selectedPeriod == period;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedPeriod = period;
                });
                
                // Call API when Daily, Weekly, Monthly, or Yearly button is clicked
                if (period == 'Daily') {
                  _fetchDailyRevenue();
                } else if (period == 'Weekly') {
                  _fetchWeeklyRevenue();
                } else if (period == 'Monthly') {
                  _fetchMonthlyRevenue();
                } else if (period == 'Yearly') {
                  _fetchYearlyRevenue();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected 
                    ? Color(0xFF00BCD4) 
                    : Colors.white,
                foregroundColor: isSelected 
                    ? Colors.white 
                    : Color(0xFF2C3E50),
                elevation: isSelected ? 2 : 0,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                period,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatisticsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatisticCard(
            label: 'Total Gross Rev',
            value: _formatFullCurrency(_totalGrossRevenue),
            color: Color(0xFF00BCD4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatisticCard(
            label: 'My Gross Share',
            value: _formatFullCurrency(_myGrossShare),
            color: Color(0xFF265984),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Color(0xFFBDC3C7), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedPeriod == 'Monthly' ? 'Month' : 'Hotel',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2C3E50),
            ),
          ),
          DropdownButton<String?>(
            value: _selectedPeriod == 'Monthly' 
                ? _selectedMonth 
                : _selectedHotel,
            underline: SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: Color(0xFF2C3E50)),
            items: _selectedPeriod == 'Monthly'
                ? (_availableMonths.isNotEmpty ? _availableMonths : _months)
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ))
                    .toList()
                : [
                    // Add "All Hotels" option first
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        'All Hotels',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                    // Add individual hotels
                    ...(_availableHotels.isNotEmpty ? _availableHotels : [])
                        .map((hotel) => DropdownMenuItem<String?>(
                              value: hotel,
                              child: Text(
                                hotel,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ))
                        .toList(),
                  ],
            onChanged: (value) {
              setState(() {
                if (_selectedPeriod == 'Monthly') {
                  _selectedMonth = value;
                  _loadSelectedMonthData();
                } else {
                  _selectedHotel = value;
                  _loadYearlyData();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    // Get data based on period
    dynamic displayData;
    bool isYearlyData = false;
    
    if (_selectedPeriod == 'Monthly') {
      displayData = _selectedMonthHotelData;
    } else if (_selectedPeriod == 'Yearly') {
      displayData = _yearlyData;
      isYearlyData = true;
    } else {
      displayData = _hotelData;
    }
    
    // Handle empty data
    if (displayData == null || (displayData is List && displayData.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              'No data available',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ),
        ),
      );
    }
    
    // Find max revenue for scaling
    final maxRevenue = (displayData as List)
        .map((item) => isYearlyData 
            ? (item as YearRevenue).totalRevenue 
            : (item as HotelRevenue).totalRevenue)
        .reduce((a, b) => a > b ? a : b);
    
    final maxY = maxRevenue > 0 
        ? ((maxRevenue / 100000).ceil() * 100000).toDouble()
        : 100000.0;
    
    // Calculate dynamic bar width based on number of entries
    // More entries = narrower bars, fewer entries = wider bars
    // Reduced width ratio for narrower bars
    final dataCount = (displayData as List).length;
    double barWidth;
    if (dataCount <= 3) {
      barWidth = 35.0; // Reduced from 50.0
    } else if (dataCount <= 5) {
      barWidth = 28.0; // Reduced from 40.0
    } else if (dataCount <= 8) {
      barWidth = 22.0; // Reduced from 30.0
    } else if (dataCount <= 12) {
      barWidth = 18.0; // Reduced from 25.0
    } else {
      barWidth = 15.0; // Reduced from 20.0
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart
          SizedBox(
            height: 350,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                groupsSpace: dataCount > 8 ? 8.0 : 12.0, // Less space when many entries
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.white,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final index = group.x.toInt();
                      String category;
                      double value;
                      Color textColor;
                      String label;
                      
                      if (isYearlyData) {
                        final yearData = (displayData as List<YearRevenue>)[index];
                        label = 'Year ${yearData.year}';
                        if (rodIndex == 0) {
                          category = 'TotalShare';
                          value = yearData.totalRevenue;
                          textColor = Color(0xFF00BCD4);
                        } else {
                          category = 'MyGrossShare';
                          value = yearData.yourShare;
                          textColor = Color(0xFF265984);
                        }
                      } else {
                        final hotel = (displayData as List<HotelRevenue>)[index];
                        label = hotel.fullName;
                        if (rodIndex == 0) {
                          category = 'TotalShare';
                          value = hotel.totalRevenue;
                          textColor = Color(0xFF00BCD4);
                        } else {
                          category = 'MyGrossShare';
                          value = hotel.yourShare;
                          textColor = Color(0xFF265984);
                        }
                      }
                      
                      return BarTooltipItem(
                        '$label\n$category: ${_formatFullCurrency(value)}',
                        TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < (displayData as List).length) {
                          // Show years on x-axis when yearly is selected, otherwise show hotel names
                          String label;
                          if (isYearlyData) {
                            final yearData = (displayData as List<YearRevenue>)[index];
                            label = yearData.year.toString();
                          } else {
                            final hotel = (displayData as List<HotelRevenue>)[index];
                            label = hotel.shortName;
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: Color(0xFF2C3E50),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 55,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            _formatCurrency(value),
                            style: TextStyle(
                              color: Color(0xFF7F8C8D),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                      interval: maxY / 6,
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 6,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Color(0xFFECF0F1),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                  checkToShowHorizontalLine: (value) {
                    return value % (maxY / 6) == 0;
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFBDC3C7), width: 1),
                    left: BorderSide(color: Color(0xFFBDC3C7), width: 1),
                  ),
                ),
                barGroups: (displayData as List).asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  
                  // Get revenue values based on data type
                  final totalRev = isYearlyData 
                      ? (item as YearRevenue).totalRevenue 
                      : (item as HotelRevenue).totalRevenue;
                  final yourShare = isYearlyData 
                      ? (item as YearRevenue).yourShare 
                      : (item as HotelRevenue).yourShare;
                  
                  return BarChartGroupData(
                    x: index,
                    groupVertically: false,
                    barRods: [
                      // Total Gross Rev (light blue) - full height background bar
                      BarChartRodData(
                        fromY: 0,
                        toY: totalRev,
                        color: Color(0xFF00BCD4).withOpacity(0.6),
                        width: barWidth,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                      // My Gross Share (darker blue) - overlays on top of Total Gross Rev
                      // This bar goes from 0 to yourShare (which is <= totalRevenue)
                      BarChartRodData(
                        fromY: 0,
                        toY: yourShare,
                        color: Color(0xFF265984),
                        width: barWidth,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Total Gross Rev', Color(0xFF00BCD4)),
              const SizedBox(width: 24),
              _buildLegendItem('My Gross Share', Color(0xFF265984)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildTableSection() {
    // Get data based on period
    dynamic displayData;
    bool isYearlyData = false;
    
    if (_selectedPeriod == 'Monthly') {
      displayData = _selectedMonthHotelData;
    } else if (_selectedPeriod == 'Yearly') {
      displayData = _yearlyData;
      isYearlyData = true;
    } else {
      displayData = _hotelData;
    }
    
    if (displayData == null || (displayData is List && displayData.isEmpty)) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              'No data available',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    isYearlyData ? 'Year' : 'Hotel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Total Rev.',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                if (!isYearlyData)
                  Expanded(
                    child: Text(
                      'Inv(%)',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    'Your Share',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          ...(displayData as List).asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == (displayData as List).length - 1;
            
            String nameLabel;
            double totalRev;
            double yourShare;
            double? investmentPercentage;
            
            if (isYearlyData) {
              final yearData = item as YearRevenue;
              nameLabel = yearData.year.toString();
              totalRev = yearData.totalRevenue;
              yourShare = yearData.yourShare;
              investmentPercentage = null;
            } else {
              final hotel = item as HotelRevenue;
              nameLabel = hotel.fullName;
              totalRev = hotel.totalRevenue;
              yourShare = hotel.yourShare;
              investmentPercentage = hotel.investmentPercentage;
            }
            
            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: isLast
                      ? BorderSide.none
                      : BorderSide(color: Color(0xFFECF0F1), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      nameLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _formatFullCurrency(totalRev),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  if (!isYearlyData && investmentPercentage != null)
                    Expanded(
                      child: Text(
                        '${investmentPercentage.toStringAsFixed(2)}%',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      _formatFullCurrency(yourShare),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

// Data model for hotel revenue
class HotelRevenue {
  final String shortName;
  final String fullName;
  final double totalRevenue;
  final double investmentPercentage;
  final double yourShare;

  HotelRevenue({
    required this.shortName,
    required this.fullName,
    required this.totalRevenue,
    required this.investmentPercentage,
    required this.yourShare,
  });
}

// Data model for monthly revenue (aggregated)
class MonthRevenue {
  final String monthName;
  final double totalRevenue;
  final double yourShare;
  final double investmentPercentage;

  MonthRevenue({
    required this.monthName,
    required this.totalRevenue,
    required this.yourShare,
    required this.investmentPercentage,
  });
}

// Data model for yearly revenue
class YearRevenue {
  final int year;
  final double totalRevenue;
  final double yourShare;

  YearRevenue({
    required this.year,
    required this.totalRevenue,
    required this.yourShare,
  });
}
