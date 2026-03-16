const fs = require('fs');

// Slide Data (Simplified from Academy Deck)
const SLIDES = [
 { title: "Course 101: The Agent POS", module: "Intro", intent: "Hook the audience. Define the problem." },
 { title: "Context Rot", module: "Why", intent: "Explain why current AI fails." },
 { title: "The God File", module: "Why", intent: "Show the chaos of big docs." },
 { title: "Visualizing the 4 Tiers", module: "Structure", intent: "Metaphor: The Building." },
 { title: "Tier 1: Constitution", module: "Structure", intent: "Foundation/Safety." },
 { title: "JIT Funnel", module: "Structure", intent: "Metaphor: Filtering Noise." },
 { title: "Stability (Ω)", module: "Brain", intent: "The Math of feasibility." },
 { title: "Coherence Loop", module: "Ops", intent: "Verification loop." }
];

function generateScript() {
 let script = "# Vibe Ops Academy: Speaker Script\n\n";
 let totalTime = 0;

 SLIDES.forEach((slide, index) => {
 script += `## Slide ${index + 1}: ${slide.title}\n`;
 script += `**Goal**: ${slide.intent}\n\n`;

 // Mocking the "Coach" logic
 if (slide.module === "Intro") {
 script += "**Script**:\n";
 script += '"Welcome to Vibe Ops Academy. We are here to stop pasting files and start building systems."\n';
 script += '"This isn\'t a prompt engineering course. It\'s an Operating System course."\n\n';
 totalTime += 30;
 } else if (slide.title === "Context Rot") {
 script += "**Script**:\n";
 script += '"See this graph? This is your agent\'s IQ dropping every time you hit Enter."\n';
 script += '"We call this Context Rot. It\'s why your agent writes buggy code after 10 minutes."\n\n';
 totalTime += 45;
 } else if (slide.title === "Visualizing the 4 Tiers") {
 script += "**Script**:\n";
 script += '"Think of the OS as a building."\n';
 script += '"The Foundation is the Constitution. It never moves."\n';
 script += '"The Penthouse is the Context. It changes every day."\n';
 script += '"You don\'t build a penthouse without a foundation."\n\n';
 totalTime += 60;
 } else {
 script += "**Script**:\n";
 script += '"[Explain ' + slide.title + ' using the visual asset...]"\n\n';
 totalTime += 30;
 }
 });

 script += `---\n**Total Estimated Time**: ${Math.ceil(totalTime / 60)} minutes`;

 fs.writeFileSync('docs/presentations/vibe_kb_academy_script.md', script);
}

generateScript();
