# AI Usage Log | Team The GRID

This log records all AI tool interactions during the MoMo SMS Database
project, per the assignment's AI Usage Policy. AI was used **only** for
permitted purposes: grammar/syntax checking, code **syntax** verification,
and MySQL best-practice research (with citation). The ERD design, SQL
schema logic, entity relationships, and all written explanations and
reflections were produced by team members **without** AI.

---

## A. Code Syntax Verification (not logic)

### Entry 1

- **Team member:** Alicia Keza Rutayisire
- **Tool:** Claude Sonnet
- **Permitted category:** Code syntax verification
- **Prompt summary:** "Is the syntax of this `CREATE TABLE transactions`
  block valid MySQL? **pasted the table...**
- **AI response summary:** Flagged a missing comma after the `amount`
  column; confirmed the rest compiles.
- **How it was used:** Added the missing comma only. All columns, types,
  and the table design were decided by Alicia.

### Entry 2

- **Team member:** Alicia Keza Rutayisire
- **Tool:** Claude Sonnet
- **Permitted category:** Code syntax verification
- **Prompt summary:** "Is this `FOREIGN KEY (user_id) REFERENCES
  users(user_id)` clause written correctly?"
- **AI response summary:** Confirmed valid; suggested `ON DELETE` action
  is optional.
- **How it was used:** Kept our own referential rule; AI only confirmed
  the clause syntax. The relationship itself was designed from our ERD.

### Entry 3

- **Team member:** Wilson Nshizirungu
- **Tool:** Claude Opus
- **Permitted category:** Code syntax verification
- **Prompt summary:** "MySQL error 1064 near my `CHECK (amount > 0)` —
  what's the syntax problem?"
- **AI response summary:** Extra parenthesis; corrected the bracket
  placement.
- **How it was used:** Fixed the bracket. The business rule (amount must
  be positive) was our own decision.

### Entry 4

- **Team member:** Alicia Keza Rutayisire
- **Tool:** Claude Opus
- **Permitted category:** Code syntax verification
- **Prompt summary:** "Is `ENGINE=InnoDB DEFAULT CHARSET=utf8mb4` in the
  right position after the closing parenthesis?"
- **AI response summary:** Confirmed correct table-option placement.
- **How it was used:** Confirmation only; no logic involved.

### Entry 5

- **Team member:** Aline Teta
- **Tool:** ChatGPT-4o
- **Permitted category:** Code syntax verification
- **Prompt summary:** "Is the file `examples/json_schemas.json` valid JSON
  (brackets/commas)?"
- **AI response summary:** Pointed to a trailing comma on the last array
  element.
- **How it was used:** Removed the trailing comma. The JSON structure and
  field choices were modeled by the whole team from our schema.

### Entry 6

- **Team member:** Ines Karega Uwase
- **Tool:** ChatGPT-4o
- **Permitted category:** Code syntax verification
- **Prompt summary:** "Does this `INSERT INTO users (...) VALUES (...)`
  row's value count match the column list?"
- **AI response summary:** Identified one row with 4 values vs 3 columns.
- **How it was used:** Corrected the sample row. Sample data values were
  create by Ines.

### Entry 7

- **Team member:** Gania Isaro Kayumba
- **Tool:** Claude Sonnet
- **Permitted category:** Code syntax verification
- **Prompt summary:** "Correct the syntax of this composite
  `CREATE INDEX idx_txn_user_date ON transactions(user_id, created_at)`."
- **AI response summary:** Syntax already valid; no change needed.
- **How it was used:** No change. Which columns to index was decided by
  the whole team from our query patterns.

---

## B. MySQL Best-Practice Research (with citation)

### Entry 8

- **Team member:** The Whole Team
- **Tool:** Claude Sonnet
- **Permitted category:** MySQL best-practice research
- **Prompt summary:** "For money values in MySQL, is `DECIMAL` preferred
  over `FLOAT`?"
- **AI response summary:** `DECIMAL` recommended for exact monetary values.
- **How it was used:** Confirmed our choice of `DECIMAL(12,2)` for amounts;
  decision and precision chosen by the team.
  https://dev.mysql.com/doc/refman/8.0/en/fixed-point-types.html

### Entry 9

- **Team member:** The Whole Team
- **Tool:** Claude
- **Permitted category:** MySQL best-practice research
- **Prompt summary:** "When to use `TIMESTAMP` vs `DATETIME` in MySQL 8.0?"
- **AI response summary:** `TIMESTAMP` is UTC/range-limited;
  `DATETIME` for wider range without timezone conversion.
- **How it was used:** Informed our choice of `TIMESTAMP` for `created_at`;
  final decision by the team.
  and TIMESTAMP Types" — https://dev.mysql.com/doc/refman/8.0/en/datetime.html

### Entry 10

- **Team member:** Gania Isaro Kayumba
- **Tool:** ChatGPT-4o
- **Permitted category:** MySQL best-practice research
- **Prompt summary:** "General indexing best practices for foreign-key
  columns?"
- **AI response summary:** Index FK columns used in JOIN/WHERE; avoid
  over-indexing write-heavy tables.
- **How it was used:** Background reading; actual indexes were chosen by
  the team from our real queries in `queries.sql`.
  Indexes" https://dev.mysql.com/doc/refman/8.0/en/optimization-indexes.html

---

## C. Grammar / Syntax Checking in Documentation

### Entry 11

- **Team member:** Aline Teta
- **Tool:** Claude
- **Permitted category:** Grammar/clarity proofread (content authored by human)
- **Prompt summary:** "Proofread the database section of our README for
  typos, don't change the meaning."
- **AI response summary:** Minor typo and punctuation fixes only.
- **How it was used:** Accepted typo fixes; the explanation itself was
  written by the team.

---

## D. Neutral Workflow / Tooling Help (not prohibited, no logic generated)

### Entry 12

- **Team member:** Wilson Nshizirungu
- **Tool:** Claude (Claude Code)
- **Permitted category:** Git workflow / collaboration assistance
- **Prompt summary:** "How do we merge 5 feature branches into a protected
  `main` when two members created the same new SQL file?"
- **AI response summary:** Explained a PR-based merge train, add/add
  conflict resolution on the feature branch, and merge-commit strategy to
  keep every member's commits visible.
- **How it was used:** Followed the git process only. No ERD, schema,
  query logic, JSON model, or written explanation was generated by AI.
