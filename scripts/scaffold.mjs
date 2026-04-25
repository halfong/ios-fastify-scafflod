#!/usr/bin/env node
/**
 * Scaffold script for ios-fastify-scaffold template.
 *
 * Usage:
 *   npm run scaffold           # interactive prompts
 *   npm run scaffold -- --force  # overwrite even if already scaffolded
 *
 * Tokens replaced across repo text files:
 *   __APP_NAME__       iOS app display name
 *   __BUNDLE_ID__      iOS bundle identifier (e.g. com.example.myapp)
 *   __SERVER_NAME__    npm package name for the server (e.g. my-api-server)
 *   __SERVER_PORT__    TCP port the server listens on (e.g. 3000)
 *   __API_BASE_URL__   Base URL iOS client uses to reach the server
 */

import { existsSync, writeFileSync } from "fs";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";
import fg from "fast-glob";
import replaceInFilePkg from "replace-in-file";
const { replaceInFile } = replaceInFilePkg;
import prompts from "prompts";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, "..");
const MARKER = resolve(ROOT, ".scaffolded");

const args = process.argv.slice(2);
const force = args.includes("--force");

// ---------------------------------------------------------------------------
// Guard: prevent re-running unless --force
// ---------------------------------------------------------------------------
if (existsSync(MARKER) && !force) {
  console.error(
    "\n❌  This repo has already been scaffolded.\n" +
      "    Run with --force to overwrite: npm run scaffold -- --force\n"
  );
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Prompts
// ---------------------------------------------------------------------------
const response = await prompts(
  [
    {
      type: "text",
      name: "appName",
      message: "iOS app display name",
      initial: "MyApp",
      validate: (v) => (v.trim().length > 0 ? true : "App name is required"),
    },
    {
      type: "text",
      name: "bundleId",
      message: "iOS bundle identifier (e.g. com.example.myapp)",
      initial: "com.example.myapp",
      validate: (v) =>
        /^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$/i.test(v.trim())
          ? true
          : "Enter a valid reverse-DNS bundle ID",
    },
    {
      type: "text",
      name: "serverName",
      message: "Server npm package name (e.g. my-api-server)",
      initial: "my-api-server",
      validate: (v) =>
        /^[a-z][a-z0-9-]*$/.test(v.trim())
          ? true
          : "Use lowercase letters, numbers and hyphens only",
    },
    {
      type: "text",
      name: "serverPort",
      message: "Server port",
      initial: "3000",
      validate: (v) =>
        /^\d{1,5}$/.test(v.trim()) ? true : "Enter a valid port number",
    },
    {
      type: "text",
      name: "apiBaseUrl",
      message: "API base URL (as seen by the iOS client)",
      initial: "http://localhost:3000",
      validate: (v) =>
        v.trim().startsWith("http") ? true : "Enter a valid URL (http/https)",
    },
  ],
  {
    onCancel: () => {
      console.log("\nScaffolding cancelled.");
      process.exit(0);
    },
  }
);

const { appName, bundleId, serverName, serverPort, apiBaseUrl } = response;

console.log("\n🔧  Applying tokens…\n");

// ---------------------------------------------------------------------------
// File discovery — text files only, skip known binary/generated paths
// ---------------------------------------------------------------------------
const files = await fg(
  [
    "**/*.{ts,js,mjs,cjs,json,md,txt,env,example,yaml,yml,swift,plist,xcconfig,pbxproj,storyboard,xib,html,sh}",
    "**/.env.example",
    "**/README.md",
  ],
  {
    cwd: ROOT,
    absolute: true,
    dot: true,
    ignore: [
      "**/node_modules/**",
      "**/.git/**",
      "**/xcuserdata/**",
      "**/DerivedData/**",
      "**/*.xcuserstate",
      "**/dist/**",
      "**/build/**",
      "**/.build/**",
      "**/.swiftpm/**",
      "**/Pods/**",
      "**/Carthage/**",
      // Skip the scaffold script itself to avoid self-modification issues
      "**/scripts/scaffold.mjs",
    ],
  }
);

if (files.length === 0) {
  console.warn("⚠️  No files matched for token replacement.");
}

// ---------------------------------------------------------------------------
// Token replacement map
// ---------------------------------------------------------------------------
const tokenMap = [
  { from: /__APP_NAME__/g, to: appName.trim() },
  { from: /__BUNDLE_ID__/g, to: bundleId.trim() },
  { from: /__SERVER_NAME__/g, to: serverName.trim() },
  { from: /__SERVER_PORT__/g, to: serverPort.trim() },
  { from: /__API_BASE_URL__/g, to: apiBaseUrl.trim() },
];

// Apply all replacements to all files in a single pass per token
for (const { from, to } of tokenMap) {
  const results = await replaceInFile({ files, from, to });
  const changed = results.filter((r) => r.hasChanged).map((r) => r.file);
  if (changed.length > 0) {
    console.log(`  ✔  ${from.source.replace(/\\/g, "")}  →  "${to}"  (${changed.length} file(s))`);
  }
}

// ---------------------------------------------------------------------------
// Write .scaffolded marker
// ---------------------------------------------------------------------------
const timestamp = new Date().toISOString();
writeFileSync(
  MARKER,
  `Scaffolded on ${timestamp}\nApp: ${appName}\nBundle ID: ${bundleId}\nServer: ${serverName}:${serverPort}\nAPI: ${apiBaseUrl}\n`
);

console.log(`
✅  Scaffolding complete!

Next steps:
  1. Install server dependencies:
       cd server && npm install
  2. Copy the server env file:
       cp server/.env.example server/.env
  3. Start the dev server:
       npm run server:dev
  4. Open the iOS project in Xcode:
       open ios/App/App.xcodeproj
`);
