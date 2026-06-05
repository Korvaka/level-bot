#!/usr/bin/env node
/**
 * Seeds the Firestore `exercises` collection from exercises_seed.json.
 *
 * Usage:
 *   npm install firebase-admin
 *   export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccountKey.json
 *   node scripts/seed_exercises.js
 *
 * Or pass the key file as an argument:
 *   node scripts/seed_exercises.js /path/to/serviceAccountKey.json
 */

const admin = require('firebase-admin');
const path = require('path');
const exercises = require('./exercises_seed.json');

const PROJECT_ID = 'bulkrep-6d946';

// Allow passing service account key path as CLI argument
const keyArg = process.argv[2];
if (keyArg) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS = path.resolve(keyArg);
}

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId: PROJECT_ID,
});

const db = admin.firestore();

async function seed() {
  const collection = db.collection('exercises');
  const batch = db.batch();
  let count = 0;

  for (const exercise of exercises) {
    const docRef = collection.doc(exercise.id);
    batch.set(docRef, {
      name: exercise.name,
      description: exercise.description || '',
      // seed JSON may use 'muscleGroup'; Firestore model expects 'primaryMuscle'
      primaryMuscle: exercise.primaryMuscle || exercise.muscleGroup || 'chest',
      secondaryMuscles: exercise.secondaryMuscles || [],
      equipment: exercise.equipment || 'none',
      category: exercise.category || 'compound',
      difficulty: exercise.difficulty || 'intermediate',
      instructions: exercise.instructions || [],
      tips: exercise.tips || [],
      commonMistakes: exercise.commonMistakes || [],
      gifUrl: exercise.gifUrl || null,
      videoUrl: exercise.videoUrl || null,
      thumbnailUrl: exercise.thumbnailUrl || null,
      isCustom: false,
      createdBy: null,
      aliases: exercise.aliases || [],
      videos: [],
    });
    count++;

    // Firestore batches are limited to 500 operations
    if (count % 499 === 0) {
      await batch.commit();
      console.log(`Committed ${count} exercises...`);
    }
  }

  await batch.commit();
  console.log(`Done! Seeded ${count} exercises into Firestore.`);
  process.exit(0);
}

seed().catch((err) => {
  console.error('Error seeding exercises:', err);
  process.exit(1);
});
