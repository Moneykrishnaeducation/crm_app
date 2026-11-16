
Multi-Agent Development Rules
Default workflow

For every medium or large development task, first inspect the repository and create a task plan. Delegate independent tasks to parallel asynchronous subagents whenever available.

Agent roles
Planner: Understand requirements, identify dependencies, and define task boundaries.
Frontend: Own UI, components, styling, and frontend tests.
Backend: Own APIs, business logic, and backend tests.
Database: Own schemas, migrations, and data access.
Reviewer: Independently inspect changes, regressions, and test results.

Assign only the roles needed for each task.

Parallel execution
Start independent tasks concurrently.
Do not start dependent tasks before their prerequisites are defined.
Give every worker a specific deliverable and file ownership boundary.
Use isolated Git worktrees for parallel code-writing tasks whenever supported.
Never allow concurrent workers to modify the same files without explicit coordination.
Integration
Wait for workers to report completion.
Review their changes before integration.
Run relevant tests, linting, and builds.
Resolve conflicts deliberately.
Report incomplete work and failed tests honestly.
Safety
Preserve existing user changes and uncommitted files.
Never perform destructive Git operations without explicit permission.
Never expose secrets or commit environment files containing credentials.
Ask before performing irreversible or production-impacting actions.
Communication

At the end of each task, report the workers used, their deliverables, files changed, validation results, and remaining issues.
