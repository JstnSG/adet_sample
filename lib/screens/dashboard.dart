import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/user_form_dialog.dart';
import 'login.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  List<UserModel> _users = [];
  bool _isLoading = false;
  bool _isActionLoading = false;
  String _search = '';

  late AnimationController _tableAnim;
  late Animation<double> _tableFade;

  // ── Design System ──
  static const _bg = Color(0xFF0D1117);
  static const _surface = Color(0xFF161B22);
  static const _card = Color(0xFF1C2128);
  static const _border = Color(0xFF30363D);
  static const _teal = Color(0xFF00B4D8);
  static const _tealDeep = Color(0xFF0077B6);
  static const _green = Color(0xFF3FB950);
  static const _orange = Color(0xFFD29922);
  static const _red = Color(0xFFF85149);
  static const _white = Color(0xFFE6EDF3);
  static const _textMid = Color(0xFF8B949E);
  static const _textDim = Color(0xFF3D444D);

  @override
  void initState() {
    super.initState();
    _tableAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _tableFade = CurvedAnimation(parent: _tableAnim, curve: Curves.easeOut);
    _initAndLoad();
  }

  @override
  void dispose() {
    _tableAnim.dispose();
    super.dispose();
  }

  Future<void> _initAndLoad() async {
    await ApiService.loadToken();
    await _loadUsers();
  }

  // ═══════════════════════════════════════
  //  CRUD OPERATIONS
  // ═══════════════════════════════════════

  // READ ALL
  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    _tableAnim.reset();
    try {
      final users = await ApiService.getUsers();
      setState(() => _users = users);
      _tableAnim.forward();
    } catch (e) {
      _toast('Failed to load users: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // CREATE
  Future<void> _createUser() async {
    final result = await showDialog<UserModel>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => const UserFormDialog(),
    );
    if (result == null) return;
    setState(() => _isActionLoading = true);
    try {
      final created = await ApiService.createUser(result);
      setState(() => _users.insert(0, created));
      _toast('"${created.fullname}" has been added');
    } catch (e) {
      _toast('Create failed: $e', isError: true);
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  // READ ONE
  void _viewUser(UserModel user) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => _ViewDialog(user: user),
    );
  }

  // UPDATE
  Future<void> _updateUser(UserModel user) async {
    final result = await showDialog<UserModel>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => UserFormDialog(existing: user),
    );
    if (result == null) return;
    setState(() => _isActionLoading = true);
    try {
      await ApiService.updateUser(user.id!, result);
      await _loadUsers();
      _toast('"${result.fullname}" has been updated');
    } catch (e) {
      _toast('Update failed: $e', isError: true);
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  // DELETE
  Future<void> _deleteUser(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => _DeleteDialog(user: user),
    );
    if (confirm != true) return;
    setState(() => _isActionLoading = true);
    try {
      await ApiService.deleteUser(user.id!);
      setState(() => _users.removeWhere((u) => u.id == user.id));
      _toast('"${user.fullname}" has been deleted');
    } catch (e) {
      _toast('Delete failed: $e', isError: true);
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  // LOGOUT
  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
    );
  }

  // ── Toast ──
  void _toast(String msg, {bool isError = false}) {
    final color = isError ? _red : _green;
    final bg = isError ? const Color(0xFF3D1F1F) : const Color(0xFF1A3A26);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_rounded,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(
                    color: _white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: color.withValues(alpha: 0.4)),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  List<UserModel> get _filtered {
    if (_search.isEmpty) return _users;
    final q = _search.toLowerCase();
    return _users
        .where(
          (u) =>
              u.fullname.toLowerCase().contains(q) ||
              u.username.toLowerCase().contains(q),
        )
        .toList();
  }

  // ═══════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildAppBar(),
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ── AppBar ──
  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 12,
        20,
        12,
      ),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          // Brand
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_teal, _tealDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User Dashboard',
                style: TextStyle(
                  color: _white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${_users.length} total records',
                style: const TextStyle(color: _textMid, fontSize: 11),
              ),
            ],
          ),
          const Spacer(),
          // Live badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _green.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _green,
                    boxShadow: [
                      BoxShadow(
                        color: _green.withValues(alpha: 0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Live',
                  style: TextStyle(
                    color: _green,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Refresh
          _iconBtn(
            icon: _isActionLoading ? null : Icons.refresh_rounded,
            loading: _isActionLoading,
            onTap: _loadUsers,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 6),
          // Logout
          _iconBtn(
            icon: Icons.logout_rounded,
            onTap: _logout,
            tooltip: 'Logout',
            iconColor: _red,
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({
    IconData? icon,
    bool loading = false,
    required VoidCallback onTap,
    required String tooltip,
    Color iconColor = _textMid,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border),
          ),
          child: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _teal,
                  ),
                )
              : Icon(icon, size: 16, color: iconColor),
        ),
      ),
    );
  }

  // ── Search + Add bar ──
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: _surface,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: _white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search name or username…',
                  hintStyle: TextStyle(
                    color: _textMid.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: _textMid,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Showing count chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            child: Text(
              '${_filtered.length}/${_users.length}',
              style: const TextStyle(
                color: _textMid,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Add button
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: _createUser,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ──
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _teal, strokeWidth: 2),
      );
    }
    if (_filtered.isEmpty) return _buildEmpty();
    return FadeTransition(
      opacity: _tableFade,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats row
            _buildStatsRow(),
            const SizedBox(height: 16),
            // Table
            Container(
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Column(
                children: [
                  // Table header
                  _buildTableHeader(),
                  // Rows
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: _border),
                    itemBuilder: (_, i) => _buildRow(_filtered[i], i),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            Icons.people_rounded,
            'Total Users',
            '${_users.length}',
            _teal,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            Icons.person_search_rounded,
            'Showing',
            '${_filtered.length}',
            _orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(Icons.dns_rounded, 'API Status', 'Online', _green),
        ),
      ],
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _textMid,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _teal.withValues(alpha: 0.07),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
        border: const Border(bottom: BorderSide(color: _border)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 52, child: _TH('ID')),
          Expanded(flex: 3, child: _TH('FULL NAME')),
          Expanded(flex: 2, child: _TH('USERNAME')),
          Expanded(flex: 4, child: _TH('ACTIONS')),
        ],
      ),
    );
  }

  Widget _buildRow(UserModel user, int i) {
    final avatarColors = [
      _teal,
      _green,
      _orange,
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];
    final ac = avatarColors[i % avatarColors.length];

    return Container(
      color: i.isEven
          ? Colors.transparent
          : Colors.white.withValues(alpha: 0.01),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          // ID badge
          SizedBox(
            width: 52,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: _teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _teal.withValues(alpha: 0.2)),
              ),
              child: Text(
                '${user.id}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _teal,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          // Full name + avatar
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ac.withValues(alpha: 0.15),
                    border: Border.all(color: ac.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(
                      user.fullname.isNotEmpty
                          ? user.fullname[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: ac,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    user.fullname,
                    style: const TextStyle(
                      color: _white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Username
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text('@', style: TextStyle(color: _textDim, fontSize: 12)),
                Expanded(
                  child: Text(
                    user.username,
                    style: const TextStyle(color: _textMid, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          Expanded(
            flex: 4,
            child: Row(
              children: [
                _actionBtn(
                  'Read',
                  Icons.visibility_rounded,
                  _teal,
                  () => _viewUser(user),
                ),
                const SizedBox(width: 6),
                _actionBtn(
                  'Update',
                  Icons.edit_rounded,
                  _orange,
                  () => _updateUser(user),
                ),
                const SizedBox(width: 6),
                _actionBtn(
                  'Delete',
                  Icons.delete_rounded,
                  _red,
                  () => _deleteUser(user),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _teal.withValues(alpha: 0.07),
              border: Border.all(
                color: _teal.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              size: 30,
              color: _teal,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No users found',
            style: TextStyle(
              color: _white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap "Add User" to create the first one',
            style: TextStyle(color: _textMid, fontSize: 13),
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: _createUser,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
//  VIEW DIALOG
// ═══════════════════════════════════════
class _ViewDialog extends StatelessWidget {
  final UserModel user;
  const _ViewDialog({required this.user});

  static const _bg = Color(0xFF1C2128);
  static const _border = Color(0xFF30363D);
  static const _teal = Color(0xFF00B4D8);
  static const _white = Color(0xFFE6EDF3);
  static const _mid = Color(0xFF8B949E);
  static const _surface = Color(0xFF161B22);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _border),
      ),
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_teal, Color(0xFF0077B6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _teal.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.fullname.isNotEmpty
                      ? user.fullname[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              user.fullname,
              style: const TextStyle(
                color: _white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '@${user.username}',
              style: const TextStyle(color: _teal, fontSize: 13),
            ),
            const SizedBox(height: 22),
            _tile(Icons.tag_rounded, 'User ID', '${user.id}'),
            const SizedBox(height: 8),
            _tile(Icons.person_rounded, 'Full Name', user.fullname),
            const SizedBox(height: 8),
            _tile(Icons.alternate_email_rounded, 'Username', user.username),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: _teal),
          const SizedBox(width: 10),
          Text(
            '$label  ',
            style: const TextStyle(
              color: _mid,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
//  DELETE DIALOG
// ═══════════════════════════════════════
class _DeleteDialog extends StatelessWidget {
  final UserModel user;
  const _DeleteDialog({required this.user});

  static const _bg = Color(0xFF1C2128);
  static const _border = Color(0xFF30363D);
  static const _red = Color(0xFFF85149);
  static const _white = Color(0xFFE6EDF3);
  static const _mid = Color(0xFF8B949E);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _border),
      ),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _red.withValues(alpha: 0.1),
                border: Border.all(color: _red.withValues(alpha: 0.25)),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: _red,
                size: 24,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Delete User',
              style: TextStyle(
                color: _white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to delete\n"${user.fullname}"?\nThis action cannot be undone.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _mid, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _mid,
                      side: const BorderSide(color: _border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Table Header Cell ──
class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8B949E),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}
