import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/OccupancyService.dart';

class OccupancyPage extends StatefulWidget {
  const OccupancyPage({super.key});

  @override
  State<OccupancyPage> createState() => _OccupancyPageState();
}

class _OccupancyPageState extends State<OccupancyPage> {
  // Time period selection
  String _selectedPeriod = 'Daily'; // Daily, Weekly, Monthly, Yearly
  
  // Dropdown values
  String? _selectedMonth;
  String? _selectedYear;
  
  // Selected month data (hotels for selected month)
  List<HotelOccupancy> _selectedMonthHotelData = [];
  
  // Loading state
  bool _isLoading = false;
  
  // Occupancy data
  List<HotelOccupancy> _hotelData = [];
  
  // Monthly occupancy data (aggregated by month)
  List<MonthOccupancy> _monthlyData = [];
  
  // List of month names from API response
  List<String> _availableMonths = [];
  
  // Store raw monthly API response for filtering
  List<Map<String, dynamic>> _rawMonthlyResponse = [];
  
  // Yearly occupancy data
  List<YearOccupancy> _yearlyData = [];
  
  // Store raw yearly API response for filtering
  List<Map<String, dynamic>> _rawYearlyResponse = [];
  
  // Selected hotel for yearly view (null means "All Hotels")
  String? _selectedHotel;
  
  // List of available hotels from yearly API response
  List<String> _availableHotels = [];

  // Calculate totals and occupancy rate
  double get _totalRooms {
    if (_selectedPeriod == 'Monthly') {
      if (_selectedMonth != null && _selectedMonthHotelData.isNotEmpty) {
        return _selectedMonthHotelData.fold(0.0, (sum, hotel) => sum + hotel.totalRooms);
      }
      return _monthlyData.fold(0.0, (sum, month) => sum + month.totalRooms);
    } else if (_selectedPeriod == 'Yearly') {
      return _yearlyData.fold(0.0, (sum, year) => sum + year.totalRooms);
    }
    return _hotelData.fold(0.0, (sum, hotel) => sum + hotel.totalRooms);
  }

  double get _occupiedRooms {
    if (_selectedPeriod == 'Monthly') {
      if (_selectedMonth != null && _selectedMonthHotelData.isNotEmpty) {
        return _selectedMonthHotelData.fold(0.0, (sum, hotel) => sum + hotel.occupiedRooms);
      }
      return _monthlyData.fold(0.0, (sum, month) => sum + month.occupiedRooms);
    } else if (_selectedPeriod == 'Yearly') {
      return _yearlyData.fold(0.0, (sum, year) => sum + year.occupiedRooms);
    }
    return _hotelData.fold(0.0, (sum, hotel) => sum + hotel.occupiedRooms);
  }

