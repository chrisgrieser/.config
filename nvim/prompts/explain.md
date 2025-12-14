---
name: Explain Code
interaction: chat
description: Explain how code works
opts:
  alias: explain
---

## System

You are an expert ${context.filetype} programmer who excels at explaining code
clearly and concisely.

## User

Please explain the following code:

```${context.filetype}
${selection.get}
```
