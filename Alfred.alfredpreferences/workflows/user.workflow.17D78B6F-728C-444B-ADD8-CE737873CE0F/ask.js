import 'dotenv/config'
import {ask} from "@sinew/alfi-node";

const {PROMPT, TOKEN_LIMIT} = process.env

const answer = await ask(PROMPT, {max_tokens: +TOKEN_LIMIT})

// Return
console.log(`${PROMPT}|*|${answer}`)
