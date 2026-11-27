# Next Planners POS – Enterprise Multi-Tenant RBAC & Shop Management System

**Product:** Next Planners POS  
**Company:** Next Planners Tech Solution (NPTS)  
**Architecture:** Multi-Tenant SaaS with Branch-Level Granular Access Control  
**Frontend:** Flutter (Mobile, Desktop, Web)  
**Backend:** Node.js + Express.js  
**Database:** MongoDB + Mongoose  

---

## 1. System Architecture & Features

- **Platform-Level Roles:** Super Admin, Support Admin.
- **Predefined Shop-Level Roles (9 Standard Roles):**
  - Shop Owner
  - Shop Administrator
  - Branch Manager
  - Sales Manager
  - Cashier / POS Operator
  - Inventory Manager
  - Purchase Officer
  - Accountant / Finance Officer
  - Auditor / Read-Only User
- **Custom Roles:** Unlimited custom roles configurable without modifying code.
- **17 Granular Permission Modules:** Dashboard, POS, Products, Categories, Brands, Inventory, Purchases, Sales, Customers, Suppliers, Expenses, Accounts, Users, Roles, Reports, Branches, Settings, Subscription, Approvals, and Audit.
- **Branch-Level Access Control:** Scoped to `ALL_BRANCHES`, `ASSIGNED_BRANCH`, or `SPECIFIC_BRANCH`.
- **User-Level Permission Overrides:** Granular `ALLOW` grants or explicit `DENY` revokes with expiration dates.
- **Approval Workflows:** Threshold-based triggers (e.g. discount > 10%, refunds > Rs. 5,000, stock write-offs) with cryptographic self-approval prevention.
- **Tamper-Proof Audit Logging:** Append-only immutable log collection.
- **Official Brand Tokens:**
  - Primary: `#123B8B` (Navy Blue)
  - Secondary: `#FF7900` (Vibrant Orange)
  - Success: `#16A34A`
  - Danger: `#DC2626`
  - Background: `#F5F6FA`
  - Typography: Poppins

---

## 2. Directory Structure

```text
mobile-app-pos/
├── backend/
│   ├── src/
│   │   ├── config/
│   │   ├── controllers/         # Auth, Roles, Users, Approvals, Audit
│   │   ├── middleware/          # Auth, Tenant, Branch, Authorization
│   │   ├── models/              # User, Role, Permission, Branch, Shop, Audit, etc.
│   │   ├── permissions/         # Permission catalog (17 modules, 11 roles)
│   │   ├── routes/              # Express REST routes
│   │   ├── seeds/               # Seeder for system roles & permissions
│   │   ├── services/            # Centralized Permission, Audit & Approval engines
│   │   ├── app.js               # Express application
│   │   └── server.js            # Server entrypoint
│   ├── tests/
│   │   └── rbac.test.js         # Security and RBAC unit/integration tests
│   └── package.json
│
└── frontend/
    ├── lib/
    │   ├── core/
    │   │   ├── constants/       # App permissions
    │   │   ├── services/        # AuthService & Session state
    │   │   ├── theme/           # AppColors & AppTheme (#123B8B, #FF7900)
    │   │   └── widgets/         # PermissionGuard widget
    │   ├── features/
    │   │   ├── roles/           # Roles & permissions management screen
    │   │   ├── users/           # Employee directory & branch scope screen
    │   │   ├── approvals/       # Operational threshold approvals screen
    │   │   └── audit_logs/      # Immutable audit trail screen
    │   ├── presentation/
    │   │   └── shell/           # Responsive brand sidebar & topbar
    │   └── main.dart            # Flutter application entrypoint
    └── pubspec.yaml
```

---

## 3. Running the Backend

```bash
cd backend
npm install
npm test            # Run RBAC security test suite
npm run seed        # Seed all 17 permission modules and 11 default roles
npm start           # Starts on port 5000
```

## 4. Running the Flutter Client

```bash
cd frontend
flutter pub get
flutter run -d chrome  # Or windows / android / ios
flutter build apk --release
flutter build apk --split-per-abi

cd i:\mobile-app-pos\frontend
flutter clean
flutter pub get

```
