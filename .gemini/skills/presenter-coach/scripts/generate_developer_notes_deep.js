const fs = require('fs');

const SLIDES = [
 // --- SECTION 0: FUNDAMENTALS ---
 {
 id: "llm_101",
 title: "LLM 101: The Stochastic Engine",
 module: "Fundamentals",
 content_block: "An Large Language Model (LLM) functions as a **Probabilistic Engine**, not a deterministic database. It processes input tokens to predict the most likely subsequent token based on training weights.\n\n**Key Characteristics**:\n• **Stateless**: The model retains no memory of previous interactions outside the current context window.\n• **Non-Deterministic**: Identical inputs can yield different outputs ('Temperature').\n• **Instruction Following**: Capabilities depend on the quality of the prompt engineering.",
 code_block: "f(context, temperature) -> probabilities\n\nExample:\n>> 'The sky is'\n<< 'blue' (90%)\n<< 'gray' (5%)",
 notes: "Think of an LLM as a CPU that processes language, rather than a Hard Drive that stores facts. It requires explicit context to function correctly."
 },
 {
 id: "context_window",
 title: "The Context Window Constraints",
 module: "Fundamentals",
 content_block: "The **Context Window** represents the Agent's working memory (RAM). It is a finite, sliding window of tokens that captures the conversation history, system instructions, and retrieved documents.\n\n**Operational Risks**:\n1. **Attention Drift**: As the window fills, the model's ability to recall specific instructions degrades.\n2. **Cost**: Every new message re-processes the entire window history (Quadratic/Linear cost).\n3. **Truncation**: Exceeding the limit results in hard data loss.",
 code_block: "Context = [\n System_Prompt (Immutable),\n Conversation_History (FIFO),\n Retrieved_Knowledge (JIT),\n User_Query\n]",
 notes: "Managing this window is the primary responsibility of the Agent OS. We must rigorously prune irrelevant context."
 },
 {
 id: "mcp_primer",
 title: "Model Context Protocol (MCP)",
 module: "Fundamentals",
 content_block: "MCP is the open standard that enables AI models to interact with external systems. It decouples the **Model** (Client) from the **Tools** (Server).\n\n**Architecture**:\n• **MCP Client**: The Agent runtime (e.g., Claude Desktop, Vibe OS).\n• **MCP Server**: A lightweight service exposing capabilities (Filesystem, Git, API).\n• **Protocol**: JSON-RPC over Stdio or HTTP.",
 code_block: "// JSON-RPC Tool Call\n{\n \"method\": \"tools/call\",\n \"params\": {\n \"name\": \"git_commit\",\n \"args\": { \"msg\": \"feat: init architecture\" }\n }\n}",
 notes: "MCP gives the agent 'hands'. Without it, the model is an isolated brain in a jar. Vibe uses MCP for all filesystem actions."
 },
 {
 id: "agent_loop",
 title: "The ReAct Loop Architecture",
 module: "Fundamentals",
 content_block: "An 'Agent' is an LLM wrapper implementing a recursive **Reasoning and Action (ReAct)** loop.\n\n**The Cycle**:\n1. **Thought**: Analyze the current state and determine the next step.\n2. **Action**: Execute a tool call (via MCP) to change the state.\n3. **Observation**: Read the tool's output or error message.\n4. **Repeat**: Iterate until the success criteria are met or the retry limit is reached.",
 code_block: "while (status != DONE):\n trajectory = context.read()\n plan = model.reason(trajectory)\n result = tools.execute(plan)\n context.append(result)",
 notes: "This loop is powerful but prone to infinite divergence. We implement strict 'Stability Checks' to prevent runaway costs."
 },

 // --- SECTION 1: OVERVIEW ---
 {
 id: "intro",
 title: "Vibe Runtime v2.2",
 module: "System Overview",
 content_block: "**Vibe** is a portable, token-optimized operating system designed to govern AI agent behavior.\n\nUnlike passive documentation, Vibe is an **Execution Framework** that enforces strict context management. Its primary goal is to solve 'Context Rot'—the degradation of agent performance caused by irrelevant or unstructured information.",
 notes: "We define the system as a Runtime because it must be 'booted' by the agent. It actively manages the thought process."
 },
 {
 id: "vision_params",
 title: "Optimization Objectives",
 module: "System Overview",
 content_block: "The architecture is engineered to optimize four critical variables:\n\n1. **Portability**: The `.agents/` directory is self-contained. Drop it into any repo to inherit the stack.\n2. **Efficiency**: JIT Loading ensures we never waste tokens on irrelevant docs.\n3. **Intent Clarity**: We prioritize structured inputs (High Beta) over vague queries.\n4. **Verification**: Constraints are enforced via the 'Coherence Protocol'.",
 notes: "These objectives effectively lower the 'Epsilon' (Noise) in our Stability Equation."
 },
 {
 id: "anti_pattern",
 title: "The Pathology of Context Rot",
 module: "System Overview",
 content_block: "**Context Rot** occurs when low-signal files flood the context window, displacing critical instructions.\n\n**Typical Symptoms**:\n• **Hallucination**: Inventing libraries that don't exist.\n• **Regression**: Forgetting established patterns (e.g., using `var` instead of `const`).\n• **Drift**: Ignoring strict security constraints.\n\n**Root Cause**: Flat knowledge hierarchies where all docs have equal weight.",
 notes: "Context Rot is not a model failure; it is an architecture failure. We fix it by hierarchizing knowledge."
 },

 // --- SECTION 2: ARCHITECTURE ---
 {
 id: "tier_table",
 title: "The 4-Tier Knowledge Hierarchy",
 module: "Architecture",
 content_block: "To solve Context Rot, we organize knowledge into four logical tiers based on **Scope** and **Frequency**:\n\n• **Tier 1 (Constitution)**: Immutable identity & ethics. Loaded at Boot.\n• **Tier 1.5 (Governance)**: Security gates & policies. Loaded Just-In-Time (Trigger-based).\n• **Tier 2 (Reference)**: Technical diagrams & stack patterns. Loaded Just-In-Time (Task-based).\n• **Tier 3 (Context)**: Ephemeral task state. Dynamic.",
 notes: "This O(1) scaling strategy ensures that adding 1000 documentation files does not slow down the agent. It only loads what it needs."
 },
 {
 id: "tier1_deep",
 title: "Tier 1: The Constitution",
 module: "Architecture",
 content_block: "Tier 1 represents the **Immutable Kernel** of the agent's identity. These files are universally loaded and define the non-negotiable behaviors.\n\n**The Prime Directives**:\n1. **Intent > Syntax**: Understand the goal before coding.\n2. **Verify First**: No task is done without evidence.\n3. **Evidence-Based**: Use logs and tests to prove completion.\n\n**Constraint**: Must remain under 500 lines to preserve window space.",
 notes: "If the Constitution is ambiguous, the agent will drift. It must be short, punchy, and absolute."
 },
 {
 id: "tier15_gov",
 title: "Tier 1.5: JIT Governance",
 module: "Architecture",
 content_block: "Governance policies define high-risk constraints that are loaded **Just-In-Time**.\n\n**Triggers**:\n• **SEC-001**: Triggered by 'Auth', 'Key', or 'Token' keywords.\n• **HYG-001**: Triggered by 'Refactor' or 'Cleanup' tasks.\n\nThis keeps the kernel clean while enforcing strict security during sensitive operations.",
 code_block: "if (action.includes('API_KEY')) {\n context.load('SEC-001');\n print('Applying Security Protocols...');\n}",
 notes: "We don't need security rules when writing a CSS file. We load them only when touching Auth."
 },
 {
 id: "minification",
 title: "Dual-Format Documentation (Min/Raw)",
 module: "Architecture",
 content_block: "Agents process information differently than humans. We maintain two versions of truth:\n\n1. **.min.md (Dist)**: YAML-heavy, token-optimized logic for the machine. (60% smaller)\n2. **.md (Source)**: Prose-heavy explanations for deep reasoning and humans.\n\n**Workflow**: The agent loads `.min.md` by default. It only requests `.md` if it fails to understand.",
 code_block: "# 01_CORE.min.md\nmode: strict\nrules:\n - no_yolo_merges\n - verify_first\n - evidence_required",
 notes: "We treat documentation as software code. It has a build step (Minification) and a distribution artifact."
 },

 // --- SECTION 3: EXECUTION ---
 {
 id: "stability_math",
 title: "The Stability Equation (Ω)",
 module: "Execution",
 code_block: "Ω = f(β, S, τ, ε)\n\nβ (Beta) = Intent Clarity\nS (Sigma) = Structure Definition\nτ (Tau) = Context Strain\nε (Epsilon) = Instruction Noise\n\nThreshold: Ω > 0.8",
 content_block: "We do not code blindly. Before execution, the agent calculates **Ω (Feasibility)**.\n\n**Logic**:\nIf **Ω < 0.5**, the risk of hallucination is statistically significant. The system **HALTS** and demands user clarification (Bumping Beta).",
 notes: "We don't rely on the model 'figuring it out'. We rely on mathematical signal-to-noise ratios."
 },
 {
 id: "beta_factor",
 title: "Beta (β): Intent Specificity",
 module: "Execution",
 content_block: "Beta measures the specificity of the user's input.\n\n• **Low β**: \"Fix the bug please.\" (High ambiguity, high risk).\n• **High β**: \"Fix the NullPointer in `auth.ts` line 40 when user is null.\" (High specificity).\n\n**Rule**: The system rejects Low Beta tasks to prevent wasted compute.",
 notes: "Garbage In, Hallucination Out. We refuse to process Garbage."
 },
 {
 id: "tau_factor",
 title: "Tau (τ): Context Management",
 module: "Execution",
 content_block: "Tau measures the strain on the context window. As τ approaches 1.0 (Full Window), the model's 'IQ' drops linearly due to attention dilution.\n\n**The Strategy**: When τ > 0.5, we aggressively trigger **Context Pruning** (The Law of Discovery), unloading Tier 2 and Tier 3 files to free up working memory.",
 notes: "Information overload is a bug. We treat context management as memory management."
 },

 // --- SECTION 4: STANDARDS ---
 {
 id: "testing_pyramid",
 title: "The Testing Pyramid Contract",
 module: "Standards",
 content_block: "We adhere to a strict testing ratio to ensure stability:\n\n• **Unit Tests (70%)**: Fast, isolated logic checks. Mock everything.\n• **Integration Tests (25%)**: Wiring checks between components (e.g., API <-> DB).\n• **E2E Tests (5%)**: Happy path user flows only. Expensive.\n\n**The Rule**: No Pull Request is merged without green tests at the appropriate tier.",
 notes: "This pyramid is our contract. If you break the ratio, you break the build."
 },
 {
 id: "error_taxonomy",
 title: "Error Taxonomy & Recovery",
 module: "Standards",
 content_block: "We categorize errors to optimize recovery costs:\n\n1. **Syntax Error (Permanent)**: Logic flaws. **Strategy: Fail Fast**. Retrying burns tokens for zero gain.\n2. **Timeout / 500 (Transient)**: System blips. **Strategy: Retry** with Backoff.\n3. **Security (Critical)**: Leaks. **Strategy: Halt** immediately.\n\n**Why?** Retrying a Syntax Error is the definition of insanity (and waste).",
 code_block: "if (error.isSyntax) {\n return System.halt(); // Save tokens\n} else if (error.isNetwork) {\n return System.retry(backoff=2s);\n}",
 notes: "Smart error handling saves money. Understanding 'Permanent' vs 'Transient' is key to autonomous operation."
 },
 {
 id: "transient_recovery",
 title: "Transient Recovery Strategy",
 module: "Standards",
 content_block: "For Transient errors (e.g., API timeouts), we implement a robust recovery loop:\n\n• **Max Attempts**: 3\n• **Algorithm**: Jittered Exponential Backoff (1s, 2s, 4s).\n• **Circuit Breaker**: If >5 failures in 10s, open the circuit to protect the service.\n\nThis ensures resilience without causing cascading system failures.",
 notes: "Resilience is engineering, not luck. We explicitly code the retry logic."
 },

 // --- SECTION 5: VERIFICATION ---
 {
 id: "coherence_protocol",
 title: "The Coherence Protocol",
 module: "Verification",
 content_block: "We redefine 'Done' not as subjective completion, but as **Coherence**:\n\n**Definition**: The Intended State (User Request) matches the Observed State (Logs/Tests).\n\n**The Ban**: Subjective claims like \"I think it works\" or \"I updated the code\" are strictly **BANNED**. You must prove it with a trace.",
 notes: "Subjective completion is the root of all bugs. We demand objective proof."
 },
 {
 id: "vibe_check",
 title: "The Vibe Check Workflow",
 module: "Verification",
 content_block: "The practical application of Coherence:\n\n1. **Declare Intent**: \"I am changing the Auth Logic.\"\n2. **Act**: Apply the code changes.\n3. **Verify**: Run `pytest tests/auth`.\n4. **Assert**: If Red, Rollback or Fix. If Green, Commit.\n\n**Constraint**: Committing on Red is a violation of Tier 1 Protocols.",
 notes: "If it's not tested, it doesn't exist. The Vibe Check is our gatekeeper."
 },
 {
 id: "audit_artifacts",
 title: "Audit Artifacts & Resumability",
 module: "Verification",
 content_block: "Every session must result in a verifiable trail to enable **Resumability**:\n\n• **update_plan.md**: The strategic approach.\n• **walkthrough.md**: The proof of work (screenshots, logs).\n• **task.md**: The granular status checklist.\n\nThis ensures that any agent can resume the work of another without loss of context.",
 notes: "We build for the next agent, not just the current user. Resumability is continuity."
 },
 {
 id: "intro", // Re-use Intro visual for Outro
 title: "Conclusion: Trust, but Verify.",
 module: "Conclusion",
 content_block: "Vibe is not about trusting AI to be magic. It is about **Engineering Reliability** into the stochastic process.\n\n1. Scope the Intent (High Beta).\n2. Limit the Context (Low Tau).\n3. Verify the Outcome (Coherence).\n\n**Result**: Autonomous Agents that actually work in production.",
 notes: "The end goal is not 'smart' agents. It is 'reliable' agents. Reliability is an engineered feature."
 }
];

function generateVisualSpecNotes() {
 const outputPath = 'docs/presentations/speaker_notes_deep.json';
 fs.writeFileSync(outputPath, JSON.stringify(SLIDES, null, 2));
 console.log(`Generated Concise Visual Spec notes at ${outputPath}`);
}

generateVisualSpecNotes();
