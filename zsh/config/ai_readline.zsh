#!/usr/bin/env zsh

# SOURCE based on https://github.com/day50-dev/Zummoner/blob/main/zummoner.zsh

zummoner() {
	# CONFIG
	local model='gpt-4.1-mini'

	local system_prompt="
		You are an experienced software engineer with expertise in all UNIX 
		command line tools.

		Given a task, generate a single command or a pipeline of commands that
		accomplish the task efficiently. For complex tasks or those requiring
		multiple steps, provide a pipeline of commands. 

		This command is to be executed in zsh. The system is macOS. If a command
		is not compatible with the system or shell, provide a suitable alternative.

		Output only the command as a single line of plain text, with no quotes,
		formatting, or additional commentary. 

		Create a command to accomplish the following task:
	"
	#────────────────────────────────────────────────────────────────────────────

	local question="$BUFFER"
	BUFFER="(🤖 Asking AI…)"

	local response
	response=$(jq -n \
		--arg model "$model" --arg system_prompt "$system_prompt" --arg question "$question" \
		'{ model: $model, messages: [
				{role: "system", content: $system_prompt},
				{role: "user", content: $question}
		] }' |
		curl --silent --max-time 15 "https://api.openai.com/v1/chat/completions" \
			-H "Content-Type: application/json" \
			-H "Authorization: Bearer $OPENAI_API_KEY" \
			-d @-)

	# GUARD
	if [[ -z "$response" ]]; then
		print "\e[1;33mNo response from the AI provider.\e[0m"
		return 1
	fi
	if echo "$response" | jq -e '.error' > /dev/null; then
		local error_msg
		error_msg=$(echo "$response" | jq -r '.error.message')
		echo "❌ error: $error_msg" >&2
		return 1
	fi

	# set zsh buffer
	BUFFER="$(echo "$response" | jq -r '.choices[0].message.content')"
	# zle reset-prompt
	# shellcheck disable=2034
	CURSOR=${#BUFFER}
}

zle -N zummoner
bindkey '^G' zummoner # [G]enerate ai command
