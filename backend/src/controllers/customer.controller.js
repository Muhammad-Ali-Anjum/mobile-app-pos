const { Customer } = require('../models');
const auditService = require('../services/audit.service');

class CustomerController {
  async listCustomers(req, res) {
    try {
      const { search } = req.query;
      const query = { shopId: req.shopId };
      if (search) {
        query.$or = [
          { fullName: { $regex: search, $options: 'i' } },
          { phone: { $regex: search, $options: 'i' } }
        ];
      }

      const customers = await Customer.find(query).sort({ fullName: 1 }).lean();
      const totalCustomers = await Customer.countDocuments({ shopId: req.shopId });
      const activeCustomers = await Customer.countDocuments({ shopId: req.shopId, status: 'ACTIVE' });
      const withBalance = await Customer.countDocuments({ shopId: req.shopId, currentBalance: { $gt: 0 } });

      return res.status(200).json({
        success: true,
        data: customers,
        summary: {
          totalCustomers,
          activeCustomers,
          withBalance
        }
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  async createCustomer(req, res) {
    try {
      const { fullName, phone, email, address, creditLimit } = req.body;
      if (!fullName || !phone) {
        return res.status(400).json({ success: false, message: 'Customer name and phone are required.' });
      }

      const customer = new Customer({
        shopId: req.shopId,
        fullName: fullName.trim(),
        phone: phone.trim(),
        email: email || '',
        address: address || '',
        creditLimit: creditLimit || 50000
      });

      const saved = await customer.save();

      await auditService.log({
        shopId: req.shopId,
        userId: req.user._id,
        action: 'CUSTOMER_CREATED',
        module: 'customers',
        recordId: saved._id.toString(),
        newValues: { fullName, phone },
        req
      });

      return res.status(201).json({
        success: true,
        message: 'Customer added successfully.',
        data: saved
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}

module.exports = new CustomerController();

