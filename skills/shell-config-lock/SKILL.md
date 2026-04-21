---
name: shell-config-lock
description: Lock and unlock shell configuration files to prevent unwanted modifications. Use when user wants to protect bash/zsh configs from scripts writing to them, or unlock them for editing.
---

# Shell Config Lock/Unlock

## Lock (prevent modifications)
```bash
chflags uchg ~/.bashrc ~/.bash_profile ~/.zshrc ~/.zprofile 2>/dev/null
```

## Unlock (allow editing)
```bash
chflags nouchg ~/.bashrc ~/.bash_profile ~/.zshrc ~/.zprofile 2>/dev/null
```

## Check status
```bash
ls -lO ~/.bashrc ~/.bash_profile ~/.zshrc ~/.zprofile 2>/dev/null | grep -E "(uchg|^)"
```

Files with `uchg` flag are locked.
