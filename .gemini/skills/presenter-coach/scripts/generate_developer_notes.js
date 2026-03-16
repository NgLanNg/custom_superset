const fs = require('fs');

// Slide Data with "Developer" Tone
const SLIDES = [
 {
 id: "intro",
 title: "Vibe Ops: The Agent Runtime",
 module: "101",
 notes: "Welcome. We're discussing the Vibe Knowledge Base, specifically the runtime architecture for agentic workflows.\n\nProblem: Most agent implementations suffer from non-deterministic context loading.\n\nSolution: A 4-Tier structured environment that enforces separation of concerns."
 },
 {
 id: "why",
 title: "The Failure Mode: Context Drift",
 module: "Why",
 notes: "Let's talk about 'Context Drift'.\n\nIn a standard chat window, context is a FIFO buffer. As you add new tokens, early instructions get compressed or dropped.\n\nFor complex engineering tasks, this means the agent 'forgets' the tech stack or security constraints defined at the start. We need a persistent state manager."
 },
 {
 id: "godfile",
 title: "Anti-Pattern: The 'God File'",
 module: "Why",
 notes: "A common anti-pattern is the 'God File' - dumping 50 pages of documentation into a system prompt.\n\nThis wastes tokens (increasing cost/latency) and confuses the attention mechanism. Agents perform better with scoped, high-signal context injected Just-In-Time."
 },
 {
 id: "structure",
 title: "Architecture: The 4-Tier Model",
 module: "Structure",
 notes: "We organize knowledge into 4 logical tiers based on volatility and scope:\n\n1. Constitution: Immutable global rules.\n2. Governance: Security/Compliance gates.\n3. Reference: Static technical documentation.\n4. Context: Ephemeral task state."
 },
 {
 id: "tier1",
 title: "Tier 1: The Kernel (Constitution)",
 module: "Structure",
 notes: "Tier 1 is the Kernel. It loads at boot time. \n\nIt defines the identity and non-negotiable constraints (e.g., 'Never commit to main without verification'). This is kept under 500 lines to minimize boot overhead."
 },
 {
 id: "jit",
 title: "Optimization: JIT Context Injection",
 module: "Structure",
 notes: "We use JIT (Just-In-Time) loading for Tiers 2 and 3.\n\nInstead of loading all docs, we use triggers (file types, keywords) to inject specific reference material. This keeps the active context window lean, maximizing the model's reasoning capacity."
 },
 {
 id: "stability",
 title: "Heuristic: The Stability Equation (Ω)",
 module: "Brain",
 notes: "We don't just 'hope' the agent understands. We calculate a Stability Score (Ω) before execution.\n\nΩ = Function of (Intent Clarity + Structured Output) minus (Noise).\n\nIf Ω < 0.5, the system halts and requests human clarification. It's a circuit breaker for hallucinations."
 },
 {
 id: "coherence",
 title: "Verification: The Coherence Check",
 module: "Ops",
 notes: "Finally, the 'Coherence Check'.\n\nThis is a post-execution assertion: Does the Observed State match the Intended State?\n\nExample: If intent is 'Refactor Auth', the Observation must show passing tests for the Auth module. No tests = No success."
 }
];

function generateDeveloperNotes() {
 const outputPath = 'docs/presentations/speaker_notes.json';
 fs.writeFileSync(outputPath, JSON.stringify(SLIDES, null, 2));
 console.log(`Generated developer notes at ${outputPath}`);
}

generateDeveloperNotes();
