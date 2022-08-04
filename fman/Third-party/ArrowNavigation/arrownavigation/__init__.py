from fman import DirectoryPaneCommand, load_json
from fman.fs import is_dir
from fman.url import splitscheme

class OpenIfDirectory(DirectoryPaneCommand):
	def __call__(self):
		file_under_cursor = self.pane.get_file_under_cursor()
		if file_under_cursor:
			try:
				f_is_dir = is_dir(file_under_cursor)
			except OSError as e:
				show_alert(
					'Could not read from %s (%s)' %
					(as_human_readable(file_under_cursor), e)
				)
				return
			if f_is_dir:
				self.pane.set_path(file_under_cursor)
			else:
				# Archive handling:
				scheme, path = splitscheme(file_under_cursor)
				if scheme == 'file://':
					new_scheme = self._get_handler_for_archive(path)
					if new_scheme:
						new_url = new_scheme + path
						self.pane.run_command(
							'open_directory', {'url': new_url}
						)
	def _get_handler_for_archive(self, file_path):
		settings = load_json('Core Settings.json', default={})
		archive_types = sorted(
			settings.get('archive_handlers', {}).items(),
			key=lambda tpl: -len(tpl[0])
		)
		for suffix, scheme in archive_types:
			if file_path.lower().endswith(suffix):
				return scheme
	def is_visible(self):
		return False