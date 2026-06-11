import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/currency_data.dart';
import '../../../../core/services/achievement_tracking_service.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/currency_input_card.dart';
import '../widgets/currency_picker_sheet.dart';
import '../widgets/currency_swap_button.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final _fromCtrl = TextEditingController(text: '1');
  final _toCtrl = TextEditingController();

  String _fromCode = 'USD';
  String _toCode = 'IDR';

  Map<String, dynamic>? _rates;
  bool _loading = true;
  String? _error;
  String? _lastUpdate;
  bool _trackedConversion = false;

  @override
  void initState() {
    super.initState();
    _fromCtrl.addListener(_convert);
    _fetchRates();
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchRates() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await CurrencyService.getRates(_fromCode);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _rates = result['rates'] as Map<String, dynamic>;
        _lastUpdate = result['lastUpdate'] as String?;
        _loading = false;
      });
      _convert();
    } else {
      setState(() {
        _error = result['message'] as String?;
        _loading = false;
      });
    }
  }

  void _convert() {
    if (_rates == null) return;

    final amount = double.tryParse(_fromCtrl.text) ?? 0;
    final rate = (_rates![_toCode] as num?)?.toDouble() ?? 0;
    final result = amount * rate;

    _toCtrl.text = _formatNumber(result);
    if (!_trackedConversion && amount > 0 && result > 0) {
      _trackedConversion = true;
      AchievementTrackingService.track('currency_converter_used');
    }
  }

  String _formatNumber(double value) {
    if (value == 0) return '0';
    final formatter = NumberFormat('#,##0.##', 'en_US');
    return formatter.format(value);
  }

  Future<void> _pickFromCurrency() async {
    final code = await CurrencyPickerSheet.show(context, _fromCode);
    if (code != null && code != _fromCode) {
      setState(() => _fromCode = code);
      await _fetchRates();
    }
  }

  Future<void> _pickToCurrency() async {
    final code = await CurrencyPickerSheet.show(context, _toCode);
    if (code != null && code != _toCode) {
      setState(() => _toCode = code);
      _convert();
    }
  }

  void _swap() {
    setState(() {
      final tempCode = _fromCode;
      _fromCode = _toCode;
      _toCode = tempCode;
      _fromCtrl.text = _toCtrl.text.replaceAll(',', '');
    });
    _fetchRates();
  }

  String _getRateInfo() {
    if (_rates == null) return '';
    final rate = (_rates![_toCode] as num?)?.toDouble() ?? 0;
    return '1 $_fromCode = ${_formatNumber(rate)} $_toCode';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _error != null
            ? _buildErrorState()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildRateInfoCard(),
                    const SizedBox(height: 20),
                    _buildConverterCards(),
                    const SizedBox(height: 16),
                    _buildPopularRates(),
                    const SizedBox(height: 16),
                    _buildLastUpdate(),
                  ],
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey.shade50,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Konversi Mata Uang',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: Colors.grey.shade700),
          onPressed: _loading ? null : _fetchRates,
        ),
      ],
    );
  }

  Widget _buildRateInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF8C42), Color(0xFFFF6B42)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.currency_exchange_rounded,
              size: 26,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exchange Rate',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                _loading
                    ? Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    : Text(
                        _getRateInfo(),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConverterCards() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            CurrencyInputCard(
              label: 'Dari',
              currencyCode: _fromCode,
              controller: _fromCtrl,
              onCurrencyTap: _pickFromCurrency,
              isLoading: false,
            ),
            const SizedBox(height: 12),
            CurrencyInputCard(
              label: 'Ke',
              currencyCode: _toCode,
              controller: _toCtrl,
              onCurrencyTap: _pickToCurrency,
              readOnly: true,
              isLoading: _loading,
            ),
          ],
        ),
        // Swap button di tengah (overlap antar 2 card)
        Positioned(
          left: 0,
          right: 0,
          top: 92,
          child: CurrencySwapButton(onTap: _swap),
        ),
      ],
    );
  }

  Widget _buildPopularRates() {
    if (_rates == null || _loading) return const SizedBox.shrink();

    final popular = [
      'USD',
      'EUR',
      'GBP',
      'JPY',
      'SGD',
      'IDR',
    ].where((c) => c != _fromCode).take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Rate Populer',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(vs $_fromCode)',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...popular.map((code) {
            final currency = CurrencyData.getByCode(code);
            final rate = (_rates![code] as num?)?.toDouble() ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.payments_rounded,
                    size: 20,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          code,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          currency?['name'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatNumber(rate),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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

  Widget _buildLastUpdate() {
    if (_lastUpdate == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.access_time_rounded, size: 11, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(
          'Update: ${_formatUpdateTime(_lastUpdate!)}',
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  String _formatUpdateTime(String utcString) {
    try {
      final dt = DateTime.parse(utcString).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return utcString;
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.signal_wifi_connected_no_internet_4_rounded,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchRates,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Coba Lagi',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
