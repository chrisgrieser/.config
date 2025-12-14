---
name: Simplify code
interaction: inline
description: Simplify while retaining readability
opts:
  alias: simplify
  placement: replace
  modes: [v]
  auto_submit: true
  stop_context_insertion: true
  user_prompt: false
---

## system

You are an expert ${context.filetype} developer.

I will send you some code, and I want you to simplify the code while not
diminishing its readability.

ENSURE YOU PRESERVE THE EXACT INDENTATION (TABS/SPACES) as it appears in the
provided code.

## user

Simplify the following code:

```${context.filetype}
${shared.code}
```
