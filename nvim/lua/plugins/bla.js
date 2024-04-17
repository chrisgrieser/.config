const sourceFolder = dv.current().file.frontmatter["source folder"];
const unfinishedPages = dv
	.pages(`"${sourceFolder}"`)
	.filter((p) => {
		const unread = !p.file.frontmatter.read;
		const outlinks = p.file.outlinks.filter((l) => !l.toString().match(/[![]]+[/#]/));
		return unread && outlinks.length > 0;
	})
	.map((p) => [p.file.link, p.file.outlinks]);
dv.table(["File", "Outgoing Links"], unfinishedPages);
