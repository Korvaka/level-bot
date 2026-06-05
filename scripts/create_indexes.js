#!/usr/bin/env node
/**
 * Creates all required Firestore composite indexes for the app.
 *
 * Usage:
 *   npm install firebase-admin
 *   node scripts/create_indexes.js /path/to/serviceAccountKey.json
 *
 * Or with env var:
 *   export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccountKey.json
 *   node scripts/create_indexes.js
 */

const admin = require('firebase-admin');
const https = require('https');
const path = require('path');

const PROJECT_ID = 'bulkrep-6d946';
const DB_PATH = `projects/${PROJECT_ID}/databases/(default)`;

const keyArg = process.argv[2];
if (keyArg) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS = path.resolve(keyArg);
}

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId: PROJECT_ID,
});

// All composite indexes required by the app
const INDEXES = [
  {
    collection: 'posts',
    fields: [
      { fieldPath: 'userId', order: 'ASCENDING' },
      { fieldPath: 'createdAt', order: 'DESCENDING' },
    ],
  },
  {
    collection: 'posts',
    fields: [
      { fieldPath: 'likesCount', order: 'DESCENDING' },
      { fieldPath: 'createdAt', order: 'DESCENDING' },
    ],
  },
  {
    collection: 'workout_sessions',
    fields: [
      { fieldPath: 'userId', order: 'ASCENDING' },
      { fieldPath: 'completedAt', order: 'DESCENDING' },
    ],
  },
  {
    collection: 'workout_sessions',
    fields: [
      { fieldPath: 'userId', order: 'ASCENDING' },
      { fieldPath: 'status', order: 'ASCENDING' },
      { fieldPath: 'completedAt', order: 'DESCENDING' },
    ],
  },
  {
    collection: 'personal_records',
    fields: [
      { fieldPath: 'userId', order: 'ASCENDING' },
      { fieldPath: 'achievedAt', order: 'DESCENDING' },
    ],
  },
  {
    collection: 'personal_records',
    fields: [
      { fieldPath: 'userId', order: 'ASCENDING' },
      { fieldPath: 'exerciseId', order: 'ASCENDING' },
      { fieldPath: 'achievedAt', order: 'DESCENDING' },
    ],
  },
  {
    collection: 'programs',
    fields: [
      { fieldPath: 'userId', order: 'ASCENDING' },
      { fieldPath: 'isArchived', order: 'ASCENDING' },
      { fieldPath: 'createdAt', order: 'DESCENDING' },
    ],
  },
  {
    collection: 'programs',
    fields: [
      { fieldPath: 'isPublic', order: 'ASCENDING' },
      { fieldPath: 'isArchived', order: 'ASCENDING' },
      { fieldPath: 'likesCount', order: 'DESCENDING' },
    ],
  },
  {
    collection: 'exercises',
    fields: [
      { fieldPath: 'primaryMuscle', order: 'ASCENDING' },
      { fieldPath: 'name', order: 'ASCENDING' },
    ],
  },
  {
    collection: 'exercises',
    fields: [
      { fieldPath: 'equipment', order: 'ASCENDING' },
      { fieldPath: 'name', order: 'ASCENDING' },
    ],
  },
];

async function getAccessToken() {
  const token = await admin.app().options.credential.getAccessToken();
  return token.access_token;
}

function httpsPost(url, body, token) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(body);
    const urlObj = new URL(url);
    const options = {
      hostname: urlObj.hostname,
      path: urlObj.pathname,
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data),
      },
    };
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => { body += chunk; });
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(body) }); }
        catch { resolve({ status: res.statusCode, body }); }
      });
    });
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

async function createIndex(token, collection, fields) {
  const url = `https://firestore.googleapis.com/v1/${DB_PATH}/collectionGroups/${collection}/indexes`;
  const body = {
    queryScope: 'COLLECTION',
    fields: fields.map((f) => ({
      fieldPath: f.fieldPath,
      order: f.order,
    })),
  };
  return httpsPost(url, body, token);
}

async function main() {
  console.log(`Creating Firestore indexes for project: ${PROJECT_ID}\n`);

  let token;
  try {
    token = await getAccessToken();
  } catch (e) {
    console.error('Failed to get access token. Is GOOGLE_APPLICATION_CREDENTIALS set?');
    console.error(e.message);
    process.exit(1);
  }

  let created = 0;
  let skipped = 0;
  let errors = 0;

  for (const idx of INDEXES) {
    const fieldDesc = idx.fields.map((f) => `${f.fieldPath}(${f.order})`).join(', ');
    const desc = `[${idx.collection}] ${fieldDesc}`;

    const result = await createIndex(token, idx.collection, idx.fields);

    if (result.status === 200 || result.status === 201) {
      console.log(`  ✓ Creating: ${desc}`);
      console.log(`    State: ${result.body.state || 'CREATING'} (building in background)`);
      created++;
    } else if (result.status === 409) {
      console.log(`  = Already exists: ${desc}`);
      skipped++;
    } else {
      console.error(`  ✗ Error (${result.status}): ${desc}`);
      console.error(`    ${JSON.stringify(result.body?.error || result.body)}`);
      errors++;
    }
  }

  console.log(`\nDone: ${created} created, ${skipped} already existed, ${errors} errors`);
  if (created > 0) {
    console.log('\nNote: Indexes are being built in the background by Firestore.');
    console.log('They will be ready in 1–5 minutes. The app will work once all are READY.');
  }

  process.exit(errors > 0 ? 1 : 0);
}

main().catch((e) => { console.error(e); process.exit(1); });
