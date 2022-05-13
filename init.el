;;;; Chabi's personal emacs configuration
(setq inhibit-startup-message t)
(load-theme 'wombat 't)
;;; Get rid of ~ files
(setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
      backup-by-copying      t  ; Don't de-link hard links
      version-control        t  ; Use version numbers on backups
      delete-old-versions    t  ; Automatically delete excess backups:
      kept-new-versions      20 ; how many of the newest versions to keep
      kept-old-versions      5) ; and how many of the old

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)

(menu-bar-mode -1)
;;; Visible bell set
(setq visible-bell t)


;;; Font settings
(set-face-attribute 'default nil :font "Fira Code Nerd Font" :height 75)

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
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("835868dcd17131ba8b9619d14c67c127aa18b90a82438c8613586331129dda63" "c4063322b5011829f7fdd7509979b5823e8eea2abf1fe5572ec4b7af1dd78519" default))
 '(eglot-ignored-server-capabilities '(:hoverProvider :codeLensProvider :executeCommandProvider))
 '(package-selected-packages
   '(avy vterm-toggle vterm tree-sitter-langs tree-sitter eglot yasnippet company rustic lsp-ivy lsp-ui lsp-mode rust-mode slime magit counsel-projectile which-key projectile evil-collection evil doom-themes ivy-rich rainbow-delimiters doom-modeline counsel ivy use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(when (display-graphic-p)
  (require 'all-the-icons))
;; or
(use-package all-the-icons
  :if (display-graphic-p))
(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :config
  ;; Disables ^ in counsel search
  (setq ivy-initial-inputs-alist nil))
(use-package avy)
(use-package doom-themes
  :init (load-theme 'doom-gruvbox t))
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)	
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :init
  (ivy-mode 1))
 
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 30)))

;;; Find parentheses and brackets easier
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/SummerOfCode")
    (setq projectile-project-search-path '("~/SummerOfCode")))
  ;; Load up dired on load package
  (setq projectile-switch-project-action #'projectile-dired))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

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
(use-package slime)
(setq inferior-lisp-program "sbcl")

;;; MINIMAL eglot setup
(use-package eglot)
(add-to-list 'eglot-server-programs '((c++-mode c-mode) "clangd"))
(add-hook 'rust-mode-hook 'eglot-ensure)
(add-hook 'c-mode-hook 'eglot-ensure)

(use-package company)
(global-company-mode)

(use-package yasnippet)
(yas-global-mode 1)

;;; Terminal
(use-package vterm
    :ensure t)

;;; Multi-buffer
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
;;; Keybindings
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(global-set-key (kbd "C-M-j") 'counsel-switch-buffer)
(global-set-key (kbd "C-c c") 'counsel-projectile-find-file)
(global-set-key (kbd "<C-return>") 'my-split-horizontal)
(global-set-key (kbd "<C-M-return>") 'my-split-vertical)
(global-set-key (kbd "C-c C-c") 'kill-buffer-and-window)
(global-set-key (kbd "C-c t") 'open-term)
;;; Define keybinding in major mode map. EX:
(define-key rust-mode-map (kbd "C-x M-t") 'rust-run-clippy)
;;; (define-key emacs-lisp-mode-map (kbd "C-x M-t") 'counsel-load-theme) 
