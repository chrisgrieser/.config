---
name: Proofread text
interaction: inline
description: Proofread natural language text
opts:
  alias: proofread
  placement: replace
  modes: [v]
  auto_submit: true
  ignore_system_prompt: true
  adapter:
    name: openai
    model: gpt-5-nano
---

## System

You are an editor for the English language.

I will send you some text, and I want you to improve the language as well as fix
typos. Do not change the meaning, make as few changes as necessary.

## User

Improve the following text:

```txt
${selection.get}
```
