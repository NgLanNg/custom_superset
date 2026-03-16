const fs = require('fs');

const FILES = {
 'slides.json': [
 {
 "title": "Welcome to Presentation Engineering",
 "module": "Intro",
 "body": "This deck fits a generic schema. Edit slides.json to add content.",
 "notes": "Speaker notes go here.",
 "visual": "placeholder.png",
 "shapes": []
 }
 ],
 'theme.json': {
 "colors": {
 "background": "0b0e14",
 "text": "e2e8f0",
 "textDim": "94a3b8",
 "accent": "6366f1",
 "border": "334155"
 },
 "fonts": {
 "header": "Arial Black",
 "body": "Arial",
 "mono": "Courier New"
 },
 "defaultModule": "General"
 }
};

if (!fs.existsSync('assets')) fs.mkdirSync('assets');

Object.entries(FILES).forEach(([name, content]) => {
 if (!fs.existsSync(name)) {
 fs.writeFileSync(name, JSON.stringify(content, null, 2));
 console.log(`Created ${name}`);
 } else {
 console.log(`Skipped ${name} (Exists)`);
 }
});
