#!/usr/bin/env node
/**
 * Lists catalog entities stored in the Backstage database.
 *
 * Usage:
 *   node scripts/check-catalog-db.mjs              # all entities
 *   node scripts/check-catalog-db.mjs <filter>     # filter by name
 */

import pg from 'pg';
import { readFileSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

function loadEnv() {
  try {
    const envPath = resolve(__dirname, '..', '.env');
    for (const line of readFileSync(envPath, 'utf-8').split('\n')) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith('#')) continue;
      const eqIndex = trimmed.indexOf('=');
      if (eqIndex === -1) continue;
      const key = trimmed.slice(0, eqIndex);
      if (!process.env[key]) process.env[key] = trimmed.slice(eqIndex + 1);
    }
  } catch { /* rely on existing env vars */ }
}

loadEnv();

const pool = new pg.Pool({
  host: process.env.POSTGRES_HOST || 'postgres',
  port: parseInt(process.env.POSTGRES_PORT || '5432', 10),
  user: process.env.POSTGRES_USER || 'backstage',
  password: process.env.POSTGRES_PASSWORD || 'backstage',
  database: 'backstage_plugin_catalog',
});

const filter = process.argv[2] || null;

async function main() {
  const client = await pool.connect();
  try {
    const params = [];
    let where = '';
    if (filter) {
      where = 'WHERE final_entity::text ILIKE $1';
      params.push(`%${filter}%`);
    }

    const { rows } = await client.query(
      `SELECT entity_id, final_entity FROM final_entities ${where} ORDER BY entity_id`,
      params,
    );

    // Group by kind
    const byKind = {};
    for (const r of rows) {
      const e = typeof r.final_entity === 'string' ? JSON.parse(r.final_entity) : r.final_entity;
      const kind = e.kind || '?';
      const name = e.metadata?.name || '?';
      const ns = e.metadata?.namespace || 'default';
      (byKind[kind] ??= []).push(`${ns}/${name}`);
    }

    const label = filter ? ` matching "${filter}"` : '';
    console.log(`\nCatalog entities${label}: ${rows.length} total\n`);
    for (const [kind, items] of Object.entries(byKind).sort()) {
      console.log(`  ${kind} (${items.length}):`);
      for (const item of items.sort()) {
        console.log(`    - ${item}`);
      }
    }
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch(err => {
  console.error('check-catalog-db: skipped —', err.message);
});
