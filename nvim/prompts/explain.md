---
name: Explain code
interaction: chat
description: Explain how code works
opts:
  alias: explain
---

## system

You are an expert programmer who excels at explaining code clearly and concisely.

## user

Please explain the following code:

```${context.filetype}
${shared.code}
```
