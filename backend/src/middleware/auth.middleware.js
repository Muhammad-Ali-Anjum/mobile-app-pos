const jwt = require('jsonwebtoken');
const { User, Session } = require('../models');

const JWT_SECRET = process.env.JWT_SECRET || 'npts-pos-super-secure-production-jwt-secret-key-2026';

const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required. Bearer token missing.'
      });
    }

    const token = authHeader.split(' ')[1];
    let decoded;
    try {
      decoded = jwt.verify(token, JWT_SECRET);
    } catch (err) {
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired authentication token.'
      });
    }

    const user = await User.findById(decoded.userId);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'User account not found.'
      });
    }

    if (user.status === 'SUSPENDED') {
      return res.status(403).json({
        success: false,
        message: 'Account has been suspended. Please contact your shop administrator.'
      });
    }

    req.user = user;
    next();
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Internal server error during authentication.',
      error: error.message
    });
  }
};

const requirePlatformAdmin = (req, res, next) => {
  if (!req.user || !req.user.isPlatformUser) {
    return res.status(403).json({
      success: false,
      message: 'Access denied. Platform Super Admin privileges required.'
    });
  }
  next();
};

module.exports = {
  authenticate,
  requirePlatformAdmin,
  JWT_SECRET
};
