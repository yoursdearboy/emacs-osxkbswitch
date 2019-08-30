# osxkbswitch module for Emacs

Emacs module which provides `(keyboard-layout)` and `(set-keyboard-layout layout-name)` functions to get and set keyboard layout on Mac OS.

Example usage (with evil-mode) to switch keyboard to Latin after exiting insert state:

```
(module-load "/path/to/osxkbswitch.so")
(add-hook 'evil-insert-state-exit-hook (lambda () (set-keyboard-layout "com.apple.keylayout.ABC")))
```

Take .so file from the repo. Or build with `make`. Test with `make test`.
