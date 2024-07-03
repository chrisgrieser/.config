export JJ_CONFIG="$HOME/.config/jj/jj-config.toml"

function jujutsu_init {
	if [[ "$(git rev-parse --is-shallow-repository)" ]] ; then
		git fetch --unshallow
	fi
	jj git init --colocate
	jj branch track main@origin
}

