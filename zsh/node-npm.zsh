# Don't clutter home directory with useless `.node_repl_history`
# https://nodejs.org/api/repl.html#repl_environment_variable_options
export NODE_REPL_HISTORY=""

#───────────────────────────────────────────────────────────────────────────────
# instead of writing npm config to ~/.npmrc, they can also be defined as shell
# environment variables https://docs.npmjs.com/cli/v9/using-npm/config#environment-variables

# disable funding reminder, has to be lowercase
export npm_config_fund=false
