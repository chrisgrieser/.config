# Alfred Client for the [Pass-CLI](https://www.passwordstore.org/)

## Requirements
- `pass`
- `pinentry-mac`
- Alfred 5 with Powerpack

Install them via `brew install pass pinentry-mac`. 

1. Setup `pass` with an GPG key. See the [Pass-Website](https://www.passwordstore.org/) for information.
1. Setup `pinentry-mac` as your `pinentry-program`:

`[[ -d "$HOME/.gnupg" ]] || mkdir ~/.gnupg`
`echo "pinentry-program /opt/homebrew/bin/pinentry-mac" > ~/.gnupg/gpg-agent.conf`
`gpgconf --kill gpg-agent`

## Configuration

This workflow is reads all your `PASSWORD_STORE_*` environment variables which have been added to your `~/.zshenv`. This means that most configuration is done by exporting respective variables in `~/.zshenv`; this workflow therefore has only few configuration options which concern Alfred in particular. Example: `export PASSWORD_STORE_GENERATED_LENGTH=32`. For information on the available environment variables, see the [pass man page](https://git.zx2c4.com/password-store/about/).

If you are using a custom password-store directory, you **must** export your `PASSWORD_STORE_DIR` in your `~/.zshenv` for this workflow to work.

## Credits

Created by [Chris Grieser](https://chris-grieser.de/).
