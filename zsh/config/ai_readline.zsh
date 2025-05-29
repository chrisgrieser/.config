#!/usr/bin/env zsh

# SOURCE based on https://github.com/day50-dev/Zummoner/blob/main/zummoner.zsh

zummoner() {
	local model='gpt-4.1-mini' # CONFIG

	local the_prompt="
		You are an experienced software engineer with expertise in all UNIX command 
		line commands.

		Given a task, generate a single command or a pipeline of commands that accomplish the task efficiently. For complex tasks or those requiring multiple steps, provide a pipeline of commands. If a command is not compatible with the system or shell, provide a suitable alternative.

		This command is to be executed in zsh. The system is macOS.

		Output only the command as a single line of plain text, with no quotes,
		formatting, or additional commentary. 

		Create a command to accomplish the following task:
	"

	#────────────────────────────────────────────────────────────────────────────

	local question="$BUFFER"
	BUFFER="(Asking AI…)" # temp display

	zle -R # reset the prompt
	local response
	response=$(curl --silent --max-time 15 "https://api.openai.com/v1/chat/completions" \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-d "{
			\"model\": \"$model\",
			\"messages\": [
				{\"role\": \"system\", \"content\": \"$the_prompt\"},
				{\"role\": \"user\", \"content\": \"$question\"}
			]
		}")
	if [[ -z "$response" ]]; then
		print "\e[1;33mNo response from the AI provider.\e[0m"
		return 1
	fi

	local cmd
	cmd=$(echo -n "$response" | sed 's/```//g' | tr -d '\n')
	BUFFER="$cmd"
	# shellcheck disable=2034
	CURSOR=${#BUFFER}
}

zle -N zummoner
bindkey '^G' zummoner # [G]enerate ai command
