(toggle-scroll-bar -1)
(setq evil-want-keybinding nil)
(setq inhibit-startup-screen t)

;; (package-initialize)
;; (setq package-archives '(("melpa" . "https://melpa.org/packages/")
;;                          ("org"   . "https://orgmode.org/elpa/")
;;                          ("elpa"  . "https://elpa.gnu.org/packages/")))
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(require 'package)
;; Initialize use-package on non-linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

;; Make sure packages are downloaded and installed before they are run
;; also frees you from having to put :ensure t after installing EVERY PACKAGE.
(setq use-package-always-ensure t)

(setq package-selected-packages '(lsp-mode yasnippet lsp-treemacs helm-lsp projectile hydra flycheck company avy which-key helm-xref dap-mode gruvbox-theme json-mode))
(when (cl-find-if-not #'package-installed-p package-selected-packages)
  (package-refresh-contents)
  (mapc #'package-install package-selected-packages))
(load-theme 'gruvbox t)

(helm-mode)
(require 'helm-xref)
(define-key global-map [remap find-file] #'helm-find-files)
(define-key global-map [remap execute-extended-command] #'helm-M-x)
(define-key global-map [remap switch-to-buffer] #'helm-mini)
(which-key-mode)
(add-hook 'prog-mode-hook #'lsp)
(setq gc-cons-threshold (* 100 1024 1024)
            read-process-output-max (* 1024 1024)
                  company-idle-delay 0.0
                        company-minimum-prefix-length 1
                              create-lockfiles nil) ;; lock files will kill `npm start'
(with-eval-after-load 'lsp-mode
                        (require 'dap-chrome)
                          (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
                            (yas-global-mode))

(setq evil-want-C-i-jump nil)
;; Download Evil
(unless (package-installed-p 'evil)
  (package-install 'evil))

;; Enable Evil
(setq evil-want-C-u-scroll t)
(require 'evil)
(evil-mode t)
(setq evil-emacs-state-modes (delq 'ibuffer-mode evil-emacs-state-modes))
(define-key helm-map (kbd "C-j") 'helm-next-line)
(define-key helm-map (kbd "C-k") 'helm-previous-line)
(require 'treemacs)
(evil-define-key 'treemacs treemacs-mode-map (kbd "h")      #'treemacs-COLLAPSE-action)
(evil-define-key 'treemacs treemacs-mode-map (kbd "l")      #'treemacs-RET-action)

(add-to-list 'display-buffer-alist
                    `(,(rx bos "*helm" (* not-newline) "*" eos)
                         (display-buffer-in-side-window)
                         (inhibit-same-window . t)
                         (window-height . 0.4)))

;; evil-collection
(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

;; show opening, closing parens
(show-paren-mode)

;; show relative line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode)

(use-package flycheck
  :ensure t
  :config
  (add-hook 'typescript-mode-hook 'flycheck-mode))
 
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))
 
(use-package company
  :ensure t
  :config
  (setq company-show-numbers t)
  (setq company-tooltip-align-annotations t)
  ;; invert the navigation direction if the the completion popup-isearch-match
  ;; is displayed on top (happens near the bottom of windows)
  (setq company-tooltip-flip-when-above t)
  (global-company-mode))
 
(use-package company-quickhelp
  :ensure t
  :init
  (company-quickhelp-mode 1)
  (use-package pos-tip
    :ensure t))
 
(use-package web-mode
  :ensure t
  :mode (("\\.html?\\'" . web-mode)
         ("\\.tsx\\'" . web-mode)
         ("\\.jsx\\'" . web-mode))
  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2
        web-mode-block-padding 2
        web-mode-comment-style 2
 
        web-mode-enable-css-colorization t
        web-mode-enable-auto-pairing t
        web-mode-enable-comment-keywords t
        web-mode-enable-current-element-highlight t
	web-mode-enable-auto-indentation nil
        )
  (add-hook 'web-mode-hook
            (lambda ()
              (when (string-equal "tsx" (file-name-extension buffer-file-name))
		(setup-tide-mode))))
  ;; enable typescript-tslint checker
  (flycheck-add-mode 'typescript-tslint 'web-mode))
 
(use-package typescript-mode
  :ensure t
  :config
  (setq typescript-indent-level 2)
  (add-hook 'typescript-mode #'subword-mode))
 
(use-package tide
  :init
  :ensure t
  :after (typescript-mode company flycheck)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)))
 
(use-package css-mode
  :config
(setq css-indent-offset 2))

(use-package dashboard
  :ensure t
  :config
  (setq show-week-agenda-p t)
  (setq dashboard-items '((recents . 15) (agenda . 5)))
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-startup-banner 3)
  :init
  (dashboard-setup-startup-hook)
  )

;; (defun my/dashboard-banner ()
;;   """Set a dashboard banner including information on package initialization
;;    time and garbage collections."""
;;   (setq dashboard-banner-logo-title
;;         (format "Emacs ready in %.2f seconds with %d garbage collections."
;;                 (float-time (time-subtract after-init-time before-init-time)) gcs-done)))

;; (use-package dashboard
;;   :init
;;   (add-hook 'after-init-hook 'dashboard-refresh-buffer)
;;   (add-hook 'dashboard-mode-hook 'my/dashboard-banner)
;;   :config
;;   (setq dashboard-startup-banner 'logo)
;;   (dashboard-setup-startup-hook))

(use-package lsp-mode
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  :init (setq lsp-keymap-prefix "C-c l")
  :hook (;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)
(add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)

;; projectile
(unless (package-installed-p 'projectile)
  (package-install 'projectile))
(use-package projectile
  :ensure t
  :pin melpa
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map)))

; org-mode
 (use-package org-bullets
    :ensure t
        :init
        (add-hook 'org-mode-hook (lambda ()
                            (org-bullets-mode 1))))
(setq org-cycle-emulate-tab 'white)

;; mode-line
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package all-the-icons)
(all-the-icons-octicon "file-binary")  ;; GitHub Octicon for Binary File
(all-the-icons-faicon  "cogs")         ;; FontAwesome icon for cogs
(all-the-icons-wicon   "tornado")      ;; Weather Icon for tornado

(setq tab-width 2) ; or any other preferred value
(add-hook 'after-init-hook #'global-prettier-mode)

(use-package treemacs)
(use-package treemacs-evil)
(use-package treemacs-magit)

(use-package all-the-icons-dired
:config
;(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)
;:hook (dired-mode-hook . all-the-icons-dired-mode)
;defer loading of all-the-icons-dired until called
:commands all-the-icons-dired-mode
);end all the icons dired

 (add-hook 'emacs-lisp-mode-hook
              (lambda ()
                ;; Use spaces, not tabs.
                (setq indent-tabs-mode nil)
                ;; Keep M-TAB for `completion-at-point'
                (define-key flyspell-mode-map "\M-\t" nil)
                ;; Pretty-print eval'd expressions.
                (define-key emacs-lisp-mode-map
                            "\C-x\C-e" 'pp-eval-last-sexp)
                ;; Recompile if .elc exists.
                (add-hook (make-local-variable 'after-save-hook)
                          (lambda ()
                            (byte-force-recompile default-directory)))
                (define-key emacs-lisp-mode-map
                            "\r" 'reindent-then-newline-and-indent)))
    (add-hook 'emacs-lisp-mode-hook 'eldoc-mode)
    (add-hook 'emacs-lisp-mode-hook 'flyspell-prog-mode) ;; Requires Ispell

(use-package all-the-icons-ivy
  :init (add-hook 'after-init-hook 'all-the-icons-ivy-setup))

(set-face-attribute 'flycheck-error nil :underline '(:color "red2" :style wave))

;; dired copy to another open dired buffer
(setq dired-dwim-target t)

;; autocomplete paired brackets
(electric-pair-mode 1)

;; enable cousel projectile-mode on startup
(add-hook 'emacs-startup-hook 'counsel-projectile-mode)

;; dired copy from one buffer too another
(setq dired-dwim-target t)

;; enable winner mode to navigate back and forth
;; (winner-mode 1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ediff                                                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'ediff)
;; don't start another frame
;; this is done by default in preluse
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
;; put windows side by side
(setq ediff-split-window-function (quote split-window-horizontally))
;;revert windows on exit - needs winner mode
(winner-mode)
(add-hook 'ediff-after-quit-hook-internal 'winner-undo)
(defun update-diff-colors ()
  "update the colors for diff faces"
  (set-face-attribute 'diff-added nil
                      :foreground "white" :background "blue")
  (set-face-attribute 'diff-removed nil
                      :foreground "white" :background "red3")
  (set-face-attribute 'diff-changed nil
                      :foreground "white" :background "purple"))
(eval-after-load "diff-mode"
  '(update-diff-colors))
(require 'wgrep)

(setq org-capture-templates
      '(("d" "Taks template" entry
         (file "chapterly-demo-tasks.org")
         "* TODO %^{Header} :%^{tag|FEATURE|BUG}\n SCHEDULED: %^t\n %?")))

(setq org-todo-keywords
      '((sequence "TODO" "IN-PROGRESS" "ON-HOLD" "|" "DONE" "WONT-FIX")))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(helm-minibuffer-history-key "M-p")
 '(package-selected-packages
   '(wgrep counsel-ag-popup mct helm-ispell git-gutter+ rainbow-mode dired emmet-mode nodejs-repl restclient paredit flycheck-clojure clojure-mode counsel-projectile smartparens all-the-icons-ibuffer all-the-icons-ivy dashboard treemacs-icons-dired treemacs-evil treemacs-projectile treemacs-magit prettier doom-modeline ag magit evil-magit lsp-mode yasnippet lsp-treemacs helm-lsp projectile hydra flycheck company avy which-key helm-xref dap-mode gruvbox-theme json-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(flycheck-error ((t (:background "red" :underline (:color "red" :style wave)))))
 '(flycheck-warning ((t (:background "color-137" :underline (:color "#ffaf00" :style wave))))))
