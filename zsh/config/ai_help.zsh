#!/usr/bin/env zsh
# SOURCE based on https://github.com/day50-dev/Zummoner/blob/main/zummoner.zsh
#───────────────────────────────────────────────────────────────────────────────

ai() {
	# CONFIG
	local model='gpt-5-mini'

	# https://platform.openai.com/api-keys
	private_dots="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles"
	OPENAI_API_KEY="$(cat "$private_dots/openai-api-key.txt")"

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
	#────────────────────────────────────────────────────────────────────────────

	local task="$*"
	print "\e[1;34mAsking AI…\e[0m "

	# OpenAI request
	local response
	response=$(jq -n \
		--arg model "$model" --arg system_prompt "$system_prompt" --arg task "$task" \
		'{
			model: $model,
			messages: [
				{ role: "system", content: $system_prompt },
				{ role: "user", content: $task }
			]
		}' |
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
	local cmd
	cmd="$(echo "$response" | jq -r '.choices[0].message.content')"
	echo -n "$cmd" | pbcopy
	echo "$cmd" | bat --language=sh --wrap=character
	print "\e[1;35m(Copied)\e[0m"
}
