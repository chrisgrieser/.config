#!/usr/bin/env python3

import argparse
import os
import subprocess


WORKFLOW_BUNDLE_ID = "net.cdoug.gmail-search-tools"


def parse_account(value: str) -> str:
    try:
        account = int(value)
    except ValueError as exc:
        raise argparse.ArgumentTypeError("userNumber must be an integer from 0 to 9") from exc

    if account < 0 or account > 9:
        raise argparse.ArgumentTypeError("userNumber must be between 0 and 9")

    return str(account)


def set_alfred_workflow_variable(variable_name: str, value: str, workflow_bundle_id: str) -> None:
    subprocess.run(
        [
            "/usr/bin/osascript",
            "-e",
            (
                'tell application id "com.runningwithcrayons.Alfred" '
                f'to set configuration "{variable_name}" to value "{value}" '
                f'in workflow "{workflow_bundle_id}"'
            ),
        ],
        check=True,
    )


def main() -> None:
    parser = argparse.ArgumentParser(description='Set environment variable "userNumber"')
    parser.add_argument("account", type=parse_account, help="Account number (0-9)")
    args = parser.parse_args()

    workflow_bundle_id = os.environ.get("alfred_workflow_bundleid", WORKFLOW_BUNDLE_ID)
    set_alfred_workflow_variable("userNumber", args.account, workflow_bundle_id)
    set_alfred_workflow_variable("gmail_account", args.account, workflow_bundle_id)

    os.environ["userNumber"] = args.account
    os.environ["gmail_account"] = args.account
    print(f'userNumber={args.account}')


if __name__ == "__main__":
    main()
