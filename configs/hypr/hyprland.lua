-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- miryam の会話・ニュース窓を中央フロート表示 (マスコット本体は layer-shell で対象外)
o.window("^dev\\.youknow\\.miryam$", { float = true, center = true })

-- 仕事用 (workspace 2) / 趣味用 (workspace 3) の自動配置
o.window("^(cursor|Cursor)$", { workspace = "2" })
o.window("^(antigravity|Antigravity)$", { workspace = "3" })

-- 透過
o.window(".*", { opacity = "0.80 0.80" })

-- special はもうちょい透過して背景が見えるようにする
o.window({ workspace = "^special:scratchpad$" }, { opacity = "0.40 override 0.40 override" })

-- window-switcher をフロート表示
o.window({ title = "^window-switcher$" }, { float = true, size = "600 400", center = true })

-- 緊急日本語入力 をフロート表示
o.window({ title = "^Emergency JP Input$" }, { float = true, size = "600 400", center = true })

-- nvim-cheats をフロート表示
o.window({ title = "^nvim-cheats$" }, { float = true, size = "900 500", center = true })

-- fcitx5 向け GTK_IM_MODULE (GTK/XWayland アプリの日本語入力)
hl.env("GTK_IM_MODULE", "fcitx")

-- GPU: EGL/GLX ベンダを mesa に固定する
-- このマシンは AMD 780M のみ (NVIDIA GPU 無し) だが nvidia-utils が
-- /usr/share/glvnd/egl_vendor.d/10_nvidia.json を置くため、libglvnd が
-- libEGL_nvidia + libnvidia-egl-wayland2 を読み込む。chromium の GPU プロセスが
-- そこで SEGV し、GPU 無効化 (--use-gl=disabled) にフォールバックして
-- WebGL が全滅する (Figma が "WebGL isn't supported" になる)。
-- NVIDIA GPU を積む構成に変えたときはこの 2 行を削除すること。
hl.env("__EGL_VENDOR_LIBRARY_FILENAMES", "/usr/share/glvnd/egl_vendor.d/50_mesa.json")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "mesa")
