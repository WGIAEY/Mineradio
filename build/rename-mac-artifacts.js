// Rename macOS build artifacts: arm64 → apple, x64 → intel
const fs = require('fs');
const path = require('path');

const DIST = path.join(__dirname, '..', 'dist');
if (!fs.existsSync(DIST)) {
  console.log('  • dist/ not found, nothing to rename');
  process.exit(0);
}

const mapping = {
  arm64: 'apple',
  x64: 'intel',
};

const files = fs.readdirSync(DIST).filter(f => /\.(dmg|zip|blockmap)$/i.test(f));
let renamed = 0;

files.forEach(file => {
  let newName = file;
  for (const [from, to] of Object.entries(mapping)) {
    if (newName.includes(from)) {
      newName = newName.replace(from, to);
    }
  }
  if (newName !== file) {
    const oldPath = path.join(DIST, file);
    const newPath = path.join(DIST, newName);
    fs.renameSync(oldPath, newPath);
    console.log('  •', file, '→', newName);
    renamed++;
  }
});

if (!renamed) console.log('  • no macOS artifacts to rename');
