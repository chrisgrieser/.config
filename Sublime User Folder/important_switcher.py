import re
import sublime_plugin


class ImportantSwitcher(sublime_plugin.TextCommand):  # pylint: disable=too-few-public-methods
	def run(self, edit):
		for region in self.view.sel():  # for every selection (region = range in Sublime)
			line = self.view.line(region)  # extend to beginning/end of line
			line_content = self.view.substr(line)

			# remove !importants
			if "!important" in line_content:
				line_content = re.sub(r"\s?!important", "", line_content, 0)

			# add importants to blocks or to single-line declarations
			# https://regex101.com/r/BIB6cU/1
			else:
				line_content = re.sub(r"(;|(?!^) ?})$", " !important\\1", line_content, 0, re.MULTILINE)

			self.view.replace(edit, line, line_content)
