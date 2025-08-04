const express = require('express');
const User = require('../models/User');
const authenticateToken = require('../middleware/auth');
const router = express.Router();

// Create or update user profile and emergency contacts
router.post('/profile', authenticateToken, async (req, res) => {
  const { name, phone, emergencyContacts } = req.body;
  const uid = req.user.uid;

  if (!name || !phone || !Array.isArray(emergencyContacts) || emergencyContacts.length !== 5) {
    return res.status(400).json({ message: 'Name, phone, and exactly 5 emergency contacts are required.' });
  }

  let user = await User.findOneAndUpdate(
    { uid },
    { name, phone, emergencyContacts },
    { upsert: true, new: true }
  );
  res.json(user);
});

// Get user profile and emergency contacts
router.get('/profile', authenticateToken, async (req, res) => {
  const uid = req.user.uid;
  const user = await User.findOne({ uid });
  if (!user) return res.status(404).json({ message: 'User not found' });
  res.json(user);
});

module.exports = router; 