-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- 起動時に chromium / ghostty を起動 (既に起動していればスキップ)
o.exec_on_start("pgrep -x chromium >/dev/null || chromium")
o.exec_on_start("pgrep -x ghostty >/dev/null || ghostty")
