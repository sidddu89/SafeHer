const admin = require('firebase-admin');
const serviceAccount = require('./safeher-cb626-firebase-adminsdk-fbsvc-6143cedf88.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin; 