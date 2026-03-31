import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../services/api_service.dart';
import '../widgets/coins_lives_row.dart';
import '../widgets/animated_bg.dart';
import '../widgets/button_3d.dart';
import '../widgets/depth_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _api = ApiService();
  final gc = Get.find<GameController>();

  bool _loading = true;
  Map<String, dynamic> _wallet = {};
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _api.getWallet(),
      _api.getWithdrawalHistory(),
    ]);
    setState(() {
      _wallet = results[0] ?? {};
      final histData = results[1];
      _history = (histData?['withdrawals'] as List?) ?? [];
      _loading = false;
    });
  }

  bool get isAr => gc.isAr;
  int get gems => (_wallet['coins'] as num?)?.toInt() ?? gc.coins.value;
  int get userXp => (_wallet['xp'] as num?)?.toInt() ?? gc.xp.value;
  int get coinsPerDollar => (_wallet['coins_per_dollar'] as num?)?.toInt() ?? 10000;
  int get minWithdraw => (_wallet['min_withdraw_coins'] as num?)?.toInt() ?? 50000;
  int get availableGems => (_wallet['available_coins'] as num?)?.toInt() ?? 0;
  int get pendingGems => (_wallet['pending_coins'] as num?)?.toInt() ?? 0;
  double get totalEarned => (_wallet['total_earned'] as num?)?.toDouble() ?? 0;
  bool get withdrawalEnabled => _wallet['withdrawal_enabled'] as bool? ?? false;
  bool get canWithdraw => _wallet['can_withdraw'] as bool? ?? false;
  List<dynamic> get paymentMethods => _wallet['payment_methods'] as List? ?? [];
  String get currency => _wallet['currency'] as String? ?? 'EGP';
  int get todayAds => (_wallet['today_ad_watches'] as num?)?.toInt() ?? 0;
  int get maxAds => (_wallet['max_daily_ads'] as num?)?.toInt() ?? 50;
  int get gemsPerAd => (_wallet['gems_per_ad'] as num?)?.toInt() ?? 5;
  int get minAccountAge => (_wallet['min_account_age'] as num?)?.toInt() ?? 30;
  int get accountAgeDays => (_wallet['account_age_days'] as num?)?.toInt() ?? 0;
  int get minXpToWithdraw => (_wallet['min_xp_to_withdraw'] as num?)?.toInt() ?? 500;

  double gemsToMoney(int g) => g / coinsPerDollar;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = isDarkCtx(context);
      return Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: kTextPrimary,
            leading: _build3DBackButton(),
            title: Text(isAr ? '\u0627\u0644\u0645\u062d\u0641\u0638\u0629' : 'Wallet'),
            centerTitle: true,
            actions: const [CoinsLivesRow()],
          ),
          body: AnimatedGameBg(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: kToolbarHeight + MediaQuery.of(context).padding.top + rs(8),
                        left: rs(16),
                        right: rs(16),
                        bottom: rs(16),
                      ),
                      child: Column(
                        children: [
                          _buildBalanceCard(),
                          SizedBox(height: rs(16)),
                          _buildStatsRow(),
                          SizedBox(height: rs(16)),
                          _buildWithdrawButton(),
                          SizedBox(height: rs(24)),
                          _buildHistorySection(),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      );
    });
  }

  Widget _build3DBackButton() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        margin: EdgeInsets.all(rs(8)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDarkCtx(context) ? kDarkCardColor : Colors.white,
              isDarkCtx(context)
                  ? HSLColor.fromColor(kDarkCardColor).withLightness(0.18).toColor()
                  : const Color(0xFFF0F0F0),
            ],
          ),
          borderRadius: BorderRadius.circular(rs(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkCtx(context) ? 0.4 : 0.10),
              offset: Offset(0, rs(3)),
              blurRadius: 0,
            ),
            BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.10),
              blurRadius: rs(8),
              offset: Offset(0, rs(2)),
            ),
          ],
        ),
        child: Icon(Icons.arrow_back_ios_new, size: rs(18), color: kTextPrimary),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(24)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryColor, Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(rs(20)),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.5),
            offset: Offset(0, rs(5)),
            blurRadius: 0,
          ),
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glossy highlight
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: rs(50),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(rs(20))),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.22),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                isAr ? '\u0631\u0635\u064a\u062f\u0643' : 'Your Balance',
                style: TextStyle(color: Colors.white70, fontSize: kFontSizeBody),
              ),
              SizedBox(height: rs(8)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.diamond, color: Colors.amber, size: rs(32)),
                  SizedBox(width: rs(8)),
                  Text(
                    _formatNumber(gems),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: kFontSizeH1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: rs(4)),
              Text(
                '= ${gemsToMoney(gems).toStringAsFixed(2)} $currency',
                style: TextStyle(color: Colors.white70, fontSize: kFontSizeBodyLarge),
              ),
              SizedBox(height: rs(12)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: rs(12), vertical: rs(6)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(rs(20)),
                ),
                child: Text(
                  isAr
                      ? '$coinsPerDollar \u062c\u0648\u0647\u0631\u0629 = 1 $currency'
                      : '$coinsPerDollar gems = 1 $currency',
                  style: TextStyle(color: Colors.white, fontSize: kFontSizeCaption),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _statCard(
          icon: Icons.hourglass_empty,
          label: isAr ? '\u0641\u064a \u0627\u0644\u0627\u0646\u062a\u0638\u0627\u0631' : 'Pending',
          value: _formatNumber(pendingGems),
          color: kOrangeColor,
        )),
        SizedBox(width: rs(8)),
        Expanded(child: _statCard(
          icon: Icons.check_circle,
          label: isAr ? '\u0645\u062a\u0627\u062d \u0644\u0644\u0633\u062d\u0628' : 'Available',
          value: _formatNumber(availableGems),
          color: kGreenColor,
        )),
        SizedBox(width: rs(8)),
        Expanded(child: _statCard(
          icon: Icons.paid,
          label: isAr ? '\u0625\u062c\u0645\u0627\u0644\u064a \u0627\u0644\u0645\u0643\u0627\u0633\u0628' : 'Total Earned',
          value: totalEarned.toStringAsFixed(1),
          color: kSecondaryColor,
        )),
      ],
    );
  }

  Widget _statCard({required IconData icon, required String label, required String value, required Color color}) {
    final isDark = isDarkCtx(context);
    return Container(
      padding: EdgeInsets.all(rs(12)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.22).toColor()]
              : [Colors.white, Colors.white.withValues(alpha: 0.95)],
        ),
        borderRadius: BorderRadius.circular(rs(14)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : color.withValues(alpha: 0.1),
            offset: Offset(0, rs(3)),
            blurRadius: 0,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: rs(10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(rs(6)),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
              borderRadius: BorderRadius.circular(rs(8)),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: rs(6), offset: Offset(0, rs(2))),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: rs(16)),
          ),
          SizedBox(height: rs(4)),
          Text(value, style: TextStyle(color: kTextPrimary, fontSize: kFontSizeBody, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: kTextHint, fontSize: kFontSizeTiny), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildWithdrawButton() {
    final canWithdrawNow = canWithdraw && availableGems >= minWithdraw;
    return Button3D(
      label: isAr ? '\u0633\u062d\u0628 \u0627\u0644\u0623\u0631\u0628\u0627\u062d' : 'Withdraw Earnings',
      icon: Icons.account_balance_wallet,
      color: canWithdrawNow ? kGreenColor : kCardColor,
      textColor: canWithdrawNow ? Colors.white : kTextDisabled,
      height: 54,
      onTap: canWithdrawNow ? _showWithdrawDialog : null,
    );
  }

  void _showWithdrawDialog() {
    final coinsCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    final selectedMethod = (paymentMethods.isNotEmpty ? paymentMethods.first.toString() : '').obs;
    final isDark = isDarkCtx(context);

    Get.dialog(
      Dialog(
        backgroundColor: isDark ? kDarkCardColor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(20))),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(rs(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? '\u0637\u0644\u0628 \u0633\u062d\u0628' : 'Withdraw Request',
                style: TextStyle(color: kTextPrimary, fontSize: kFontSizeH3, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: rs(16)),
              Text(isAr ? '\u0639\u062f\u062f \u0627\u0644\u0639\u0645\u0644\u0627\u062a' : 'Coins Amount', style: TextStyle(color: kTextSecondary, fontSize: kFontSizeBody)),
              SizedBox(height: rs(6)),
              TextField(
                controller: coinsCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: kTextPrimary),
                decoration: InputDecoration(
                  hintText: isAr ? '\u0627\u0644\u062d\u062f \u0627\u0644\u0623\u062f\u0646\u0649 $minWithdraw' : 'Min $minWithdraw',
                  hintStyle: TextStyle(color: kTextHint),
                  filled: true,
                  fillColor: kBgColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(rs(12)), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: rs(16)),
              Text(isAr ? '\u0637\u0631\u064a\u0642\u0629 \u0627\u0644\u062f\u0641\u0639' : 'Payment Method', style: TextStyle(color: kTextSecondary, fontSize: kFontSizeBody)),
              SizedBox(height: rs(6)),
              Obx(() => Wrap(
                spacing: rs(8),
                children: paymentMethods.map((m) {
                  final method = m.toString();
                  final isSelected = selectedMethod.value == method;
                  return ChoiceChip(
                    label: Text(_methodLabel(method)),
                    selected: isSelected,
                    onSelected: (_) => selectedMethod.value = method,
                    selectedColor: kPrimaryColor.withValues(alpha: 0.2),
                    labelStyle: TextStyle(color: isSelected ? kPrimaryColor : kTextPrimary, fontSize: kFontSizeCaption),
                  );
                }).toList(),
              )),
              SizedBox(height: rs(16)),
              Obx(() => Text(
                _detailsLabel(selectedMethod.value),
                style: TextStyle(color: kTextSecondary, fontSize: kFontSizeBody),
              )),
              SizedBox(height: rs(6)),
              TextField(
                controller: detailsCtrl,
                style: TextStyle(color: kTextPrimary),
                decoration: InputDecoration(
                  hintText: isAr ? '\u0623\u062f\u062e\u0644 \u0631\u0642\u0645 \u0627\u0644\u062d\u0633\u0627\u0628' : 'Enter account info',
                  hintStyle: TextStyle(color: kTextHint),
                  filled: true,
                  fillColor: kBgColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(rs(12)), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: rs(20)),
              Button3D(
                label: isAr ? '\u062a\u0623\u0643\u064a\u062f \u0627\u0644\u0633\u062d\u0628' : 'Confirm Withdrawal',
                color: kGreenColor,
                height: 48,
                onTap: () => _submitWithdraw(
                  int.tryParse(coinsCtrl.text) ?? 0,
                  selectedMethod.value,
                  detailsCtrl.text.trim(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _methodLabel(String method) {
    switch (method) {
      case 'vodafone_cash': return isAr ? '\u0641\u0648\u062f\u0627\u0641\u0648\u0646 \u0643\u0627\u0634' : 'Vodafone Cash';
      case 'instapay':      return isAr ? '\u0625\u0646\u0633\u062a\u0627\u0628\u0627\u064a' : 'Instapay';
      case 'paypal':        return 'PayPal';
      default:              return method;
    }
  }

  String _detailsLabel(String method) {
    switch (method) {
      case 'vodafone_cash': return isAr ? '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641' : 'Phone Number';
      case 'instapay':      return isAr ? '\u0631\u0642\u0645 \u0627\u0644\u062d\u0633\u0627\u0628 / \u0627\u0644\u0647\u0627\u062a\u0641' : 'Account / Phone';
      case 'paypal':        return isAr ? '\u0627\u0644\u0628\u0631\u064a\u062f \u0627\u0644\u0625\u0644\u0643\u062a\u0631\u0648\u0646\u064a' : 'Email Address';
      default:              return isAr ? '\u062a\u0641\u0627\u0635\u064a\u0644 \u0627\u0644\u062d\u0633\u0627\u0628' : 'Account Details';
    }
  }

  Future<void> _submitWithdraw(int gemsAmount, String method, String details) async {
    if (gemsAmount < minWithdraw) {
      Get.snackbar(
        isAr ? '\u062e\u0637\u0623' : 'Error',
        isAr ? '\u0627\u0644\u062d\u062f \u0627\u0644\u0623\u062f\u0646\u0649 \u0644\u0644\u0633\u062d\u0628 $minWithdraw \u062c\u0648\u0647\u0631\u0629' : 'Minimum withdrawal is $minWithdraw gems',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kRedColor,
        colorText: Colors.white,
      );
      return;
    }
    if (details.isEmpty) {
      Get.snackbar(
        isAr ? '\u062e\u0637\u0623' : 'Error',
        isAr ? '\u0623\u062f\u062e\u0644 \u062a\u0641\u0627\u0635\u064a\u0644 \u0627\u0644\u062d\u0633\u0627\u0628' : 'Enter account details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kRedColor,
        colorText: Colors.white,
      );
      return;
    }

    Get.back();
    setState(() => _loading = true);

    final res = await _api.requestWithdrawal(
      coinsAmount: gemsAmount,
      paymentMethod: method,
      paymentDetails: details,
    );

    if (res != null && res.containsKey('withdrawal')) {
      Get.snackbar(
        isAr ? '\u062a\u0645 \u0627\u0644\u0625\u0631\u0633\u0627\u0644' : 'Submitted',
        isAr ? '\u062a\u0645 \u0625\u0631\u0633\u0627\u0644 \u0637\u0644\u0628 \u0627\u0644\u0633\u062d\u0628 \u0628\u0646\u062c\u0627\u062d' : 'Withdrawal request submitted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kGreenColor,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        isAr ? '\u062e\u0637\u0623' : 'Error',
        res?['message']?.toString() ?? (isAr ? '\u062d\u062f\u062b \u062e\u0637\u0623' : 'Something went wrong'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kRedColor,
        colorText: Colors.white,
      );
    }

    await _loadData();
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? '\u0633\u062c\u0644 \u0627\u0644\u0633\u062d\u0628' : 'Withdrawal History',
          style: TextStyle(color: kTextPrimary, fontSize: kFontSizeH4, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: rs(12)),
        if (_history.isEmpty)
          DepthCard(
            padding: EdgeInsets.all(rs(32)),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long, color: kTextDisabled, size: rs(40)),
                  SizedBox(height: rs(8)),
                  Text(
                    isAr ? '\u0644\u0627 \u062a\u0648\u062c\u062f \u0639\u0645\u0644\u064a\u0627\u062a \u0633\u062d\u0628 \u0628\u0639\u062f' : 'No withdrawals yet',
                    style: TextStyle(color: kTextHint, fontSize: kFontSizeBody),
                  ),
                ],
              ),
            ),
          )
        else
          ..._history.map((w) {
            final withdrawal = w as Map<String, dynamic>;
            return _buildHistoryItem(withdrawal);
          }),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> w) {
    final status = w['status'] as String? ?? 'pending';
    final amount = (w['money_amount'] as num?)?.toDouble() ?? 0;
    final coinsAmt = (w['coins_amount'] as num?)?.toInt() ?? 0;
    final method = w['payment_method'] as String? ?? '';
    final createdAt = w['created_at'] as String? ?? '';

    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (status) {
      case 'pending':
        statusColor = kOrangeColor;
        statusLabel = isAr ? '\u0641\u064a \u0627\u0644\u0627\u0646\u062a\u0638\u0627\u0631' : 'Pending';
        statusIcon = Icons.hourglass_empty;
        break;
      case 'approved':
        statusColor = Colors.blue;
        statusLabel = isAr ? '\u062a\u0645\u062a \u0627\u0644\u0645\u0648\u0627\u0641\u0642\u0629' : 'Approved';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'rejected':
        statusColor = kRedColor;
        statusLabel = isAr ? '\u0645\u0631\u0641\u0648\u0636' : 'Rejected';
        statusIcon = Icons.cancel_outlined;
        break;
      case 'paid':
        statusColor = kGreenColor;
        statusLabel = isAr ? '\u062a\u0645 \u0627\u0644\u062f\u0641\u0639' : 'Paid';
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = kTextHint;
        statusLabel = status;
        statusIcon = Icons.info_outline;
    }

    final isDark = isDarkCtx(context);
    return DepthCard(
      margin: EdgeInsets.only(bottom: rs(10)),
      padding: EdgeInsets.all(rs(14)),
      accentColor: statusColor,
      elevation: 0.7,
      child: Row(
        children: [
          Container(
            width: rs(40),
            height: rs(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [statusColor, statusColor.withValues(alpha: 0.7)]),
              borderRadius: BorderRadius.circular(rs(12)),
              boxShadow: [
                BoxShadow(color: statusColor.withValues(alpha: 0.3), blurRadius: rs(6), offset: Offset(0, rs(2))),
              ],
            ),
            child: Icon(statusIcon, color: Colors.white, size: rs(20)),
          ),
          SizedBox(width: rs(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${amount.toStringAsFixed(2)} $currency',
                  style: TextStyle(color: kTextPrimary, fontSize: kFontSizeBodyLarge, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_formatNumber(coinsAmt)} gems - ${_methodLabel(method)}',
                  style: TextStyle(color: kTextHint, fontSize: kFontSizeCaption),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: rs(8), vertical: rs(3)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [statusColor.withValues(alpha: 0.15), statusColor.withValues(alpha: 0.05)]),
                  borderRadius: BorderRadius.circular(rs(8)),
                ),
                child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: kFontSizeTiny, fontWeight: FontWeight.w600)),
              ),
              SizedBox(height: rs(4)),
              Text(
                _formatDate(createdAt),
                style: TextStyle(color: kTextDisabled, fontSize: kFontSizeTiny),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
