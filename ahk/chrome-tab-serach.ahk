; Reconfiguring Chrome keyboard shortcut
; Chrome's tab search Ctrl+Shift+A (Windows/Linux) -> Ctrl+P
#HotIf WinActive("ahk_exe chrome.exe")
^p::^+a
#HotIf