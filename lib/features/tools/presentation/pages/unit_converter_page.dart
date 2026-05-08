import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/unit_data.dart';
import '../widgets/unit_category_sheet.dart';
import '../widgets/unit_input_card.dart';
import '../widgets/unit_picker_sheet.dart';

class UnitConverterPage extends StatefulWidget {
  const UnitConverterPage({super.key});

  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage> {
  final _fromCtrl = TextEditingController(text: '1');
  final _toCtrl = TextEditingController();

  String _categoryId = 'length';
  String _fromUnitCode = 'm';
  String _toUnitCode = 'km';

  @override
  void initState() {
    super.initState();
    _fromCtrl.addListener(_convert);
    _convert();
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  UnitCategory get _category =>
      UnitData.getCategory(_categoryId) ?? UnitData.categories.first;

  UnitItem get _fromUnit =>
      _category.units.firstWhere((u) => u.code == _fromUnitCode);

  UnitItem get _toUnit =>
      _category.units.firstWhere((u) => u.code == _toUnitCode);

  void _convert() {
    final raw = _fromCtrl.text.trim();
    if (raw.isEmpty || raw == '-' || raw == '.') {
      _toCtrl.text = '';
      return;
    }

    final value = double.tryParse(raw);
    if (value == null) {
      _toCtrl.text = '';
      return;
    }

    double result;
    if (_categoryId == 'temperature') {
      result = UnitData.convertTemperature(
        value: value,
        fromCode: _fromUnitCode,
        toCode: _toUnitCode,
      );
    } else {
      result = UnitData.convertGeneral(
        value: value,
        from: _fromUnit,
        to: _toUnit,
      );
    }

    _toCtrl.text = _formatNumber(result);
  }

  String _formatNumber(double value) {
    if (value == 0) return '0';
    if (value.abs() >= 1000000000) {
      return value.toStringAsExponential(4);
    }
    if (value.abs() < 0.0001 && value != 0) {
      return value.toStringAsExponential(4);
    }

    final formatter = NumberFormat('#,##0.########', 'en_US');
    return formatter.format(value);
  }

  Future<void> _pickCategory() async {
    final id = await UnitCategorySheet.show(context, _categoryId);
    if (id != null && id != _categoryId) {
      _onCategoryChanged(id);
    }
  }

  void _onCategoryChanged(String id) {
    setState(() {
      _categoryId = id;
      // Reset ke 2 unit pertama dari kategori baru
      _fromUnitCode = _category.units.first.code;
      _toUnitCode =
          _category.units.length > 1
              ? _category.units[1].code
              : _category.units.first.code;
    });
    _convert();
  }

  Future<void> _pickFromUnit() async {
    final code = await UnitPickerSheet.show(
      context: context,
      units: _category.units,
      selectedCode: _fromUnitCode,
      accentColor: _category.color,
    );
    if (code != null && code != _fromUnitCode) {
      setState(() => _fromUnitCode = code);
      _convert();
    }
  }

  Future<void> _pickToUnit() async {
    final code = await UnitPickerSheet.show(
      context: context,
      units: _category.units,
      selectedCode: _toUnitCode,
      accentColor: _category.color,
    );
    if (code != null && code != _toUnitCode) {
      setState(() => _toUnitCode = code);
      _convert();
    }
  }

  void _swap() {
    setState(() {
      final temp = _fromUnitCode;
      _fromUnitCode = _toUnitCode;
      _toUnitCode = temp;
      _fromCtrl.text = _toCtrl.text.replaceAll(',', '');
    });
    _convert();
  }

  String _getFormulaText() {
    if (_categoryId == 'temperature') {
      return _getTemperatureFormula();
    }
    final value = 1.0;
    final result = UnitData.convertGeneral(
      value: value,
      from: _fromUnit,
      to: _toUnit,
    );
    return '1 ${_fromUnit.symbol} = ${_formatNumber(result)} ${_toUnit.symbol}';
  }

  String _getTemperatureFormula() {
    if (_fromUnitCode == _toUnitCode)
      return '1 ${_fromUnit.symbol} = 1 ${_toUnit.symbol}';

    final result = UnitData.convertTemperature(
      value: 1,
      fromCode: _fromUnitCode,
      toCode: _toUnitCode,
    );
    return '1 ${_fromUnit.symbol} = ${_formatNumber(result)} ${_toUnit.symbol}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildFormulaCard(),
              const SizedBox(height: 16),
              _buildConverterCards(),
              const SizedBox(height: 16),
              _buildQuickTable(),
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
        'Konversi Satuan',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _category.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.dehaze_rounded,
                color: _category.color,
                size: 20,
              ),
            ),
            onPressed: _pickCategory,
          ),
        ),
      ],
    );
  }

  Widget _buildFormulaCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _category.color.withOpacity(0.15),
            _category.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(_category.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konversi ${_category.name}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getFormulaText(),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
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
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            UnitInputCard(
              label: 'Dari',
              unit: _fromUnit,
              controller: _fromCtrl,
              onUnitTap: _pickFromUnit,
              accentColor: _category.color,
            ),
            const SizedBox(height: 10),
            UnitInputCard(
              label: 'Ke',
              unit: _toUnit,
              controller: _toCtrl,
              onUnitTap: _pickToUnit,
              accentColor: _category.color,
              readOnly: true,
            ),
          ],
        ),
        _buildSwapButton(),
      ],
    );
  }

  Widget _buildSwapButton() {
    return Center(
      child: GestureDetector(
        onTap: _swap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _category.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _category.color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.swap_vert_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTable() {
    final value = double.tryParse(_fromCtrl.text) ?? 1;
    final otherUnits =
        _category.units.where((u) => u.code != _fromUnitCode).take(5).toList();

    if (otherUnits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Text(
                'Konversi Cepat',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: _category.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_formatNumber(value)} ${_fromUnit.symbol}',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: _category.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Column(
            children:
                otherUnits.map((u) {
                  final isLast = u == otherUnits.last;
                  double result;
                  if (_categoryId == 'temperature') {
                    result = UnitData.convertTemperature(
                      value: value,
                      fromCode: _fromUnitCode,
                      toCode: u.code,
                    );
                  } else {
                    result = UnitData.convertGeneral(
                      value: value,
                      from: _fromUnit,
                      to: u,
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color:
                              isLast
                                  ? Colors.transparent
                                  : Colors.grey.shade100,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _category.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              u.symbol,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _category.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  u.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  u.symbol,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatNumber(result),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
