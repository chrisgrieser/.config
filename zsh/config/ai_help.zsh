#!/usr/bin/env zsh
# SOURCE based on https://github.com/day50-dev/Zummoner/blob/main/zummoner.zsh
#───────────────────────────────────────────────────────────────────────────────

ai() {
	# CONFIG
	local model='gpt-5-mini'
	local reasoning='low'

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

	local response cmd task

	task="$*"
	print "\e[1;34mAsking AI…\e[0m "

	# OpenAI request
	# DOCS https://platform.openai.com/docs/api-reference/responses/get
	response=$(jq -n \
		--arg model "$model" --arg system_prompt "$system_prompt" --arg task "$task" --arg reasoning "$reasoning" \
		'{
			model: $model,
			reasoning: { effort: $reasoning },
			input: [
				{ role: "developer", content: $system_prompt },
				{ role: "user", content: $task }
			]
		}' |
		curl --silent --max-time 15 "https://api.openai.com/v1/responses" \
			-H "Content-Type: application/json" \
			-H "Authorization: Bearer $OPENAI_API_KEY" \
			-d @-)

	# GUARD
	if [[ -z "$response" ]]; then
		print "\e[1;33mNo response from the AI provider.\e[0m"
		return 1
	fi
	cmd="$(echo "$response" | jq --raw-output '.output[1].content[0].text')"
	if [[ $? -ne 0 || -z "$cmd" || "$cmd" == "null" ]]; then
		echo "❌ error: $response" >&2
		return 1
	fi

	# output
	echo -n "$cmd" | pbcopy
	echo "$cmd" | bat --language=sh
	print "\e[1;35m(Copied)\e[0m"
}
