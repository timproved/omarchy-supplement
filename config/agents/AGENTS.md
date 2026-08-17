I'm Tim. You are my agent.

I love to build well-structured systems. I focus on making complex things as simple as possible and finding ways to reduce complexity when solving problems.

I wanted to share some of my preferences here so we can be more aligned as we work together.

# Coding preferences - general

- Keep things simple. Apply YAGNI unless told otherwise.
- Design cohesive modules, classes, and functions around one responsibility or reason to change. Do not split code mechanically when doing so makes the system harder to understand.
- Use SOLID principles where they reduce coupling or clarify ownership; do not introduce abstractions speculatively.
- Preserve domain invariants in types where practical, especially in TypeScript and Python codebases. Validate untrusted data at system boundaries. Do not use `any`, unsafe casts, ignores, or unchecked dictionaries merely to silence the type checker.
- Propose materially better alternatives when you see them, but distinguish recommendations from the requested work and ask before expanding scope.
- Be careful with destructive actions when not explicitly requested by the user.
- Test observable behavior affected by the change. Derive expectations from requirements, documented behavior, or demonstrated defects. Prefer the narrowest test that provides meaningful confidence, and avoid redundant smoke tests or tests that preserve deleted implementation details.
- Comments should explain intent, invariants, constraints, or non-obvious tradeoffs, not restate the code. Public API documentation should explain usage where the type signature is insufficient. Avoid AI-slop language in comments.
- Keep comments and documentation accurate when behavior changes.

## Preserve Codebase Coherence

- Before implementing something, inspect how the codebase solves similar problems, including its existing abstractions, module boundaries, naming, types, error handling, and tests.
- Prefer extending or reusing an established approach over introducing a competing pattern or parallel implementation.
- Do not follow an existing pattern blindly. If it is unsuitable or materially flawed, explain why and propose a coherent alternative before expanding the scope.
- Keep each domain rule or responsibility owned in one clear place rather than duplicating it across the codebase.

## Questions are read-only

- A question is a request for an answer, not for changes. If the message opens with "how hard would it be", "what would be the impact of", "what are your thoughts on", "should we", "can X do Y", "isn't this better than that", or otherwise asks rather than instructs: answer it and do not edit files.
- If the answer is obvious and the change is trivial, still answer first and offer the change. Ask before making it!

## Match ceremony to the task

- Use subagents only when work is broad, naturally parallel, or benefits from independent review. Do not delegate ordinary work that a single agent can finish in one pass.
- Assign non-overlapping file ownership before parallel edits so agents do not collide.

## Blast Radius

- Never touch production, live databases, or daily-driver build/preview channels unless explicitly told to. When a task is adjacent to any of them, name what you are about to touch before touching it.

## Git and Pull Requests

- Only create commits when explicitly requested. Follow the repository's commit conventions; where it uses conventional commits, use a concise message such as `fix(ai): harden structured output calls for code snippets`.
- Each commit should contain one focused batch of work that solves one issue.
- Do not add AI attribution, agent names, generated-by notices, or agent co-authors to commits or pull requests.
- Keep pull requests lean. Functionality that does not belong in a pull request should go into a separate pull request.
- Make pull-request titles simple, easy to understand, and consistent with repository conventions, such as `fix(web): prevent new threads from spiking CPU` in projects that use conventional commits.
- Keep pull-request descriptions simple. Open with a clear description of the problem, followed by how it was solved.
- Before opening a pull request, update the branch from the repository's default branch. Rebase private branches; ask before rewriting a shared branch or force-pushing.
