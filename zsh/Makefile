.PHONY: init run
#───────────────────────────────────────────────────────────────────────────────

run:
	source ./.venv/bin/activate && \
	python3 main.py

# set up venv & install deps
# INFO using homebrew python3.12 instead of macOS system python3.9 due to
# https://github.com/urllib3/urllib3/issues/3020
init:
	command
	[[ -d ./.venv ]] && rm -rf ./.venv ; \
	python3.12 -m venv ./.venv && \
	source ./.venv/bin/activate && \
	python3 -m pip install -r requirements.txt && \
	python3 -m pip install --upgrade pip
