(require 'yasnippet)

(add-to-list 'yas/snippet-dirs (expand-file-name "snippets" emacs.d-directory))
;; Use only own snippets, do not use bundled ones
;(setq yas/snippet-dirs (list (expand-file-name "snippets" emacs.d-directory)))
;(setq yas/snippet-dirs '((concat emacs.d-directory "snippets")))
;(setq yas/snippet-dirs (list (concat "" "snippets")))
(yas/global-mode 1)

;; Include snippets for Buster.js
;(require 'buster-snippets)

;; Jump to end of snippet definition
(define-key yas/keymap (kbd "<return>") 'yas/exit-all-snippets)

;; Inter-field navigation
(defun yas/goto-end-of-active-field ()
  (interactive)
  (let* ((snippet (car (yas/snippets-at-point)))
        (position (yas/field-end (yas/snippet-active-field snippet))))
    (if (= (point) position)
        (move-end-of-line)
      (goto-char position))))

(defun yas/goto-start-of-active-field ()
  (interactive)
  (let* ((snippet (car (yas/snippets-at-point)))
        (position (yas/field-start (yas/snippet-active-field snippet))))
    (if (= (point) position)
        (move-beginning-of-line)
      (goto-char position))))

(define-key yas/keymap (kbd "C-e") 'yas/goto-end-of-active-field)
(define-key yas/keymap (kbd "C-a") 'yas/goto-start-of-active-field)

;; No dropdowns please, yas
(setq yas/prompt-functions '(yas/ido-prompt yas/completing-prompt))

;; Wrap around region
(setq yas/wrap-around-region t)

(provide 'setup-yasnippet)
