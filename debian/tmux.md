# Cheat Sheet: tmux

### 🏆 **Basic Commands:**

```bash
tmux new -s abc             # Create a new session named "abc"
tmux ls                     # List all sessions
tmux attach -t abc          # Attach to a session
tmux detach                 # Detach (Ctrl + B, then D also works)
tmux switch-client -t abc   # switch to the other session without nesting
tmux kill-session -t abc    # Kill a session
tmux kill-server            # Kill all sessions
```

---

### ⚙️ **Pane Management:**

| Action                              | Shortcut               |
| ----------------------------------- | ---------------------- |
| **Split vertically (left/right)**   | `Ctrl + B` → `%`       |
| **Split horizontally (top/bottom)** | `Ctrl + B` → `"`       |
| **Switch panes**                    | `Ctrl + B` → Arrow key |
| **Close current pane**              | `Ctrl + D`             |
| **Resize pane**                     | `Ctrl + B` → `:` then: |
| Shrink down                         | `resize-pane -D 5`     |
| Shrink up                           | `resize-pane -U 5`     |
| Shrink left                         | `resize-pane -L 5`     |
| Shrink right                        | `resize-pane -R 5`     |

---

### 🌐 **Window (Tab) Management:**

| Action               | Shortcut         |
| -------------------- | ---------------- |
| **List windows**     | `Ctrl + B` → `W` |
| **Rename window**    | `Ctrl + B` → `,` |
| **New window (tab)** | `Ctrl + B` → `C` |
| **Next window**      | `Ctrl + B` → `N` |
| **Previous window**  | `Ctrl + B` → `P` |
| **Close window**     | `Ctrl + B` → `&` |

---

### 📌 **Session Management:**

| Action                  | Shortcut                              |
| ----------------------- | ------------------------------------- |
| **Detach from session** | `Ctrl + B` → `D`                      |
| **Switch sessions**     | `Ctrl + B` → `S`                      |
| **Rename session**      | `Ctrl + B` → `$`                      |
| **Kill session**        | `Ctrl + B` → `:` then: `kill-session` |
