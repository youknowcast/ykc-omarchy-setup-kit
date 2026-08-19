-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- 起動時に vivaldi / ghostty を起動 (既に起動していればスキップ)
o.exec_on_start("pgrep -x vivaldi-bin >/dev/null || vivaldi-stable")
o.exec_on_start("pgrep -x ghostty >/dev/null || ghostty")
