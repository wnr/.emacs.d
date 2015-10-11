;; Frame (window) size
;;(set-frame-parameter nil 'fullscreen 'fullboth)
(add-to-list 'default-frame-alist '(width  . 114))
(add-to-list 'default-frame-alist '(height . 71))

;; Turn off mouse interface early in startup to avoid momentary display
;;(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
;;(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; No splash screen please ... jeez
(setq inhibit-startup-message t)

;; Set path to dependencies
(setq site-lisp-dir (expand-file-name "site-lisp" emacs.d-directory))

;; Set up load path
(add-to-list 'load-path emacs.d-directory)
(add-to-list 'load-path site-lisp-dir)

;; Settings for currently logged in user
;(setq user-settings-dir
;      (concat emacs.d-directory "users/" user-login-name))
;(add-to-list 'load-path user-settings-dir)

;; Add external projects to load path
(dolist (project (directory-files site-lisp-dir t "\\w+"))
  (when (file-directory-p project)
    (add-to-list 'load-path project)))

;; Keep emacs Custom-settings in separate file
(setq custom-file (expand-file-name "custom.el" emacs.d-directory))
(load custom-file)

;; Write backup files to own directory
(setq backup-directory-alist
      `((".*" . ,(expand-file-name
                  (concat user-emacs-directory "backups")))))

;; Make backups of files, even when they're in version control
(setq vc-make-backup-files t)

;; Write auto-save files to own directory
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; Save point position between sessions
(require 'saveplace)
(setq-default save-place t)
(setq save-place-file (expand-file-name ".places" user-emacs-directory))

;; Are we on a mac?
(setq is-mac (equal system-type 'darwin))

;; Setup elnode before packages to stop it from starting a server
(require 'setup-elnode)

;; Control versions of packages
(setq package-load-list '((cider "0.8.2") all))

;; Setup packages
(require 'setup-package)

;; Install extensions if they're missing
(defun init--install-packages ()
  (packages-install
;   (cons 'exec-path-from-shell melpa)
   (cons 'paredit melpa)
   (cons 'auto-complete melpa)
   (cons 'diminish melpa)   
   (cons 'git-commit-mode melpa)
   (cons 'gitconfig-mode melpa)
   (cons 'gitignore-mode melpa)
   (cons 'groovy-mode melpa)
   (cons 'iy-go-to-char melpa)
   (cons 'js2-mode melpa)
   (cons 'js2-refactor melpa)
   (cons 'key-chord melpa)
   (cons 'less-css-mode melpa)   
   (cons 'magit melpa)
   (cons 'move-text melpa)
   (cons 'restclient melpa)
   (cons 'zencoding-mode melpa)
   (cons 'scss-mode melpa)   
;   (cons 'gist melpa)
;   (cons 'htmlize melpa)
   (cons 'visual-regexp melpa)
   (cons 'visual-regexp-steroids melpa)
;   (cons 'smartparens melpa)
;   (cons 'elisp-slime-nav melpa)
;   ;(cons 'elnode marmalade)
;   (cons 'slime-js marmalade)
;   (cons 'clojure-mode melpa)
;   (cons 'nrepl melpa)
   ))

(condition-case nil
    (init--install-packages)
  (error
   (package-refresh-contents)
   (init--install-packages)))

;; Set up appearance early
(require 'appearance)

;; Lets start with a smattering of sanity
(require 'sane-defaults)

;; Setup environment variables from the user's shell.
;(when is-mac (exec-path-from-shell-initialize))

;; Setup extensions
(eval-after-load 'org '(require 'setup-org))
;(eval-after-load 'dired '(require 'setup-dired))
;(eval-after-load 'magit '(require 'setup-magit))
;(eval-after-load 'grep '(require 'setup-rgrep))
;(eval-after-load 'shell '(require 'setup-shell))
;(require 'setup-hippie)

(eval-after-load 'auto-complete '(require 'setup-auto-complete))
(require 'setup-ace-jump-mode)
(require 'setup-ido)
(require 'setup-clojure)
(require 'setup-key-chord)
(require 'setup-markdown-mode)
(require 'setup-org)
(require 'setup-scss)
;(require 'setup-paredit)
(require 'setup-yasnippet)
(require 'setup-zencoding-mode)
;(require 'setup-perspective)
;(require 'setup-ffip)
;(require 'setup-html-mode)
;(require 'setup-paredit)
;
;; Default setup of smartparens
;(require 'smartparens-config)

;; Language specific setup files
(require 'setup-js2-mode)
;(eval-after-load 'ruby-mode '(require 'setup-ruby-mode))
;(eval-after-load 'clojure-mode '(require 'setup-clojure-mode))
;(eval-after-load 'markdown-mode '(require 'setup-markdown-mode))
;
;; Load slime-js when asked for
;(autoload 'slime-js-jack-in-browser "setup-slime-js" nil t)
;(autoload 'slime-js-jack-in-node "setup-slime-js" nil t)

;; Map files to modes
;(require 'mode-mappings)

;; Visual regexp
(require 'visual-regexp)
(require 'visual-regexp-steroids)
;(define-key global-map (kbd "M-&") 'vr/query-replace)
;(define-key global-map (kbd "M-/") 'vr/replace)

;; Tern.js
(add-to-list 'load-path (expand-file-name "tern/emacs" site-lisp-dir))
(autoload 'tern-mode "tern.el" nil t)
(add-hook 'js2-mode-hook (lambda () (tern-mode t)))
(eval-after-load 'tern
  '(progn
     (require 'tern-auto-complete)
     (tern-ac-setup)))

;; Functions (load all files in defuns-dir)
(setq defuns-dir (expand-file-name "defuns" emacs.d-directory))
(dolist (file (directory-files defuns-dir t "\\w+"))
  (when (file-regular-p file)
    (load file)))

;; Functions (load all files in defuns-dir)
(setq defuns-dir (expand-file-name "my-defuns" emacs.d-directory))
(dolist (file (directory-files defuns-dir t "\\w+"))
  (when (file-regular-p file)
    (load file)))

(require 'expand-region)
;(require 'mark-more-like-this)
;(require 'inline-string-rectangle)
(require 'multiple-cursors)
;(require 'delsel)
;(require 'jump-char)
;(require 'eproject)
;(require 'wgrep)
;(require 'smart-forward)
;(require 'change-inner)
;(require 'multifiles)
(require 'my-misc)
(require 'run-current-file)
(require 'sort-and-delete-duplicate-lines)
(require 'toggle-window-dedicated)

;
;; Fill column indicator
;(require 'fill-column-indicator)
;(setq fci-rule-color "#111122")

;; Browse kill ring
(require 'browse-kill-ring)
(setq browse-kill-ring-quit-action 'save-and-restore)

;; Smart M-x is smart
;(require 'smex)
;(smex-initialize)

;; Setup key bindings
(require 'key-bindings)

;; Misc
;(require 'project-archetypes)
;(require 'appearance)
;(require 'my-misc)
;(when is-mac (require 'mac))

;; Diminish modeline clutter
;(require 'diminish)
;(diminish 'yas/minor-mode)
;(diminish 'eldoc-mode)
;(diminish 'paredit-mode)

;; Elisp go-to-definition with M-. and back again with M-,
;(autoload 'elisp-slime-nav-mode "elisp-slime-nav")
;(add-hook 'emacs-lisp-mode-hook (lambda () (elisp-slime-nav-mode t) (eldoc-mode 1)))
;(eval-after-load 'elisp-slime-nav '(diminish 'elisp-slime-nav-mode))

;; Email, baby
;(require 'setup-mu4e)

;; Emacs server
;(require 'server)
;(unless (server-running-p)
;  (server-start))

;; Run at full power please
;(put 'downcase-region 'disabled nil)
;(put 'narrow-to-region 'disabled nil)

;; Conclude init by setting up specifics for the current user
;(when (file-exists-p user-settings-dir)
;  (mapc 'load (directory-files user-settings-dir nil "^[^#].*el$")))

;; Configures indentation of groovy, java, C and related modes all at once
(defun my-c-mode-hook () 
  (setq indent-tabs-mode nil 
        c-basic-offset 4)) 
(add-hook 'c-mode-common-hook 'my-c-mode-hook) 
