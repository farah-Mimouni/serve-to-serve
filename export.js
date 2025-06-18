const admin = require('firebase-admin');
const fs = require('fs');

const serviceAccount = require('C:/toogo/client/togood-5d7cc-firebase-adminsdk-fbsvc-00e47ae740.json');


admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function exportData() {
  const collections = await db.listCollections();
  const allData = {};

  for (const collection of collections) {
    const snapshot = await collection.get();
    allData[collection.id] = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  }

  fs.writeFileSync('firestore-data.json', JSON.stringify(allData, null, 2));
  console.log('✅ Firestore data exported to firestore-data.json');
}

exportData();
