const mongoose = require('mongoose');

const emergencyContactSchema = new mongoose.Schema({
  name: { type: String, required: true },
  phone: { type: String, required: true },
});

const userSchema = new mongoose.Schema({
  uid: { type: String, required: true, unique: true }, // Firebase UID
  phone: { type: String, required: true },
  name: { type: String },
  emergencyContacts: {
    type: [emergencyContactSchema],
    validate: [arr => arr.length === 5, 'Exactly 5 emergency contacts required'],
    required: true
  },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('User', userSchema); 