  // Calculate occupancy rate: (occupied / total) * 100
  double get _occupancyRate {
    if (_totalRooms > 0) {
      return (_occupiedRooms / _totalRooms) * 100;
    }
    return 0.0;
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
    // Load daily occupancy data on page load
    _fetchDailyOccupancy();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call daily API each time the widget is loaded/becomes visible
    if (_selectedPeriod == 'Daily' && !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedPeriod == 'Daily' && !_isLoading) {
          _fetchDailyOccupancy();
        }
      });
    }
  }

  String _formatNumber(double number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toStringAsFixed(0);
  }

  String _formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Gets the current month abbreviation (Jan, Feb, Mar, etc.)
  String _getCurrentMonthAbbreviation() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[now.month - 1];
  }

  /// Converts API response to HotelOccupancy model
  HotelOccupancy _convertApiDataToHotelOccupancy(Map<String, dynamic> apiData) {
    final hotelName = apiData['hotelName'] as String? ?? '';
    
    // Use hotelShortName from API if available, otherwise generate it
    String shortName = apiData['hotelShortName'] as String? ?? '';
    if (shortName.isEmpty && hotelName.isNotEmpty) {
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
    
    return HotelOccupancy(
      shortName: shortName,
      fullName: fullName,
      totalRooms: (apiData['totalRooms'] as num?)?.toDouble() ?? 0.0,
      occupiedRooms: (apiData['occupiedRooms'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Fetches daily occupancy data from API
  Future<void> _fetchDailyOccupancy() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await OccupancyService.getDailyOccupancy();
      
      if (mounted) {
        setState(() {
          _hotelData = response.map((data) => _convertApiDataToHotelOccupancy(data)).toList();
          _monthlyData = [];
          _yearlyData = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
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

  /// Fetches weekly occupancy data from API
  Future<void> _fetchWeeklyOccupancy() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await OccupancyService.getWeeklyOccupancy();
      
      if (mounted) {
        setState(() {
          _hotelData = response.map((data) => _convertApiDataToHotelOccupancy(data)).toList();
          _monthlyData = [];
          _yearlyData = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
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

  /// Fetches monthly occupancy data from API
  Future<void> _fetchMonthlyOccupancy() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await OccupancyService.getMonthlyOccupancy();
      
      if (mounted) {
        setState(() {
          _rawMonthlyResponse = response;
          
          _availableMonths = response
              .map((monthData) => monthData['monthName'] as String? ?? '')
              .where((name) => name.isNotEmpty)
              .toList();
          
          if (_availableMonths.isNotEmpty) {
            final currentMonth = _getCurrentMonthAbbreviation();
            if (_availableMonths.contains(currentMonth)) {
              _selectedMonth = currentMonth;
            } else {
              _selectedMonth = _availableMonths.first;
            }
          }
          
          _monthlyData = response.map((monthData) {
            final monthName = monthData['monthName'] as String? ?? '';
            final monthOccupancy = monthData['monthOccupancy'] as List<dynamic>? ?? [];
            
            double totalRooms = 0.0;
            double occupiedRooms = 0.0;
            
            for (var hotelData in monthOccupancy) {
              if (hotelData is Map<String, dynamic>) {
                totalRooms += (hotelData['totalRooms'] as num?)?.toDouble() ?? 0.0;
                occupiedRooms += (hotelData['occupiedRooms'] as num?)?.toDouble() ?? 0.0;
              }
            }
            
            return MonthOccupancy(
              monthName: monthName,
              totalRooms: totalRooms,
              occupiedRooms: occupiedRooms,
            );
          }).toList();
          
          _hotelData = [];
          _loadSelectedMonthData();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
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

  /// Fetches yearly occupancy data from API
  Future<void> _fetchYearlyOccupancy() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await OccupancyService.getYearlyOccupancy();
      
      if (mounted) {
        setState(() {
          _rawYearlyResponse = response;
          
          _availableHotels = response
              .map((hotelData) => hotelData['hotelName'] as String? ?? '')
              .where((name) => name.isNotEmpty)
              .toList();
          
          _selectedHotel = null; // Default to "All Hotels"
          
          _loadYearlyData();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
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
        double totalRooms = 0.0;
        double occupiedRooms = 0.0;
        
        for (var hotelData in _rawYearlyResponse) {
          final yearWiseData = hotelData['yearWiseData'] as List<dynamic>? ?? [];
          for (var yearData in yearWiseData) {
            if (yearData is Map<String, dynamic>) {
              final dataYear = (yearData['year'] as num?)?.toInt();
              if (dataYear == year) {
                totalRooms += (yearData['totalRooms'] as num?)?.toDouble() ?? 0.0;
                occupiedRooms += (yearData['occupiedRooms'] as num?)?.toDouble() ?? 0.0;
              }
            }
          }
        }
        
        return YearOccupancy(
          year: year,
          totalRooms: totalRooms,
          occupiedRooms: occupiedRooms,
        );
      }).toList();
    } else {
      // Selected hotel
      final selectedHotelData = _rawYearlyResponse.firstWhere(
        (hotelData) => (hotelData['hotelName'] as String? ?? '') == _selectedHotel,
        orElse: () => <String, dynamic>{},
      );
      
      if (selectedHotelData.isEmpty) {
        _yearlyData = [];
        return;
      }
      
      final yearWiseData = selectedHotelData['yearWiseData'] as List<dynamic>? ?? [];
      
      _yearlyData = yearWiseData.map((yearData) {
        if (yearData is Map<String, dynamic>) {
          return YearOccupancy(
            year: (yearData['year'] as num?)?.toInt() ?? 0,
            totalRooms: (yearData['totalRooms'] as num?)?.toDouble() ?? 0.0,
            occupiedRooms: (yearData['occupiedRooms'] as num?)?.toDouble() ?? 0.0,
          );
        }
        return null;
      }).whereType<YearOccupancy>().toList();
      
      _yearlyData.sort((a, b) => a.year.compareTo(b.year));
    }
  }

  /// Loads hotel data for the selected month
  void _loadSelectedMonthData() {
    if (_selectedMonth == null || _rawMonthlyResponse.isEmpty) {
      _selectedMonthHotelData = [];
      return;
    }
    
    final selectedMonthData = _rawMonthlyResponse.firstWhere(
      (monthData) => (monthData['monthName'] as String? ?? '') == _selectedMonth,
      orElse: () => <String, dynamic>{},
    );
    
    if (selectedMonthData.isEmpty) {
      _selectedMonthHotelData = [];
      return;
    }
    
    final monthOccupancy = selectedMonthData['monthOccupancy'] as List<dynamic>? ?? [];
    
    _selectedMonthHotelData = monthOccupancy.map((hotelData) {
      if (hotelData is Map<String, dynamic>) {
        return _convertApiDataToHotelOccupancy(hotelData);
      }
      return null;
    }).whereType<HotelOccupancy>().toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Occupancy',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
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

                    // 3 Statistic Fields (Occupancy Rate, Total Rooms, Occupied)
                    _buildStatisticsSection(),
                    const SizedBox(height: 20),

                    // Dropdown Box (for Monthly/Yearly)
                    if (_selectedPeriod == 'Monthly' || _selectedPeriod == 'Yearly')
                      _buildDropdownSection(),
                    if (_selectedPeriod == 'Monthly' || _selectedPeriod == 'Yearly')
                      const SizedBox(height: 20),

                    // Bar Chart
                    _buildChartSection(),
                    const SizedBox(height: 20),

                    // Table Section
                    _buildTableSection(),
                  ],
                ),
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
                
                // Call API when button is clicked
                if (period == 'Daily') {
                  _fetchDailyOccupancy();
                } else if (period == 'Weekly') {
                  _fetchWeeklyOccupancy();
                } else if (period == 'Monthly') {
                  _fetchMonthlyOccupancy();
                } else if (period == 'Yearly') {
                  _fetchYearlyOccupancy();
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
            label: 'Occupancy Rate',
            value: _formatPercentage(_occupancyRate),
            color: Color(0xFF00BCD4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatisticCard(
            label: 'Total Rooms',
            value: _formatNumber(_totalRooms),
            color: Color(0xFF9C27B0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatisticCard(
            label: 'Occupied',
            value: _formatNumber(_occupiedRooms),
            color: Color(0xFFE91E63),
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
              fontSize: 12,
              color: Color(0xFF7F8C8D),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
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
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 14,
            ),
            icon: Icon(Icons.arrow_drop_down, color: Color(0xFF2C3E50)),
            dropdownColor: Colors.white,
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
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
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
    
    // Find max occupancy percentage for scaling (0-100%)
    final maxOccupancy = 100.0;
    
    // Calculate dynamic bar width
    final dataCount = (displayData as List).length;
    double barWidth;
    if (dataCount <= 3) {
      barWidth = 35.0;
    } else if (dataCount <= 5) {
      barWidth = 28.0;
    } else if (dataCount <= 8) {
      barWidth = 22.0;
    } else if (dataCount <= 12) {
      barWidth = 18.0;
    } else {
      barWidth = 15.0;
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
                maxY: maxOccupancy,
                minY: 0,
                groupsSpace: dataCount > 8 ? 8.0 : 12.0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => theme.colorScheme.surface,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final index = group.x.toInt();
                      String label;
                      double totalRooms;
                      double occupiedRooms;
                      double occupancy;
                      
                      if (isYearlyData) {
                        final yearData = (displayData as List<YearOccupancy>)[index];
                        label = yearData.year.toString();
                        totalRooms = yearData.totalRooms;
                        occupiedRooms = yearData.occupiedRooms;
                        occupancy = totalRooms > 0 
                            ? (occupiedRooms / totalRooms) * 100 
                            : 0.0;
                      } else {
                        final hotel = (displayData as List<HotelOccupancy>)[index];
                        label = hotel.fullName;
                        totalRooms = hotel.totalRooms;
                        occupiedRooms = hotel.occupiedRooms;
                        occupancy = totalRooms > 0 
                            ? (occupiedRooms / totalRooms) * 100 
                            : 0.0;
                      }
                      
                      return BarTooltipItem(
                        isYearlyData 
                            ? 'Year:\n$label\n\n'
                              'Total Rooms:\n${_formatNumber(totalRooms)}\n\n'
                              'Occupied Rooms:\n${_formatNumber(occupiedRooms)}\n\n'
                              'Occupancy Rate:\n${_formatPercentage(occupancy)}'
                            : 'Hotel Name:\n$label\n\n'
                              'Total Rooms:\n${_formatNumber(totalRooms)}\n\n'
                              'Occupied Rooms:\n${_formatNumber(occupiedRooms)}\n\n'
                              'Occupancy Rate:\n${_formatPercentage(occupancy)}',
                        TextStyle(
                          color: isDark 
                              ? theme.colorScheme.onSurface
                              : Color(0xFF265984),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          height: 1.5,
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
                          String label;
                          if (isYearlyData) {
                            final yearData = (displayData as List<YearOccupancy>)[index];
                            label = yearData.year.toString();
                          } else {
                            final hotel = (displayData as List<HotelOccupancy>)[index];
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
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: Color(0xFF7F8C8D),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                      interval: 20,
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Color(0xFFECF0F1),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
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
                  
                  double occupancyPercentage;
                  if (isYearlyData) {
                    final yearData = item as YearOccupancy;
                    occupancyPercentage = yearData.totalRooms > 0 
                        ? (yearData.occupiedRooms / yearData.totalRooms) * 100 
                        : 0.0;
                  } else {
                    final hotel = item as HotelOccupancy;
                    occupancyPercentage = hotel.totalRooms > 0 
                        ? (hotel.occupiedRooms / hotel.totalRooms) * 100 
                        : 0.0;
                  }
                  
                  return BarChartGroupData(
                    x: index,
                    groupVertically: false,
                    barRods: [
                      BarChartRodData(
                        fromY: 0,
                        toY: occupancyPercentage,
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
              _buildLegendItem('Occupancy Rate', Color(0xFF265984)),
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
                    'Total Rooms',
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
                    'Occupied',
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
                    'Occu. (%)',
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
            double totalRooms;
            double occupiedRooms;
            double occupancyPercentage;
            
            if (isYearlyData) {
              final yearData = item as YearOccupancy;
              nameLabel = yearData.year.toString();
              totalRooms = yearData.totalRooms;
              occupiedRooms = yearData.occupiedRooms;
              occupancyPercentage = totalRooms > 0 
                  ? (occupiedRooms / totalRooms) * 100 
                  : 0.0;
            } else {
              final hotel = item as HotelOccupancy;
              nameLabel = hotel.fullName;
              totalRooms = hotel.totalRooms;
              occupiedRooms = hotel.occupiedRooms;
              occupancyPercentage = totalRooms > 0 
                  ? (occupiedRooms / totalRooms) * 100 
                  : 0.0;
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
                      _formatNumber(totalRooms),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _formatNumber(occupiedRooms),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _formatPercentage(occupancyPercentage),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF265984),
                        fontWeight: FontWeight.w600,
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

// Data models for occupancy
class HotelOccupancy {
  final String shortName;
  final String fullName;
  final double totalRooms;
  final double occupiedRooms;

  HotelOccupancy({
    required this.shortName,
    required this.fullName,
    required this.totalRooms,
    required this.occupiedRooms,
  });
}

class MonthOccupancy {
  final String monthName;
  final double totalRooms;
  final double occupiedRooms;

  MonthOccupancy({
    required this.monthName,
    required this.totalRooms,
    required this.occupiedRooms,
  });
}

class YearOccupancy {
  final int year;
  final double totalRooms;
  final double occupiedRooms;

  YearOccupancy({
    required this.year,
    required this.totalRooms,
    required this.occupiedRooms,
  });
}
