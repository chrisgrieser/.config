---
name: Proofread text
interaction: inline
description: Proofread natural language text
opts:
  alias: proofread
  placement: replace
  modes: [v]
  auto_submit: true
  stop_context_insertion: false
  user_prompt: false
---

## system

You are an editor for the English language.

I will send you some text, and I want you to improve the language as well as fix
typos. Do not change the meaning, make as few changes as necessary.

## user

Improve the following text:

```txt
${utils.selection}
```
