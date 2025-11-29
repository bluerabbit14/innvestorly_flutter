import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/RevenueService.dart';

class YoYReportPage extends StatefulWidget {
  const YoYReportPage({super.key});

  @override
  State<YoYReportPage> createState() => _YoYReportPageState();
}

class _YoYReportPageState extends State<YoYReportPage> {
  // Year pair selection (e.g., "2024-2025")
  String _selectedYearPair = '2024-2025';
  
  // Hotel filter (null means "All Hotel")
  String? _selectedHotel;
  
  // Loading state
  bool _isLoading = false;
  
  // YoY data
  List<YoYHotelData> _hotelData = [];
  List<YoYMonthlyData> _monthlyData = [];
  
  // Available hotels and year pairs
  List<String> _availableHotels = [];
  List<String> _availableYearPairs = ['2024-2025', '2023-2024', '2022-2023'];
  
  // Store raw API responses
  List<Map<String, dynamic>> _rawYoYResponse = [];
  List<Map<String, dynamic>> _rawMonthlyResponse = [];
  
  // Flag to check if both years have data
  bool _hasBothYearsData = false;
  
  // Flag to check if any data is available at all
  bool _hasAnyData = false;

  @override
  void initState() {
    super.initState();
    // Set default to "All Hotel"
    _selectedHotel = null;
    // Fetch YoY data on page load
    _fetchYoYData();
  }

  /// Fetches YoY revenue data from API
  Future<void> _fetchYoYData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch YoY monthly data
      final yoyResponse = await RevenueService.getYoYRevenue();
      
      // Fetch yearly revenue data for hotel-wise comparison
      final yearlyResponse = await RevenueService.getYearlyRevenue();
      
      if (mounted) {
        setState(() {
          _rawYoYResponse = yoyResponse;
          _rawMonthlyResponse = yearlyResponse;
          
          // Extract hotel names from yearly response
          _availableHotels = yearlyResponse
              .map((hotelData) => hotelData['hotelName'] as String? ?? '')
              .where((name) => name.isNotEmpty)
              .toList();
          
          // Check if any data is available (meaningful data, not just empty arrays)
          bool hasYoYData = yoyResponse.isNotEmpty && 
              yoyResponse.any((item) => 
                ((item['leftYearRevenue'] as num?)?.toDouble() ?? 0.0) > 0 ||
                ((item['rightYearRevenue'] as num?)?.toDouble() ?? 0.0) > 0);
          
          bool hasYearlyData = yearlyResponse.isNotEmpty && 
              yearlyResponse.any((hotel) {
                final yearWiseData = hotel['yearWiseData'] as List<dynamic>? ?? [];
                return yearWiseData.any((yearData) => 
                  ((yearData['totalGrossRev'] as num?)?.toDouble() ?? 0.0) > 0);
              });
          
          _hasAnyData = hasYoYData || hasYearlyData;
          
          // Process data
          _processYoYData();
          
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

  /// Processes YoY data based on selected hotel and year pair
  void _processYoYData() {
    // Extract years from year pair (e.g., "2024-2025" -> [2024, 2025])
    final years = _selectedYearPair.split('-');
    final leftYear = years[0]; // e.g., "2024"
    final rightYear = years[1]; // e.g., "2025"

    // Process monthly data from YoY API
    // The API returns: month, leftYearRevenue, rightYearRevenue, investorRevenue
    // Create a map to ensure all 12 months are present
    Map<int, YoYMonthlyData> monthlyMap = {};
    
    for (var monthData in _rawYoYResponse) {
      final monthStr = monthData['month'] as String? ?? '';
      final monthIndex = _getMonthIndex(monthStr);
      final leftRevenue = (monthData['leftYearRevenue'] as num?)?.toDouble() ?? 0.0;
      final rightRevenue = (monthData['rightYearRevenue'] as num?)?.toDouble() ?? 0.0;

      monthlyMap[monthIndex] = YoYMonthlyData(
        month: monthIndex,
        revenueYear1: leftRevenue, // Left year (e.g., 2024)
        revenueYear2: rightRevenue, // Right year (e.g., 2025)
      );
    }
    
    // Fill in missing months with zero values
    _monthlyData = List.generate(12, (index) {
      final monthIndex = index + 1;
      if (monthlyMap.containsKey(monthIndex)) {
        return monthlyMap[monthIndex]!;
      }
      return YoYMonthlyData(
        month: monthIndex,
        revenueYear1: 0.0,
        revenueYear2: 0.0,
      );
    });
    
    // Check if both years have data (at least one month with non-zero revenue for each year)
    bool hasLeftYearData = false;
    bool hasRightYearData = false;
    
    for (var monthData in _monthlyData) {
      if (monthData.revenueYear1 > 0) {
        hasLeftYearData = true;
      }
      if (monthData.revenueYear2 > 0) {
        hasRightYearData = true;
      }
      // If both years have data, we can break early
      if (hasLeftYearData && hasRightYearData) {
        break;
      }
    }
    
    _hasBothYearsData = hasLeftYearData && hasRightYearData;

    // Process hotel data from yearly revenue API
    // Extract years from year pair
    final year1 = int.tryParse(leftYear) ?? DateTime.now().year - 1;
    final year2 = int.tryParse(rightYear) ?? DateTime.now().year;

    // Filter by selected hotel if applicable
    List<Map<String, dynamic>> filteredYearlyData = _rawMonthlyResponse;
    if (_selectedHotel != null) {
      filteredYearlyData = _rawMonthlyResponse
          .where((hotel) => (hotel['hotelName'] as String? ?? '') == _selectedHotel)
          .toList();
    }

    // Process hotel-wise data
    _hotelData = filteredYearlyData.map((hotelData) {
      final hotelName = hotelData['hotelName'] as String? ?? '';
      final yearWiseData = hotelData['yearWiseData'] as List<dynamic>? ?? [];
      
      double revenueYear1 = 0.0;
      double revenueYear2 = 0.0;

      // Extract revenue for both years
      for (var yearData in yearWiseData) {
        if (yearData is Map<String, dynamic>) {
          final year = (yearData['year'] as num?)?.toInt();
          final revenue = (yearData['totalGrossRev'] as num?)?.toDouble() ?? 0.0;

          if (year == year1) {
            revenueYear1 = revenue;
          } else if (year == year2) {
            revenueYear2 = revenue;
          }
        }
      }

      // Calculate change percentage
      double changePercent = 0.0;
      if (revenueYear1 > 0) {
        changePercent = ((revenueYear2 - revenueYear1) / revenueYear1) * 100;
      } else if (revenueYear2 > 0) {
        changePercent = 100.0; // New hotel
      }

      return YoYHotelData(
        hotelName: hotelName,
        revenueYear1: revenueYear1,
        revenueYear2: revenueYear2,
        changePercent: changePercent,
      );
    }).toList();

    // Sort hotels by revenue year2 (descending)
    _hotelData.sort((a, b) => b.revenueYear2.compareTo(a.revenueYear2));
  }

  /// Converts month abbreviation to month index (1-12)
  int _getMonthIndex(String monthStr) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final index = months.indexWhere((m) => m.toLowerCase() == monthStr.toLowerCase());
    return index >= 0 ? index + 1 : 1;
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}k';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  String _formatFullCurrency(double amount) {
    // Format with commas (e.g., $1,96,842)
    final parts = amount.toStringAsFixed(0).split('.');
    final integerPart = parts[0];
    String formatted = '';
    int count = 0;
    
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = ',' + formatted;
        count = 0;
      }
      formatted = integerPart[i] + formatted;
      count++;
    }
    
