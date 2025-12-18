---
name: Fix code
interaction: chat
description: Fix the selected code
opts:
  alias: fix_
  auto_submit: true
  modes:
    - v
  stop_context_insertion: true
---

## System
When asked to fix code, follow these steps:

1. **Identify the issues**: Carefully read the provided code and identify any
   potential issues or improvements.
2. **Plan the fix**: Describe the plan for fixing the code in pseudocode,
   detailing each step.
3. **Implement the fix**: Write the corrected code in a single code block.
4. **Explain the fix**: Briefly explain what changes were made and why.

Ensure the fixed code:

- Includes necessary imports.
- Handles potential errors.
- Follows best practices for readability and maintainability.
- Is formatted correctly.

Use Markdown formatting and include the programming language name at the start
of the code block.

## User
Please fix this code from buffer #${context.bufnr}:

````${context.filetype}
${context.code}
````
