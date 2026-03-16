const pptxgen = require('pptxgenjs');
const fs = require('fs');
const path = require('path');

// Configuration
const CONFIG = {
 slides: 'slides.json',
 theme: 'theme.json',
 output: 'presentation.pptx',
 assets: 'assets'
};

async function generateDeck() {
 // 1. Load Config
 if (!fs.existsSync(CONFIG.slides) || !fs.existsSync(CONFIG.theme)) {
 console.error("Error: Missing slides.json or theme.json. Run `node scripts/bootstrap_deck.js` first.");
 process.exit(1);
 }
 const slides = JSON.parse(fs.readFileSync(CONFIG.slides, 'utf8'));
 const theme = JSON.parse(fs.readFileSync(CONFIG.theme, 'utf8'));

 // 2. Init Pres
 const pres = new pptxgen();
 pres.layout = 'LAYOUT_16x9';

 // 3. Generate Slides
 slides.forEach((slideData, index) => {
 let slide = pres.addSlide();

 // Background
 slide.background = { color: theme.colors.background };

 // Header
 slide.addText(slideData.module || theme.defaultModule, {
 x: 0.5, y: 0.4, w: 4, h: 0.5,
 fontFace: theme.fonts.mono, fontSize: 14, color: theme.colors.accent, charSpacing: 2
 });
 slide.addShape('line', {
 x: 0.5, y: 0.8, w: 9, h: 0,
 line: { color: theme.colors.border, width: 1 }
 });

 // Title
 slide.addText(slideData.title, {
 x: 0.5, y: 1.2, w: 4.5, h: 1.5,
 fontFace: theme.fonts.header, fontSize: 36, color: theme.colors.text, valign: 'top'
 });

 // Body Content
 if (slideData.body) {
 slide.addText(slideData.body, {
 x: 0.5, y: 3.0, w: 4.5, h: 3.5,
 fontFace: theme.fonts.body, fontSize: 18, color: theme.colors.textDim, lineSpacing: 24, valign: 'top'
 });
 }

 // Sidebar / Visuals
 if (slideData.visual) {
 const visualPath = path.join(CONFIG.assets, slideData.visual);
 if (fs.existsSync(visualPath)) {
 slide.addImage({
 path: visualPath,
 x: 5.5, y: 1.2, w: 4.0, h: 3.0,
 sizing: { type: 'contain', w: 4.0, h: 3.0 }
 });
 } else {
 // Placeholder if missing
 slide.addText("Missing Visual: " + slideData.visual, { x: 5.5, y: 1.2, w: 4, h: 3, color: 'FF0000' });
 }
 }

 // Custom Code/Shapes (LLM Generated)
 // If the JSON contains raw pptxgenjs shape definitions, render them.
 if (slideData.shapes && Array.isArray(slideData.shapes)) {
 slideData.shapes.forEach(shape => {
 // shape = { type: 'rect', options: { ... } }
 if (shape.type === 'text') {
 slide.addText(shape.text, shape.options);
 } else {
 slide.addShape(shape.type, shape.options);
 }
 });
 }

 // Notes
 if (slideData.notes) slide.addNotes(slideData.notes);
 });

 // 4. Save
 await pres.writeFile({ fileName: CONFIG.output });
 console.log(`Generated: ${CONFIG.output}`);
}

generateDeck().catch(console.error);
