const jwt = require('jsonwebtoken');
const { User, Shop, Branch, Role, UserRole, UserBranchAccess } = require('../models');
const { JWT_SECRET } = require('../middleware/auth.middleware');
const { ROLES, DEFAULT_ROLE_PERMISSIONS } = require('../permissions/permission.constants');
const permissionService = require('../services/permission.service');
const auditService = require('../services/audit.service');

class AuthController {
  /**
   * User login (Cashiers, Managers, Shop Owners, Super Admins)
   */
  async login(req, res) {
    try {
      const { emailOrUsername, password, shopCode } = req.body;

      if (!emailOrUsername || !password) {
        return res.status(400).json({ success: false, message: 'Email/Username and password are required.' });
      }

      const identifier = emailOrUsername.toLowerCase().trim();
      const user = await User.findOne({
        $or: [{ email: identifier }, { username: identifier }]
      });

      if (!user) {
        return res.status(401).json({ success: false, message: 'Invalid credentials.' });
      }

      if (user.status === 'SUSPENDED') {
        return res.status(403).json({ success: false, message: 'This account has been suspended.' });
      }

      const isMatch = await user.comparePassword(password);
      if (!isMatch) {
        await auditService.log({
          userId: user._id,
          action: 'LOGIN_FAILED',
          module: 'auth',
          req
        });
        return res.status(401).json({ success: false, message: 'Invalid credentials.' });
      }

      // Determine active shop
      let targetShop = null;
      if (shopCode) {
        targetShop = await Shop.findOne({ code: shopCode.toUpperCase() });
      } else if (user.defaultShopId) {
        targetShop = await Shop.findById(user.defaultShopId);
      } else {
        // Find any active shop user is assigned to
        const userRole = await UserRole.findOne({ userId: user._id, status: 'ACTIVE' }).populate('shopId');
        if (userRole && userRole.shopId) {
          targetShop = userRole.shopId;
        }
      }

      // Block login if shop is suspended/deactivated (for non-platform users)
      if (targetShop && !targetShop.isActive && !user.isPlatformUser) {
        return res.status(403).json({
          success: false,
          message: 'Your shop account is suspended or deactivated. Please contact Super Admin.'
        });
      }

      // Resolve user's permissions in this shop
      let permissions = [];
      let roles = [];
      if (targetShop) {
        const permsSet = await permissionService.resolveUserPermissions(user._id, targetShop._id);
        permissions = Array.from(permsSet);

        const userRoles = await UserRole.find({ userId: user._id, shopId: targetShop._id, status: 'ACTIVE' })
          .populate('roleId')
          .lean();
        roles = userRoles.map((ur) => ur.roleId?.name).filter(Boolean);

        // Ensure Shop Owner always has full shop permissions even if RBAC seed wasn't run
        if (String(targetShop.ownerId) === String(user._id)) {
          if (permissions.length === 0) permissions = ['*'];
          if (roles.length === 0) roles = ['Shop Owner'];
        }
      }

      // Generate JWT
      const token = jwt.sign(
        {
          userId: user._id,
          email: user.email,
          shopId: targetShop ? targetShop._id : null
        },
        JWT_SECRET,
        { expiresIn: '24h' }
      );

      user.lastLoginAt = new Date();
      await user.save();

      await auditService.log({
        shopId: targetShop ? targetShop._id : null,
        userId: user._id,
        action: 'LOGIN_SUCCESS',
        module: 'auth',
        req
      });

      return res.status(200).json({
        success: true,
        message: 'Login successful.',
        data: {
          token,
          user: {
            id: user._id,
            fullName: user.fullName,
            email: user.email,
            username: user.username,
            employeeId: user.employeeId,
            isPlatformUser: user.isPlatformUser,
            platformRole: user.platformRole
          },
          shop: targetShop
            ? {
                id: targetShop._id,
                name: targetShop.name,
                code: targetShop.code,
                currency: targetShop.settings?.currency || 'PKR',
                currencySymbol: targetShop.settings?.currencySymbol || 'Rs.'
              }
            : null,
          roles,
          permissions
        }
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Shop Registration (Strictly restricted to Platform Super Admin)
   * Super Admin registers new tenant shops and provisions the Shop Owner account.
   */
  async registerShop(req, res) {
    try {
      // Authorization Check: Only Platform Super Admin can register shops
      if (!req.user || !req.user.isPlatformUser || req.user.platformRole !== 'super_admin') {
        return res.status(403).json({
          success: false,
          message: 'Access Denied: Only Platform Super Admin is authorized to register and provision new shops.'
        });
      }

      const {
        shopName,
        shopCode,
        fullName,
        email,
        password,
        phone,
        plan = 'STANDARD',
        branchName = 'Main Branch',
        branchCity = 'Main'
      } = req.body;

      if (!shopName || !email || !password || !fullName) {
        return res.status(400).json({
          success: false,
          message: 'Shop name, owner full name, email, and password are required.'
        });
      }

      const existingUser = await User.findOne({ email: email.toLowerCase().trim() });
      if (existingUser) {
        return res.status(400).json({ success: false, message: 'Email is already registered.' });
      }

      const cleanCode = (shopCode || shopName.substring(0, 4) + Math.floor(100 + Math.random() * 900)).toUpperCase();
      const existingShop = await Shop.findOne({ code: cleanCode });
      if (existingShop) {
        return res.status(400).json({ success: false, message: 'Shop code already taken.' });
      }

      // 1. Create Owner User
      const passwordHash = await User.hashPassword(password);
      const user = new User({
        fullName: fullName.trim(),
        email: email.toLowerCase().trim(),
        username: email.split('@')[0].toLowerCase().trim(),
        phone: phone || '',
        passwordHash,
        status: 'ACTIVE'
      });
      const savedUser = await user.save();

      // 2. Create Shop
      const shop = new Shop({
        name: shopName.trim(),
        code: cleanCode,
        ownerId: savedUser._id,
        subscription: {
          plan: 'TRIAL',
          status: 'ACTIVE',
          maxBranches: 1,
          maxUsers: 5,
          expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) // 30-day trial
        }
      });
      const savedShop = await shop.save();

      savedUser.defaultShopId = savedShop._id;
      await savedUser.save();

      // 3. Create Default Main Branch
      const branch = new Branch({
        shopId: savedShop._id,
        name: branchName,
        code: 'BR-01',
        city: branchCity,
        managerId: savedUser._id,
        isMainBranch: true,
        isActive: true
      });
      const savedBranch = await branch.save();

      // 4. Find or Create SHOP_OWNER System Role
      let ownerRole = await Role.findOne({ slug: ROLES.SHOP_OWNER, isSystemRole: true });
      if (!ownerRole) {
        ownerRole = await Role.create({
          name: 'Shop Owner',
          slug: ROLES.SHOP_OWNER,
          description: 'Complete business management and full authorization',
          roleType: 'DEFAULT_SHOP',
          isSystemRole: true,
          isActive: true
        });
      }

      // 5. Assign Shop Owner Role
      await UserRole.create({
        userId: savedUser._id,
        shopId: savedShop._id,
        roleId: ownerRole._id,
        status: 'ACTIVE'
      });

      // 6. Assign All Branches Access to Owner
      await UserBranchAccess.create({
        userId: savedUser._id,
        shopId: savedShop._id,
        branchId: null,
        accessType: 'ALL_BRANCHES'
      });

      await auditService.log({
        shopId: savedShop._id,
        userId: savedUser._id,
        action: 'SHOP_REGISTERED',
        module: 'shop',
        recordId: savedShop._id.toString(),
        req
      });

      const token = jwt.sign(
        { userId: savedUser._id, email: savedUser.email, shopId: savedShop._id },
        JWT_SECRET,
        { expiresIn: '24h' }
      );

      return res.status(201).json({
        success: true,
        message: 'Shop successfully registered and configured.',
        data: {
          token,
          shop: { id: savedShop._id, name: savedShop.name, code: savedShop.code },
          branch: { id: savedBranch._id, name: savedBranch.name },
          user: { id: savedUser._id, fullName: savedUser.fullName, email: savedUser.email }
        }
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Get current authenticated user profile + effective permissions
   */
  async getProfile(req, res) {
    try {
      const permsSet = req.shopId
        ? await permissionService.resolveUserPermissions(req.user._id, req.shopId)
        : new Set();

      const userRoles = req.shopId
        ? await UserRole.find({ userId: req.user._id, shopId: req.shopId, status: 'ACTIVE' })
            .populate('roleId')
            .lean()
        : [];

      return res.status(200).json({
        success: true,
        data: {
          user: {
            id: req.user._id,
            fullName: req.user.fullName,
            email: req.user.email,
            username: req.user.username,
            employeeId: req.user.employeeId,
            status: req.user.status,
            isPlatformUser: req.user.isPlatformUser,
            platformRole: req.user.platformRole
          },
          shop: req.shop || null,
          roles: userRoles.map((ur) => ur.roleId?.name).filter(Boolean),
          permissions: Array.from(permsSet)
        }
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}

module.exports = new AuthController();