    return '\$$formatted';
  }

  String _getMonthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F2F7),
      appBar: AppBar(
        backgroundColor: Color(0xFFE0F2F7),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'YoY Revenue Report',
          style: TextStyle(
            color: Color(0xFF2C3E50),
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
            : _hasAnyData
                ? SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Two Dropdowns at the top
                        Row(
                          children: [
                            // Year Pair Dropdown (on the right)
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: Color(0xFFBDC3C7), width: 1),
                                ),
                                child: DropdownButton<String>(
                                  value: _selectedYearPair,
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  icon: Icon(Icons.arrow_drop_down, color: Color(0xFF2C3E50)),
                                  items: _availableYearPairs.map((yearPair) {
                                    return DropdownMenuItem<String>(
                                      value: yearPair,
                                      child: Text(
                                        yearPair,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedYearPair = value;
                                        _processYoYData();
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            // Hotel Filter Dropdown
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: Color(0xFFBDC3C7), width: 1),
                                ),
                                child: DropdownButton<String?>(
                                  value: _selectedHotel,
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  icon: Icon(Icons.arrow_drop_down, color: Color(0xFF2C3E50)),
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(
                                        'All Hotel',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                    ),
                                    ..._availableHotels.map((hotel) {
                                      return DropdownMenuItem<String?>(
                                        value: hotel,
                                        child: Text(
                                          hotel,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF2C3E50),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedHotel = value;
                                      _processYoYData();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        
                        // Bar Chart
                        _buildChartSection(),
                        SizedBox(height: 20),
                        
                        // Table Section
                        _buildTableSection(),
                      ],
                    ),
                  )
                : Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart_outlined,
                            size: 64,
                            color: Color(0xFF7F8C8D),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No data available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF2C3E50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please check back later',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildChartSection() {
    if (_monthlyData.isEmpty) {
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
    
    // Check if both years have data for comparison
    if (!_hasBothYearsData) {
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
              'No data available for comparison',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7F8C8D),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Find max revenue for scaling
    final maxRevenue = _monthlyData
        .map((month) => month.revenueYear1 > month.revenueYear2 
            ? month.revenueYear1 
            : month.revenueYear2)
        .reduce((a, b) => a > b ? a : b);

    final maxY = maxRevenue > 0 
        ? ((maxRevenue / 5000000).ceil() * 5000000).toDouble()
        : 20000000.0;

    // Extract years from year pair
    final years = _selectedYearPair.split('-');
    final year1 = years[0];
    final year2 = years[1];

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
          // Chart Title
          Text(
            'YoY Revenue Report',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 16),
          // Chart
          SizedBox(
            height: 350,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                groupsSpace: 8.0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.white,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final monthIndex = group.x.toInt();
                      if (monthIndex >= 0 && monthIndex < _monthlyData.length) {
                        final monthData = _monthlyData[monthIndex];
                        final monthName = _getMonthAbbreviation(monthData.month);
                        
                        String label;
                        double value;
                        Color textColor;
                        
                        if (rodIndex == 0) {
                          label = '$year2 - $monthName';
                          value = monthData.revenueYear2;
                          textColor = Color(0xFF00BCD4); // Light blue
                        } else {
                          label = '$year1 - $monthName';
                          value = monthData.revenueYear1;
                          textColor = Color(0xFF7F8C8D); // Dark grey
                        }
                        
                        return BarTooltipItem(
                          '$label\n${_formatFullCurrency(value)}',
                          TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        );
                      }
                      return BarTooltipItem('', TextStyle());
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
                        if (index >= 0 && index < _monthlyData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _getMonthAbbreviation(_monthlyData[index].month),
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
                      interval: maxY / 4,
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Color(0xFFECF0F1),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                  checkToShowHorizontalLine: (value) {
                    return value % (maxY / 4) == 0;
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFBDC3C7), width: 1),
                    left: BorderSide(color: Color(0xFFBDC3C7), width: 1),
                  ),
                ),
                barGroups: _monthlyData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final monthData = entry.value;
                  
                  return BarChartGroupData(
                    x: index,
                    groupVertically: false,
                    barRods: [
                      // Right Year (e.g., 2025) - Light blue
                      BarChartRodData(
                        fromY: 0,
                        toY: monthData.revenueYear2,
                        color: Color(0xFF00BCD4), // Light blue
                        width: 18,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      // Left Year (e.g., 2024) - Dark grey
                      BarChartRodData(
                        fromY: 0,
                        toY: monthData.revenueYear1,
                        color: Color(0xFF7F8C8D), // Dark grey
                        width: 18,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(year2, Color(0xFF00BCD4)), // Light blue
              const SizedBox(width: 24),
              _buildLegendItem(year1, Color(0xFF7F8C8D)), // Dark grey
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
    if (_hotelData.isEmpty) {
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
    
    // Check if both years have data for comparison in hotel data
    bool hasBothYearsInTable = false;
    for (var hotel in _hotelData) {
      if (hotel.revenueYear1 > 0 && hotel.revenueYear2 > 0) {
        hasBothYearsInTable = true;
        break;
      }
    }
    
    // If no hotel has data for both years, show error message
    if (!hasBothYearsInTable && _hotelData.isNotEmpty) {
      // Check if at least one hotel has data for one year
      bool hasAnyData = _hotelData.any((hotel) => 
        hotel.revenueYear1 > 0 || hotel.revenueYear2 > 0);
      
      if (hasAnyData && !hasBothYearsInTable) {
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
                'No data available for comparison',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7F8C8D),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }
    }

    // Extract years from year pair
    final years = _selectedYearPair.split('-');
    final year1 = years[0];
    final year2 = years[1];

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
                    'Hotel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '$year2 Revenue',
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
                    '$year1 Revenue',
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
                    'Change',
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
          ..._hotelData.asMap().entries.map((entry) {
            final index = entry.key;
            final hotel = entry.value;
            final isLast = index == _hotelData.length - 1;
            
            // Truncate hotel name if too long
            String hotelName = hotel.hotelName;
            if (hotelName.length > 20) {
              hotelName = '${hotelName.substring(0, 17)}...';
            }
            
            // Format change percentage
            String changeText;
            if (hotel.revenueYear1 == 0 && hotel.revenueYear2 > 0) {
              changeText = 'N/A';
            } else {
              changeText = '${hotel.changePercent.toStringAsFixed(1)}%';
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
                      hotelName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _formatFullCurrency(hotel.revenueYear2),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _formatFullCurrency(hotel.revenueYear1),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      changeText,
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

// Data model for YoY monthly data
class YoYMonthlyData {
  final int month;
  final double revenueYear1;
  final double revenueYear2;

  YoYMonthlyData({
    required this.month,
    required this.revenueYear1,
    required this.revenueYear2,
  });
}

// Data model for YoY hotel data
class YoYHotelData {
  final String hotelName;
  final double revenueYear1;
  final double revenueYear2;
  final double changePercent;

  YoYHotelData({
    required this.hotelName,
    required this.revenueYear1,
    required this.revenueYear2,
    required this.changePercent,
  });
}
