//──────────────────────────────────────────────────────────────────────────────
/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
    // DOCS https://www.mankier.com/api
    const baseUrl = "https://www.mankier.com/1/";
    const apiUrl = "https://www.mankier.com/api/v2/mans/?q=";

    // process Alfred args
    const query = argv[0] || "";
    const command = query.split(" ")[0];
    const options = argv[0] ? query.split(" ").slice(1).join(" ") : "";

    const installedBinaries = app
        .doShellScript(
            "echo $PATH | tr ':' '\n' | xargs -I {} find {} -mindepth 1 -maxdepth 1 -type f -or -type l -perm '++x' | xargs basename"
        )
        .split("\r");

    /** @type{AlfredItem[]} */
    const manPages = JSON.parse(httpRequest(apiUrl + command))
        .results.map((result) => {
            const cmd = result.name;
            let url = baseUrl + cmd;
            if (options) url += "#" + options;
            const icon = installedBinaries.includes(cmd) ? " ✅" : "";

            return {
                title: cmd + icon,
                subtitle: result.section + ": " + result.description,
                match: cmd.replace(/[-_]/, " ") + " " + cmd,
                arg: url,
                mods: {
                    cmd: {
                        arg: "man " + argv[0],
                        subtitle: "⌘: Open in Terminal >> man " + argv[0],
                    },
                },
                uid: cmd,
            };
        });

    return JSON.stringify({ items: manPages });
}

