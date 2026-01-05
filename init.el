(use-package haskell-mode
  :ensure t)

(use-package lsp-mode
  :ensure t
  :hook (haskell-mode . lsp)
  :commands lsp)

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

(use-package ormolu
  :ensure t
  :hook (haskell-mode . ormolu-format-on-save-mode))
