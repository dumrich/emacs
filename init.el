;; Chabi's Emacs config
(setq inhibit-startup-message t)

(load-theme 'doom-gruvbox t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)

(menu-bar-mode -1)
;;; Visible bell set
(setq visible-bell t)

;;; Tabs
(setq x-select-enable-clipboard t) (setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq indent-line-function 'insert-tab)
(setq-default c-basic-offset 4)
(global-visual-line-mode t)

(set-face-attribute 'default nil :font "Fira Code Nerd Font" :height 125)

(when (eq window-system nil)
    (xterm-mouse-mode t))

(add-to-list 'load-path (concat user-emacs-directory "lisp/" ))

;; (load "gas-mode")
;;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(column-number-mode)
(global-display-line-numbers-mode t)
(dolist (mode '(org-mode-hook
		term-mode-hook
		shell-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package no-littering
  :config
(setq auto-save-file-name-transforms
	`((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

(use-package all-the-icons
  :if (display-graphic-p))

(use-package avy)

;;; Streamlined completions
(use-package vertico
  :ensure t
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)
              ("<escape>" . vertico-exit))
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode))

(use-package savehist
  :init
  (savehist-mode))

(use-package marginalia
  :after vertico
  :ensure t
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))

(use-package consult
  :bind (
         ("C-s" . consult-line)
         ("C-M-j" . consult-buffer)
         ("C-c p" . project-switch-project)
         ("C-c c" . project-find-file)
         ("C-c s" . project-switch-to-buffer))
  :init
  (setq register-preview-delay 0
        register-preview-function #'consult-register-format)
  :config
  (setq consult-narrow-key "<"))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;;; Find parentheses and brackets easier
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  (define-key evil-normal-state-map (kbd "/") 'avy-goto-char-2)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;;; Language modes
(use-package rust-mode)

;;; Common lisp mode
(use-package slime
  :init
  (setq inferior-lisp-program "sbcl"))
;;; MINIMAL eglot setup
(use-package eglot
  :config
  (add-to-list 'eglot-server-programs '((c++-mode c-mode) "clangd"))
  (add-hook 'rust-mode-hook 'eglot-ensure)
  (add-hook 'c-mode-hook 'eglot-ensure))

(use-package company
  :config
  (global-company-mode))

(use-package format-all
  :hook
  (add-hook 'prog-mode-hook 'format-all-mode))

;;; Terminal
(use-package vterm
    :ensure t)

;;; Buffer management
(defun my-split-vertical ()
    (interactive)
    (split-window-vertically)
    (other-window 1))

(defun my-split-horizontal ()
    (interactive)
    (split-window-horizontally)
    (other-window 1))

(defun open-term ()
    (interactive)
    (split-window-vertically)
    (other-window 1)
    (vterm))

(use-package vterm-toggle
  :bind
  (("C-C t"        . vterm-toggle)
   :map vterm-mode-map
   ("<C-return>" . vterm-toggle-insert-cd))
  :config
  (add-to-list 'display-buffer-alist
     '("\*vterm\*"
       (display-buffer-in-side-window)
       (window-height . 0.2)
       (side . bottom)

       (slot . 0))))

;;; Tree
(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                5000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("C-;" . treemacs)
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package page-break-lines)
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-projects-backend 'project-el)
  (setq dashboard-items '((recents  . 5)
                          (bookmarks . 5)
                          (projects . 5)))
  (setq dashboard-banner-logo-title "Welcome to Chabemacs!")
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-center-content t))


;;; Org Mode
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(use-package tree-sitter)
(use-package tree-sitter-langs)
(global-tree-sitter-mode)
(add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)
 
;;; Org settings
(use-package toc-org
  :hook org-mode)

(use-package ox-hugo
  :ensure t   ;Auto-install the package from Melpa
  :pin melpa  ;`package-archives' should already have ("melpa" . "https://melpa.org/packages/")
  :after ox)

(setq org-image-actual-width '(300))

(org-babel-do-load-languages
 'org-babel-load-languages '((C . t)))


;;; Keybindings
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(global-set-key (kbd "<C-return>") 'my-split-horizontal)
(global-set-key (kbd "<C-M-return>") 'my-split-vertical)
(global-set-key (kbd "") 'kill-buffer-and-window)
(global-set-key (kbd "C-c t") 'open-term)
;;; Define keybinding in major mode map. EX:
(define-key rust-mode-map (kbd "C-x M-t") 'rust-run-clippy)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("02f57ef0a20b7f61adce51445b68b2a7e832648ce2e7efb19d217b6454c1b644" "443e2c3c4dd44510f0ea8247b438e834188dc1c6fb80785d83ad3628eadf9294" "e3daa8f18440301f3e54f2093fe15f4fe951986a8628e98dcd781efbec7a46f2" "333958c446e920f5c350c4b4016908c130c3b46d590af91e1e7e2a0611f1e8c5" "70cfdd2e7beaf492d84dfd5f1955ca358afb0a279df6bd03240c2ce74a578e9e" "1704976a1797342a1b4ea7a75bdbb3be1569f4619134341bd5a4c1cfb16abad4" "84b14a0a41bb2728568d40c545280dbe7d6891221e7fbe7c2b1c54a3f5959289" "c2aeb1bd4aa80f1e4f95746bda040aafb78b1808de07d340007ba898efa484f5" "cf922a7a5c514fad79c483048257c5d8f242b21987af0db813d3f0b138dfaf53" "7a7b1d475b42c1a0b61f3b1d1225dd249ffa1abb1b7f726aec59ac7ca3bf4dae" "c4063322b5011829f7fdd7509979b5823e8eea2abf1fe5572ec4b7af1dd78519" "171d1ae90e46978eb9c342be6658d937a83aaa45997b1d7af7657546cae5985b" "22ce392ec78cd5e512169f8960edf5cbbad70e01d3ed0284ea62ab813d4ff250" "1d5e33500bc9548f800f9e248b57d1b2a9ecde79cb40c0b1398dec51ee820daf" default))
 '(package-selected-packages
   '(ox-hugo org-bullets no-littering zenburn-theme highlight-indent-guides-mode dashboard marginalia vertico treemacs-evil treemacs vterm-toggle vterm company eglot slime rust-mode magit evil-collection evil which-key rainbow-delimiters avy all-the-icons use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
