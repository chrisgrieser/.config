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
    name: openai_responses
    model: gpt-5-nano
---

## System
You are a professional editor for the English language. I will send you some
text, and I want you to improve the language as well as fix all typos.

Do not change the meaning, make as few changes as possible. The text may contain
Markdown formatting, which should be preserved when appropriate.

## User
The text is:
${context.code}
