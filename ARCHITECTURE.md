# Project Retrofit — Architecture

## 1. Overview

Project Retrofit is an autonomous multi-agent legacy modernization system. It converts legacy COBOL business logic into modern Python while preserving observable behavior through automated regression verification.

The core loop is:

```text
Analyze → Plan → Generate → Test → Execute
                              ↑         |
                              |         ↓
                              └─ Repair ← Reflect
```

## 2. Agent State Design

LangGraph maintains shared state:

```python
class RetrofitState(TypedDict):
    legacy_code: str
    analysis: dict
    migration_plan: dict
    generated_code: str
    generated_tests: str
    execution_result: dict
    reflection: str
    iteration: int
    status: str
    trace: list
```

`legacy_code` contains the uploaded source. `analysis` contains extracted business rules. `migration_plan` contains the target design. `generated_code` and `generated_tests` contain the current artifacts. `execution_result` contains pytest output and status. `reflection` stores root-cause analysis. `iteration` prevents infinite repair loops. `trace` provides the live agent execution history.

## 3. Agent Design

### Analyzer Agent

Extracts program structure, variables, data types, calculations, conditions, inputs, outputs, business rules and migration risks.

The prompt requires structured JSON and explicitly instructs the model not to invent business rules.

### Migration Planner

Converts analysis into a target Python architecture. It defines Pydantic schemas, validation, Decimal precision, testing strategy and migration steps.

### Code Generator

Translates COBOL into executable Python. Prompt constraints require preservation of IF/ELSE and EVALUATE behavior, Pydantic schemas, Decimal financial calculations and original business rules.

### Test Agent

Creates deterministic pytest regression tests for normal paths, boundaries, branches, rates/tax tiers and net calculations. For the standardized payroll benchmark, the regression suite is deterministic so judges receive reproducible results.

### Sandbox Executor

Writes generated source and tests to a temporary directory and runs:

```bash
python -m pytest -q
```

The process has an execution timeout and captures stdout, stderr and return code.

### Reflection Agent

Receives the failed test output and determines which business behavior was violated, what the COBOL requires, and what repair is needed.

### Self-Correction Agent

Applies a targeted behavioral repair and sends the implementation back through the test and execution stages.

## 4. Prompt Engineering

The system uses specialized prompts rather than one general-purpose prompt.

Key principles:

1. **Extraction before generation** — the analyzer produces an explicit intermediate representation.
2. **No invented rules** — prompts require the model to stay grounded in the uploaded source.
3. **Precision constraints** — financial calculations must use `Decimal`.
4. **Test independence** — tests verify legacy behavior rather than merely validating generated code assumptions.
5. **Failure-driven repair** — reflection receives actual pytest evidence before proposing a correction.
6. **Bounded iteration** — the graph tracks repair iterations to prevent infinite loops.

## 5. Sandbox Security

The prototype uses a local subprocess because the challenge permits local subprocess execution.

Current controls:

- temporary workspace
- generated source isolated from the main application
- pytest executed as a separate process
- execution timeout
- captured output
- uploaded COBOL is never directly executed

Production hardening should use Docker or another isolated runtime with:

- non-root user
- disabled network
- CPU and memory quotas
- process limits
- read-only filesystem
- restricted system calls
- timeout enforcement
- ephemeral storage
- automatic cleanup

## 6. Failure Mitigation

The system treats generated code as untrusted until verification succeeds.

```text
Generate
   ↓
Regression Test
   ↓
FAIL
   ↓
Reflection
   ↓
Root Cause
   ↓
Self-Correction
   ↓
Re-test
   ↓
PASS
```

The router sends successful executions to completion. Failed executions go to reflection and repair while the iteration counter remains bounded.

The standardized payroll demonstration intentionally exposes a first-pass defect so the judges can see the autonomous recovery loop.

## 7. Behavioral Equivalence

The prototype does not claim formal mathematical equivalence for every possible program. It establishes behavioral equivalence over the regression suite.

The payroll benchmark verifies:

- fewer than 40 hours
- exactly 40 hours
- overtime above 40 hours
- tax tiers 1, 2 and 3
- other tax tier
- zero hours
- gross pay
- tax deduction
- net pay

The migrated implementation uses `Decimal` to avoid binary floating-point errors in monetary calculations.

A production system should additionally run legacy and migrated implementations against identical generated input vectors and compare normalized outputs.

## 8. Why LangGraph

The workflow is conditional rather than purely linear:

```text
Executor
 ├── PASS → END
 └── FAIL → Reflection → Repair → Test → Executor
```

LangGraph provides explicit state, conditional routing and repeatable agent orchestration.

## 9. Production Roadmap

Future improvements:

- Docker sandbox
- FastAPI REST service
- persistent artifact storage
- COBOL AST parser
- differential testing against a COBOL runtime
- Git versioning and rollback
- human-in-the-loop approval
- security scanning
- token/cost telemetry
- broader legacy language support

## 10. Design Principle

The central principle is:

> **AI-generated migration code is not trusted until it passes behavioral verification.**

Project Retrofit therefore follows:

**Generate → Test → Observe → Reflect → Repair → Verify**
