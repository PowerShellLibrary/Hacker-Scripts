*WheelDown::
{
   if InsideLoop=1
    {
        ActionInvoked = 1
        Send {LWin down}{Ctrl down}{Right down}{LWin up}{Ctrl up}{Right up}
        return
    }
    send, {blind}{WheelDown}
    return
}

*WheelUp::
{
    if InsideLoop=1
    {
        ActionInvoked = 1
        Send {LWin down}{Ctrl down}{Left down}{LWin up}{Ctrl up}{Left up}
        return
    }
    send, {blind}{WheelUp}
    return
}

$RButton::
{
    ActionInvoked = 0
    InsideLoop =
    While GetKeyState("RButton", "p")
    {
        InsideLoop = 1
    }
    InsideLoop =
    if ActionInvoked = 0
        send, {blind}{RButton}
}