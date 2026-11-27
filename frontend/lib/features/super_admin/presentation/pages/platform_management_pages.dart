import 'package:flutter/material.dart';
import '../../../../core/models/registered_shop_item.dart';
import '../../../../core/repositories/shop_repository.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';

class PlatformUsersPage extends StatefulWidget {
  const PlatformUsersPage({super.key});

  @override
  State<PlatformUsersPage> createState() => _PlatformUsersPageState();
}

class _PlatformUsersPageState extends State<PlatformUsersPage> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await ShopRepository().fetchPlatformUsers();
      if (!mounted) return;
      setState(() {
        _users = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _openEditUserDialog(Map<String, dynamic> u) {
    final nameCtrl = TextEditingController(text: '${u['fullName'] ?? ''}');
    final phoneCtrl = TextEditingController(text: '${u['phone'] ?? ''}');
    String role = (u['platformRole'] ?? 'support_agent').toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Platform User & Role', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: ['super_admin', 'admin', 'accountant', 'support_agent', 'sales_manager', 'viewer'].contains(role) ? role : 'support_agent',
              decoration: const InputDecoration(labelText: 'Platform Role', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'accountant', child: Text('Accountant')),
                DropdownMenuItem(value: 'support_agent', child: Text('Support Agent')),
                DropdownMenuItem(value: 'sales_manager', child: Text('Sales Manager')),
                DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
              ],
              onChanged: (v) => role = v ?? role,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              await ShopRepository().updatePlatformUser(u['_id'].toString(), {
                'fullName': nameCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'platformRole': role,
              });
              navigator.pop();
              _load();
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openResetPassDialog(Map<String, dynamic> u) {
    final passCtrl = TextEditingController(text: 'Pass@123');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reset Password (${u['fullName']})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              await ShopRepository().resetPlatformUserPassword(u['_id'].toString(), passCtrl.text);
              navigator.pop();
              messenger.showSnackBar(const SnackBar(content: Text('Password reset!'), backgroundColor: AppColors.success));
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openCreateDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: 'Pass@123');
    String role = 'support_agent';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Platform Staff', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Platform Role', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'accountant', child: Text('Accountant')),
                    DropdownMenuItem(value: 'support_agent', child: Text('Support Agent')),
                    DropdownMenuItem(value: 'sales_manager', child: Text('Sales Manager')),
                    DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                  ],
                  onChanged: (v) => role = v ?? 'support_agent',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ShopRepository().createPlatformUser({
                  'fullName': nameCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  'password': passCtrl.text,
                  'platformRole': role,
                });
                navigator.pop();
                await _load();
                messenger.showSnackBar(const SnackBar(content: Text('Platform user created!'), backgroundColor: AppColors.success));
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger));
              }
            },
            child: const Text('Create User', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Platform Users & Roles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                onPressed: _openCreateDialog,
                icon: const Icon(Icons.person_add_alt_1, size: 16, color: Colors.white),
                label: const Text('Add Platform User', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
          else if (_users.isEmpty)
            const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No platform staff found in database.'))))
          else
            ..._users.map((u) {
              final active = (u['status'] ?? 'ACTIVE') == 'ACTIVE';
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                    child: const Icon(Icons.shield_outlined, color: AppColors.secondary, size: 18),
                  ),
                  title: Text('${u['fullName'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('${u['email'] ?? ''} • Role: ${u['platformRole'] ?? 'staff'}', style: const TextStyle(fontSize: 11)),
                  trailing: Wrap(
                    spacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => _openEditUserDialog(u),
                        child: const Text('Edit Role', style: TextStyle(fontSize: 11)),
                      ),
                      TextButton(
                        onPressed: () => _openResetPassDialog(u),
                        child: const Text('Reset Pass', style: TextStyle(fontSize: 11)),
                      ),
                      TextButton(
                        onPressed: () async {
                          await ShopRepository().togglePlatformUserStatus(u['_id'].toString());
                          _load();
                        },
                        child: Text(active ? 'Suspend' : 'Activate',
                            style: TextStyle(fontSize: 11, color: active ? AppColors.danger : AppColors.success)),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class SupportTicketsPage extends StatefulWidget {
  final List<RegisteredShopItem> shops;
  const SupportTicketsPage({super.key, required this.shops});

  @override
  State<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage> {
  List<Map<String, dynamic>> _tickets = [];
  bool _loading = true;
  String _statusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await ShopRepository().fetchTickets(status: _statusFilter);
      if (!mounted) return;
      setState(() {
        _tickets = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _openCreateDialog() {
    final subjectCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'MEDIUM';
    String? shopId = widget.shops.isNotEmpty ? widget.shops.first.id : null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create Support Ticket', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.shops.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: shopId,
                    decoration: const InputDecoration(labelText: 'Shop', border: OutlineInputBorder()),
                    items: widget.shops.map((s) => DropdownMenuItem(value: s.id, child: Text(s.shopName))).toList(),
                    onChanged: (v) => shopId = v,
                  ),
                  const SizedBox(height: 10),
                ],
                TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'LOW', child: Text('Low')),
                    DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                    DropdownMenuItem(value: 'HIGH', child: Text('High')),
                    DropdownMenuItem(value: 'URGENT', child: Text('Urgent')),
                  ],
                  onChanged: (v) => priority = v ?? 'MEDIUM',
                ),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              await ShopRepository().createTicket({
                'shopId': shopId,
                'subject': subjectCtrl.text.trim(),
                'priority': priority,
                'description': descCtrl.text.trim(),
              });
              navigator.pop();
              _load();
            },
            child: const Text('Submit Ticket', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openReplyDialog(Map<String, dynamic> ticket) {
    final replyCtrl = TextEditingController();
    String status = (ticket['status'] ?? 'OPEN').toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${ticket['ticketNumber']} • ${ticket['subject']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${ticket['description']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'OPEN', child: Text('Open')),
                    DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                    DropdownMenuItem(value: 'RESOLVED', child: Text('Resolved')),
                    DropdownMenuItem(value: 'CLOSED', child: Text('Closed')),
                  ],
                  onChanged: (v) => status = v ?? status,
                ),
                const SizedBox(height: 10),
                TextField(controller: replyCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Reply Message', border: OutlineInputBorder())),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final id = ticket['_id'].toString();
              if (replyCtrl.text.trim().isNotEmpty) {
                await ShopRepository().replyTicket(id, replyCtrl.text.trim());
              }
              await ShopRepository().updateTicket(id, {'status': status});
              navigator.pop();
              _load();
            },
            child: const Text('Save & Reply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Support & Ticket Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                onPressed: _openCreateDialog,
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('New Ticket', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: ['ALL', 'OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'].map((s) {
              final sel = _statusFilter == s;
              return ChoiceChip(
                label: Text(s, style: const TextStyle(fontSize: 10)),
                selected: sel,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: sel ? Colors.white : AppColors.textSecondary),
                onSelected: (v) {
                  if (v) {
                    setState(() => _statusFilter = s);
                    _load();
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
          else if (_tickets.isEmpty)
            const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No support tickets found.'))))
          else
            ..._tickets.map((t) => Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                  child: ListTile(
                    title: Text('${t['ticketNumber']} • ${t['subject']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('${t['shopName']} • Priority: ${t['priority']} • Status: ${t['status']}', style: const TextStyle(fontSize: 11)),
                    trailing: OutlinedButton(onPressed: () => _openReplyDialog(t), child: const Text('Manage', style: TextStyle(fontSize: 11))),
                  ),
                )),
        ],
      ),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await ShopRepository().fetchNotifications();
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Notifications & Expiry Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final res = await ShopRepository().checkExpiringSubscriptions();
                  await _load();
                  messenger.showSnackBar(SnackBar(content: Text('Checked ${res['checked']} expiring subscriptions, created ${res['created']} alerts.')));
                },
                icon: const Icon(Icons.notifications_active, size: 16, color: Colors.white),
                label: const Text('Check Expiring', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
          else if (_items.isEmpty)
            const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No notifications yet.'))))
          else
            ..._items.map((n) => Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.border)),
                  child: ListTile(
                    leading: Icon(Icons.notifications, color: (n['isRead'] == true) ? AppColors.textMuted : AppColors.secondary),
                    title: Text('${n['title']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('${n['message']}', style: const TextStyle(fontSize: 11)),
                    trailing: (n['isRead'] == true)
                        ? const Text('Read', style: TextStyle(fontSize: 10, color: AppColors.textMuted))
                        : TextButton(
                            onPressed: () async {
                              await ShopRepository().markNotificationRead(n['_id'].toString());
                              _load();
                            },
                            child: const Text('Mark Read', style: TextStyle(fontSize: 11)),
                          ),
                  ),
                )),
        ],
      ),
    );
  }
}

class AuditLogsPage extends StatefulWidget {
  const AuditLogsPage({super.key});

  @override
  State<AuditLogsPage> createState() => _AuditLogsPageState();
}

class _AuditLogsPageState extends State<AuditLogsPage> {
  List<Map<String, dynamic>> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await ShopRepository().fetchAuditLogs();
      if (!mounted) return;
      setState(() {
        _logs = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Platform Audit Logs & Security', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
          else if (_logs.isEmpty)
            const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No audit logs recorded yet.'))))
          else
            ..._logs.map((l) {
              final user = l['userId'] as Map<String, dynamic>?;
              final shop = l['shopId'] as Map<String, dynamic>?;
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.border)),
                child: ListTile(
                  leading: const Icon(Icons.history, color: AppColors.primary, size: 18),
                  title: Text('${l['action']} (${l['module']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('By: ${user?['fullName'] ?? 'System'} • Shop: ${shop?['name'] ?? 'Platform'}', style: const TextStyle(fontSize: 11)),
                  trailing: Text(RegisteredShopItem.formatDate(l['createdAt']), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class SystemSettingsAndBackupPage extends StatefulWidget {
  const SystemSettingsAndBackupPage({super.key});

  @override
  State<SystemSettingsAndBackupPage> createState() => _SystemSettingsAndBackupPageState();
}

class _SystemSettingsAndBackupPageState extends State<SystemSettingsAndBackupPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _trialCtrl = TextEditingController();
  final _graceCtrl = TextEditingController();
  bool _autoSuspend = true;
  bool _twoFactor = false;
  bool _maintenance = false;
  String _lastBackup = 'Never';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await ShopRepository().fetchSystemSettings();
      if (!mounted) return;
      setState(() {
        _nameCtrl.text = (s['platformName'] ?? 'Next Planners POS').toString();
        _emailCtrl.text = (s['supportEmail'] ?? '').toString();
        _phoneCtrl.text = (s['supportPhone'] ?? '').toString();
        _trialCtrl.text = '${s['trialDurationDays'] ?? 30}';
        _graceCtrl.text = '${s['gracePeriodDays'] ?? 3}';
        _autoSuspend = s['autoSuspendExpired'] as bool? ?? true;
        _twoFactor = s['twoFactorRequired'] as bool? ?? false;
        _maintenance = s['maintenanceMode'] as bool? ?? false;
        _lastBackup = s['lastBackupAt'] != null ? RegisteredShopItem.formatDate(s['lastBackupAt']) : 'Never';
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Global Platform Settings & Backups', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Platform Name', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Support Email', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Support Phone', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _trialCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Trial Days', border: OutlineInputBorder()))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: _graceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Grace Period (Days)', border: OutlineInputBorder()))),
                    ],
                  ),
                  SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Auto-Suspend Expired Shops'), value: _autoSuspend, onChanged: (v) => setState(() => _autoSuspend = v)),
                  SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Require Two-Factor Auth (2FA)'), value: _twoFactor, onChanged: (v) => setState(() => _twoFactor = v)),
                  SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Maintenance Mode'), value: _maintenance, onChanged: (v) => setState(() => _maintenance = v)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await ShopRepository().updateSystemSettings({
                            'platformName': _nameCtrl.text.trim(),
                            'supportEmail': _emailCtrl.text.trim(),
                            'supportPhone': _phoneCtrl.text.trim(),
                            'trialDurationDays': int.tryParse(_trialCtrl.text.trim()) ?? 30,
                            'gracePeriodDays': int.tryParse(_graceCtrl.text.trim()) ?? 3,
                            'autoSuspendExpired': _autoSuspend,
                            'twoFactorRequired': _twoFactor,
                            'maintenanceMode': _maintenance,
                          });
                          messenger.showSnackBar(const SnackBar(content: Text('System settings saved!'), backgroundColor: AppColors.success));
                        },
                        child: const Text('Save Settings', style: TextStyle(color: Colors.white)),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final res = await ShopRepository().triggerBackup();
                          setState(() => _lastBackup = RegisteredShopItem.formatDate(res['backupAt']));
                          messenger.showSnackBar(SnackBar(content: Text('Backup snapshot recorded (${res['counts']})'), backgroundColor: AppColors.primary));
                        },
                        icon: const Icon(Icons.backup_outlined, size: 16),
                        label: Text('Run Backup (Last: $_lastBackup)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LeadsCrmPage extends StatefulWidget {
  const LeadsCrmPage({super.key});

  @override
  State<LeadsCrmPage> createState() => _LeadsCrmPageState();
}

class _LeadsCrmPageState extends State<LeadsCrmPage> {
  List<Map<String, dynamic>> _leads = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await ShopRepository().fetchLeads();
      if (!mounted) return;
      setState(() {
        _leads = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _openAddLeadDialog() {
    final bizCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String status = 'NEW';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Sales Lead', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: bizCtrl, decoration: const InputDecoration(labelText: 'Business Name', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: contactCtrl, decoration: const InputDecoration(labelText: 'Contact Person', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone / Email', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'NEW', child: Text('New')),
                    DropdownMenuItem(value: 'CONTACTED', child: Text('Contacted')),
                    DropdownMenuItem(value: 'DEMO_SCHEDULED', child: Text('Demo Scheduled')),
                    DropdownMenuItem(value: 'CONVERTED', child: Text('Converted')),
                    DropdownMenuItem(value: 'LOST', child: Text('Lost')),
                  ],
                  onChanged: (v) => status = v ?? 'NEW',
                ),
                const SizedBox(height: 10),
                TextField(controller: notesCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Sales Notes', border: OutlineInputBorder())),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              await ShopRepository().createLead({
                'businessName': bizCtrl.text.trim(),
                'contactName': contactCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'status': status,
                'notes': notesCtrl.text.trim(),
              });
              navigator.pop();
              _load();
            },
            child: const Text('Save Lead', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Leads & Sales CRM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                onPressed: _openAddLeadDialog,
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Add Lead', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
          else if (_leads.isEmpty)
            const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No sales leads yet.'))))
          else
            ..._leads.map((l) => Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.border)),
                  child: ListTile(
                    title: Text('${l['businessName']} • ${l['contactName']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('${l['phone']} • Status: ${l['status']}\n${l['notes'] ?? ''}', style: const TextStyle(fontSize: 11)),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'DELETE') {
                          await ShopRepository().deleteLead(l['_id'].toString());
                        } else {
                          await ShopRepository().updateLead(l['_id'].toString(), {'status': v});
                        }
                        _load();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'CONTACTED', child: Text('Mark Contacted')),
                        PopupMenuItem(value: 'DEMO_SCHEDULED', child: Text('Demo Scheduled')),
                        PopupMenuItem(value: 'CONVERTED', child: Text('Mark Converted')),
                        PopupMenuItem(value: 'LOST', child: Text('Mark Lost')),
                        PopupMenuItem(value: 'DELETE', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

class AnalyticsReportsPage extends StatefulWidget {
  const AnalyticsReportsPage({super.key});

  @override
  State<AnalyticsReportsPage> createState() => _AnalyticsReportsPageState();
}

class _AnalyticsReportsPageState extends State<AnalyticsReportsPage> {
  Map<String, dynamic> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ShopRepository().fetchPlatformAnalytics();
      if (!mounted) return;
      setState(() {
        _data = res;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final perShop = (_data['perShop'] as List? ?? []).cast<Map<String, dynamic>>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tenant Resource Usage & Analytics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _statChip('Shops', '${_data['totalShops'] ?? 0}'),
              _statChip('Branches', '${_data['totalBranches'] ?? 0}'),
              _statChip('Tenant Users', '${_data['totalTenantUsers'] ?? 0}'),
              _statChip('Products', '${_data['totalProducts'] ?? 0}'),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Per-Tenant Quota Usage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          if (perShop.isEmpty)
            const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(20), child: Text('No tenant usage data yet.')))
          else
            ...perShop.map((s) => Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.border)),
                  child: ListTile(
                    title: Text('${s['shopName']} (${s['plan']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('Branches: ${s['branchesUsed']} / ${s['maxBranches']} • Max Users: ${s['maxUsers']}', style: const TextStyle(fontSize: 11)),
                    trailing: Text('${s['tenantId']}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  ),
                )),
          const SizedBox(height: 16),
          const Card(
            elevation: 0,
            child: ListTile(
              leading: Icon(Icons.new_releases_outlined, color: AppColors.secondary),
              title: Text('Platform Release v2.0.0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('Multi-tenant isolation, 5-step onboarding wizard, quota enforcement, billing/coupons, tickets, CRM, and backups active.', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String val) => Chip(
        label: Text('$label: $val', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        backgroundColor: AppColors.primaryLight,
      );
}

class BranchesOverviewPage extends StatefulWidget {
  const BranchesOverviewPage({super.key});

  @override
  State<BranchesOverviewPage> createState() => _BranchesOverviewPageState();
}

class _BranchesOverviewPageState extends State<BranchesOverviewPage> {
  List<Map<String, dynamic>> _branches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await ShopRepository().fetchAllBranches();
      if (!mounted) return;
      setState(() {
        _branches = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('All Tenant Branches Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_branches.isEmpty)
            const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No branches found in database.'))))
          else
            ..._branches.map((b) {
              final shop = b['shopId'] as Map<String, dynamic>?;
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.border)),
                child: ListTile(
                  leading: const Icon(Icons.store_mall_directory_outlined, color: AppColors.primary),
                  title: Text('${b['name']} (${b['code']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('Shop: ${shop?['name'] ?? '-'} • ${b['city'] ?? ''} ${b['address'] ?? ''}', style: const TextStyle(fontSize: 11)),
                  trailing: Text((b['isMainBranch'] == true) ? 'Main' : 'Branch', style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class TenantUsersOverviewPage extends StatefulWidget {
  const TenantUsersOverviewPage({super.key});

  @override
  State<TenantUsersOverviewPage> createState() => _TenantUsersOverviewPageState();
}

class _TenantUsersOverviewPageState extends State<TenantUsersOverviewPage> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await ShopRepository().fetchAllTenantUsers();
      if (!mounted) return;
      setState(() {
        _users = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _openResetPasswordDialog(Map<String, dynamic> u) {
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Reset Password (${u['username'] ?? u['fullName']})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password (min 6 chars)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final newPass = passCtrl.text.trim();
              if (newPass.length < 6) return;
              final nav = Navigator.of(ctx);
              final msg = ScaffoldMessenger.of(context);
              try {
                await ShopRepository().resetPlatformUserPassword((u['_id'] ?? u['id']).toString(), newPass);
                nav.pop();
                msg.showSnackBar(SnackBar(
                  content: Text('Password reset for @${u['username'] ?? u['fullName']}!'),
                  backgroundColor: AppColors.success,
                ));
              } catch (e) {
                msg.showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.danger));
              }
            },
            child: const Text('Save Password', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final q = _searchQuery.trim().toLowerCase();
    final filtered = _users.where((u) {
      if (q.isEmpty) return true;
      final username = (u['username'] ?? '').toString().toLowerCase();
      final fullName = (u['fullName'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      final shopName = ((u['defaultShopId'] as Map<String, dynamic>?)?['name'] ?? '').toString().toLowerCase();
      return username.contains(q) || fullName.contains(q) || email.contains(q) || shopName.contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('All Tenant Users Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by username, name, email, or shop...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No tenant users found.'))))
          else
            ...filtered.map((u) {
              final shop = u['defaultShopId'] as Map<String, dynamic>?;
              final username = (u['username'] ?? '-').toString();
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.border)),
                child: ListTile(
                  leading: const Icon(Icons.person_outline, color: AppColors.primary),
                  title: Text('${u['fullName']} (@$username)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('${u['email']} • Shop: ${shop?['name'] ?? '-'}', style: const TextStyle(fontSize: 11)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${u['status'] ?? 'ACTIVE'}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.lock_reset, size: 20, color: AppColors.secondary),
                        tooltip: 'Reset Password',
                        onPressed: () => _openResetPasswordDialog(u),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class SuperAdminProfilePage extends StatelessWidget {
  const SuperAdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  CircleAvatar(radius: 24, backgroundColor: AppColors.secondary, child: Text('SA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Super Admin Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Platform Root Administrator', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 28),
              Text('Name: ${user?.fullName ?? 'Super Admin'}', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 6),
              Text('Email: ${user?.email ?? 'superadmin@nextplanners.com'}', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 6),
              Text('Role: ${user?.roleName ?? 'SUPER_ADMIN'}', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                onPressed: () => AuthService().logout(),
                icon: const Icon(Icons.logout, color: Colors.white, size: 16),
                label: const Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BackupsMaintenancePage extends StatefulWidget {
  const BackupsMaintenancePage({super.key});

  @override
  State<BackupsMaintenancePage> createState() => _BackupsMaintenancePageState();
}

class _BackupsMaintenancePageState extends State<BackupsMaintenancePage> {
  String _lastBackup = 'Never';
  bool _maintenance = false;
  bool _loading = true;
  Map<String, dynamic> _lastCounts = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await ShopRepository().fetchSystemSettings();
      if (!mounted) return;
      setState(() {
        _maintenance = s['maintenanceMode'] as bool? ?? false;
        _lastBackup = s['lastBackupAt'] != null ? RegisteredShopItem.formatDate(s['lastBackupAt']) : 'Never';
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Backups & System Maintenance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.storage_outlined, color: AppColors.primary),
                    title: const Text('MongoDB Database Backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('Last Snapshot: $_lastBackup • Schedule: Daily 02:00 AM', style: const TextStyle(fontSize: 12)),
                    trailing: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final res = await ShopRepository().triggerBackup();
                        setState(() {
                          _lastBackup = RegisteredShopItem.formatDate(res['backupAt']);
                          _lastCounts = (res['counts'] as Map<String, dynamic>?) ?? {};
                        });
                        messenger.showSnackBar(const SnackBar(content: Text('Database backup snapshot completed!'), backgroundColor: AppColors.success));
                      },
                      icon: const Icon(Icons.backup_outlined, size: 16, color: Colors.white),
                      label: const Text('Backup Now', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                  if (_lastCounts.isNotEmpty) ...[
                    const Divider(),
                    Text(
                      'Snapshot Records — Shops: ${_lastCounts['shops'] ?? 0}, Users: ${_lastCounts['users'] ?? 0}, Plans: ${_lastCounts['plans'] ?? 0}, Subscriptions: ${_lastCounts['subscriptions'] ?? 0}, Invoices: ${_lastCounts['invoices'] ?? 0}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                  const Divider(height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Maintenance Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Temporarily block non-admin tenant logins during upgrades', style: TextStyle(fontSize: 11)),
                    value: _maintenance,
                    onChanged: (v) async {
                      setState(() => _maintenance = v);
                      await ShopRepository().updateSystemSettings({'maintenanceMode': v});
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
