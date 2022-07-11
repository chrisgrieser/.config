# by @UlraInstinct05 on Discord
import sublime
import sublime_plugin

# https://www.sublimetext.com/docs/api_reference.html#sublime_plugin.EventListener
class RemoveTabBarListener(sublime_plugin.EventListener):

	def on_load_async(self, view):
		self.close_tab_bar(view, len(view.window().views()))
	on_new_async = on_load_async

	def on_pre_close(self, view):
		self.close_tab_bar(view, len(view.window().views()) - 1)

	@staticmethod
	def close_tab_bar(view, num_views):
		if num_views < 2:
			view.window().set_tabs_visible(False)
		else:
			view.window().set_tabs_visible(True)

