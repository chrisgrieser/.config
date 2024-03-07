
 local bla = { "williamboman/mason.nvim",
  _ = {
    cache = {
      keys_list = { <2>{ "<leader>pm", <function 1>,
          desc = " Mason",
          mode = "n"
        } },
      opts = {
        registries = <3>{ "file:/Users/chrisgrieser/.config/nvim/personal-mason-registry", "github:mason-org/mason-registry" },
        ui = <4>{
          border = "single",
          height = 0.85,
          icons = {
            package_installed = "✓",
            package_pending = "󰔟",
            package_uninstalled = "✗"
          },
          keymaps = {
            toggle_help = "?",
            toggle_package_expand = "<Tab>",
            uninstall_package = "x"
          },
          width = 0.8
        }
      }
    },
    dep = false,
    fid = 74,
    fpid = 73,
    handlers = {
      keys = {
        [",pm"] = {
          desc = " Mason",
          id = ",pm",
          lhs = "<leader>pm",
          mode = "n",
          rhs = <function 1>
        }
      }
    },
    installed = true,
    loaded = {
      plugin = "mason-tool-installer.nvim",
      time = 5532592
    },
    module = "plugins.mason",
    super = <5>{ "williamboman/mason.nvim",
      _ = {
        dep = false,
        fid = 72,
        module = "plugins.mason"
      },
      dir = "/Users/chrisgrieser/.local/share/nvim/lazy/mason.nvim",
      external_dependencies = { "node", "python3.12" },
      keys = { <table 2> },
      name = "mason.nvim",
      opts = {
        registries = <table 3>,
        ui = <table 4>
      },
      url = "https://github.com/williamboman/mason.nvim.git"
    },
    tasks = { {
        _ended = 52095336822699,
        _opts = { "git.log",
          check = true
        },
        _running = { <function 2> },
        _started = 52094972777800,
        _task = <function 3>,
        name = "log",
        output = "",
        plugin = <table 1>,
        status = "",
        <metatable> = {
          __index = {
            _check = <function 4>,
            all_done = <function 5>,
            has_started = <function 6>,
            is_done = <function 7>,
            is_running = <function 8>,
            new = <function 9>,
            schedule = <function 10>,
            spawn = <function 11>,
            start = <function 12>,
            time = <function 13>,
            wait = <function 14>
          }
        }
      } },
    working = false
  },
  dir = "/Users/chrisgrieser/.local/share/nvim/lazy/mason.nvim",
  lazy = true,
  name = "mason.nvim",
  url = "https://github.com/williamboman/mason.nvim.git",
  <metatable> = {
    __index = <table 5>
  }
}
