# https://docs.microsoft.com/en-us/windows/win32/menurc/wm-syscommand
# WM_SYSCOMMAND         0x0112

# SC_TASKLIST           0xF130
# SC_MONITORPOWER       0xF170
$type = Add-Type '[DllImport("user32.dll")]public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas

$type::SendMessage(-1, 0x0112, 0xF130, -1)
$type::SendMessage(-1, 0x0112, 0xF170, 2)