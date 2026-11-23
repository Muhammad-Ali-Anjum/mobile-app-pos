import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/permission_guard.dart';
import '../../../core/constants/permissions.dart';

class EmployeeModel {
  final String id;
  final String fullName;
  final String email;
  final String employeeId;
  final String roleName;
  final String branchScope;
  bool isActive;

  EmployeeModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.employeeId,
    required this.roleName,
    required this.branchScope,
    this.isActive = true,
  });
}

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final List<EmployeeModel> _employees = [
    EmployeeModel(
      id: '1',
      fullName: 'Ali Khan',
      email: 'ali@abc.com',
      employeeId: 'EMP-001',
      roleName: 'Shop Owner',
      branchScope: 'All Branches (Skardu, Gilgit, Islamabad)',
      isActive: true,
    ),
    EmployeeModel(
      id: '2',
      fullName: 'Fatima Ali',
      email: 'fatima@abc.com',
      employeeId: 'EMP-002',
      roleName: 'Branch Manager',
      branchScope: 'Main Branch – Skardu',
      isActive: true,
    ),
    EmployeeModel(
      id: '3',
      fullName: 'Usman Raza',
      email: 'usman@abc.com',
      employeeId: 'EMP-003',
      roleName: 'Cashier / POS Operator',
      branchScope: 'Main Branch – Skardu',
      isActive: true,
    ),
    EmployeeModel(
      id: '4',
      fullName: 'Sana Malik',
      email: 'sana@abc.com',
      employeeId: 'EMP-004',
      roleName: 'Accountant',
      branchScope: 'All Branches',
      isActive: true,
    ),
    EmployeeModel(
      id: '5',
      fullName: 'Tariq Mehmood',
      email: 'tariq@abc.com',
      employeeId: 'EMP-005',
      roleName: 'Inventory Manager',
      branchScope: 'Gilgit Branch',
      isActive: false, // Suspended demo
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Employee & User Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage staff credentials, assigned roles, branch authorizations and active status',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                PermissionGuard(
                  permission: AppPermissions.usersCreate,
                  child: ElevatedButton.icon(
                    onPressed: () => _openAddEmployeeDialog(context),
                    icon: const Icon(Icons.person_add, size: 20),
                    label: const Text('Add Employee'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Employee Table Card
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 3, child: Text('EMPLOYEE', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('EMPLOYEE ID', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('ASSIGNED ROLE', style: _headerStyle)),
                            Expanded(flex: 3, child: Text('BRANCH SCOPE', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('STATUS', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('ACTIONS', style: _headerStyle)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Table Rows
                      Expanded(
                        child: ListView.separated(
                          itemCount: _employees.length,
                          separatorBuilder: (ctx, i) => const Divider(height: 1, color: AppColors.border),
                          itemBuilder: (context, index) {
                            final emp = _employees[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: AppColors.primaryLight,
                                          child: Text(
                                            emp.fullName.substring(0, 1),
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              emp.fullName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              emp.email,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      emp.employeeId,
                                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          emp.roleName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      emp.branchScope,
                                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: emp.isActive ? AppColors.successLight : AppColors.dangerLight,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          emp.isActive ? 'ACTIVE' : 'SUSPENDED',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: emp.isActive ? AppColors.success : AppColors.danger,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 18, color: AppColors.textSecondary),
                                          onPressed: () {},
                                          tooltip: 'Edit / Assign Role',
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            emp.isActive ? Icons.block : Icons.check_circle,
                                            size: 18,
                                            color: emp.isActive ? AppColors.danger : AppColors.success,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              emp.isActive = !emp.isActive;
                                            });
                                          },
                                          tooltip: emp.isActive ? 'Suspend User' : 'Activate User',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddEmployeeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Employee'),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(decoration: const InputDecoration(labelText: 'Full Name')),
                const SizedBox(height: 12),
                TextField(decoration: const InputDecoration(labelText: 'Email Address')),
                const SizedBox(height: 12),
                TextField(decoration: const InputDecoration(labelText: 'Employee ID (e.g. EMP-101)')),
                const SizedBox(height: 12),
                TextField(decoration: const InputDecoration(labelText: 'Initial Password'), obscureText: true),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Role'),
                  items: const [
                    DropdownMenuItem(value: 'Cashier', child: Text('Cashier / POS Operator')),
                    DropdownMenuItem(value: 'Branch Manager', child: Text('Branch Manager')),
                    DropdownMenuItem(value: 'Sales Manager', child: Text('Sales Manager')),
                    DropdownMenuItem(value: 'Inventory Manager', child: Text('Inventory Manager')),
                    DropdownMenuItem(value: 'Accountant', child: Text('Accountant')),
                  ],
                  onChanged: (val) {},
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Save Employee')),
        ],
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.bold,
  color: AppColors.textSecondary,
);

