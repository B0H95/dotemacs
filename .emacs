(global-auto-revert-mode 1)
(setq make-backup-files nil)
(setq auto-save-default nil)
(menu-bar-mode 0)
(setq scroll-step 1)
(setq inhibit-splash-screen t)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq next-line-add-newlines nil)
(setq mouse-wheel-progressive-speed nil)
(setq scroll-conservatively 10000)
(setq scroll-preserve-screen-position 1)
(setq next-screen-context-lines 33) ;; do i still need this?
(defun b0h-scroll-up ()
  (interactive)
  (scroll-down-command (/ (window-body-height) 3)))
(defun b0h-scroll-down ()
  (interactive)
  (scroll-up-command (/ (window-body-height) 3)))
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 8)
(setq-default c-default-style "linux")
(setq-default buffer-file-coding-system 'utf-8-unix)
(setq default-buffer-file-coding-system 'utf-8-unix)
(setq initial-major-mode 'fundamental-mode)
(setq initial-scratch-message nil)
(setq line-move-visual nil)
(global-set-key (kbd "C-c p") 'find-lisp-find-dired)
(defun b0h-conservative-window-split (&optional window)
  (if (= (count-windows) 1)
      (with-selected-window window (split-window-right))
    (selected-window)))
(setq split-window-preferred-function #'b0h-conservative-window-split)
(setq b0h-saved-point-line nil)
(setq b0h-saved-point-column nil)
(defun b0h-save-point ()
  (interactive)
  (progn
    (setq b0h-saved-point-line (- (line-number-at-pos) 1))
    (setq b0h-saved-point-column (- (point) (line-beginning-position)))))
(defun b0h-load-point ()
  (interactive)
  (if b0h-saved-point-line
      (if b0h-saved-point-column
          (progn
            (goto-char (point-min))
            (ignore-errors (forward-line b0h-saved-point-line))
            (ignore-errors (forward-char b0h-saved-point-column))
            (if (/= b0h-saved-point-line (- (line-number-at-pos) 1))
                (progn
                  (goto-char (point-min))
                  (ignore-errors (forward-line b0h-saved-point-line))
                  (move-end-of-line nil)))))))
(setq hi-lock-auto-select-face nil) ;; variable doesn't exist by default
(defun b0h-toggle-highlight-at-point ()
  (interactive)
  (make-local-variable 'b0h-highlights)
  (if (not (boundp 'b0h-highlights))
      (setq b0h-highlights (make-hash-table :test 'equal)))
  (save-excursion
    (let ((default-hi-lock-auto-select-face-value hi-lock-auto-select-face)
          (default-case-fold-search-value case-fold-search))
      (setq hi-lock-auto-select-face t)
      (setq case-fold-search nil)
      (if (looking-at "[[:alnum:]_]")
          (progn
            (search-forward-regexp "\\_>")
            (let ((end (point)))
              (search-backward-regexp "\\_<")
              (let ((symbol-regexp (concat "\\_<" (buffer-substring (point) end) "\\_>")))
                (if (gethash symbol-regexp b0h-highlights)
                    (progn
                      (remhash symbol-regexp b0h-highlights)
                      (unhighlight-regexp symbol-regexp))
                  (progn
                    (puthash symbol-regexp t b0h-highlights)
                    (highlight-regexp symbol-regexp (hi-lock-read-face-name))))))))
      (setq hi-lock-auto-select-face default-hi-lock-auto-select-face-value)
      (setq case-fold-search default-case-fold-search-value))))
(defun b0h-clear-all-highlights ()
  (interactive)
  (make-local-variable 'b0h-highlights)
  (if (not (boundp 'b0h-highlights))
      (setq b0h-highlights (make-hash-table :test 'equal)))
  (maphash (lambda (symbol-regexp unused)
             (unhighlight-regexp symbol-regexp))
           b0h-highlights)
  (clrhash b0h-highlights))
(global-set-key (kbd "C-t") 'b0h-toggle-highlight-at-point)
(global-set-key (kbd "M-t") 'b0h-clear-all-highlights)
(global-set-key (kbd "C-v") 'b0h-scroll-down)
(global-set-key (kbd "M-v") 'b0h-scroll-up)
(setq b0h-saved-window-configuration nil)
(defun b0h-toggle-window-maximized ()
  (interactive)
  (if b0h-saved-window-configuration
      (let ((cur-window (selected-window)))
        (set-window-configuration b0h-saved-window-configuration)
        (select-window cur-window)
        (setq b0h-saved-window-configuration nil))
    (progn
      (setq b0h-saved-window-configuration (current-window-configuration))
      (maximize-window))))
(global-set-key (kbd "C-j") 'b0h-toggle-window-maximized)
(define-key key-translation-map (kbd "TAB") (kbd "M-/"))
(define-key key-translation-map (kbd "M-/") (kbd "TAB"))
(define-key key-translation-map (kbd "C-z") (kbd "TAB"))
(add-hook 'minibuffer-setup-hook
          (lambda ()
            (define-key key-translation-map (kbd "TAB") (kbd "TAB"))
            (define-key key-translation-map (kbd "M-/") (kbd "M-/"))
            (define-key key-translation-map (kbd "C-z") (kbd "M-/"))))
(add-hook 'minibuffer-exit-hook
          (lambda ()
            (define-key key-translation-map (kbd "TAB") (kbd "M-/"))
            (define-key key-translation-map (kbd "M-/") (kbd "TAB"))
            (define-key key-translation-map (kbd "C-z") (kbd "TAB"))))
(setq isearch-lazy-count t)
(fido-mode 1)
(fido-vertical-mode 1)
(set-background-color "#FFFFD7")
(blink-cursor-mode 0)
;; TODO: re-add this when some new emacs version comes along
;;       that stops hl-line-mode from overriding highlights
;; (global-hl-line-mode 1)
;; (set-face-background hl-line-face "#F0F0C9")
(global-set-key (kbd "C-o") 'other-window)
(setq column-number-mode t)
(defun b0h-delete-line ()
  (interactive)
  (if (use-region-p)
      (delete-region (region-beginning) (region-end))
    (if (= (point) (point-at-eol))
        (delete-char 1)
      (delete-region (point) (line-end-position)))))
(defun b0h-delete-word (arg)
  (interactive "p")
  (if (use-region-p)
      (delete-region (region-beginning) (region-end))
    (let ((next-point (point)))
      (save-excursion
        (forward-word arg)
        (setq next-point (point)))
      (delete-region (point) next-point))))
(defun b0h-backward-delete-word (arg)
  (interactive "p")
  (b0h-delete-word (- arg)))
(global-set-key (kbd "C-k") 'b0h-delete-line)
(global-set-key (kbd "M-d") 'b0h-delete-word)
(global-set-key (kbd "C-<backspace>") 'b0h-backward-delete-word)
(global-set-key (kbd "M-DEL") 'b0h-backward-delete-word)
(set-cursor-color "#F00279")
(setq b0h-theme-text-color "SystemWindowText")
(setq b0h-theme-keyword-color "#0022C9")
(setq b0h-theme-string-color "#6E0000")
(setq b0h-theme-comment-color "#015400")
(setq b0h-theme-region-color "#D7FFDE")
(setq b0h-theme-search-highlight-color "#7AA4FF")
(set-face-attribute 'font-lock-builtin-face nil :foreground b0h-theme-keyword-color)
(set-face-attribute 'font-lock-comment-delimiter-face nil :foreground b0h-theme-comment-color)
(set-face-attribute 'font-lock-comment-face nil :foreground b0h-theme-comment-color)
(set-face-attribute 'font-lock-constant-face nil :foreground b0h-theme-text-color)
(set-face-attribute 'font-lock-doc-face nil :foreground b0h-theme-comment-color)
(set-face-attribute 'font-lock-doc-markup-face nil :foreground b0h-theme-comment-color)
(set-face-attribute 'font-lock-function-name-face nil :foreground b0h-theme-text-color)
(set-face-attribute 'font-lock-keyword-face nil :foreground b0h-theme-keyword-color)
(set-face-attribute 'font-lock-negation-char-face nil :foreground b0h-theme-text-color)
(set-face-attribute 'font-lock-preprocessor-face nil :foreground b0h-theme-keyword-color)
(set-face-attribute 'font-lock-string-face nil :foreground b0h-theme-string-color)
(set-face-attribute 'font-lock-type-face nil :foreground b0h-theme-text-color)
(set-face-attribute 'font-lock-variable-name-face nil :foreground b0h-theme-text-color)
(set-face-attribute 'region nil :background b0h-theme-region-color)
(set-face-attribute 'lazy-highlight nil :background b0h-theme-search-highlight-color)
(setq confirm-kill-emacs #'yes-or-no-p)
(global-set-key (kbd "C-x å") 'enlarge-window)
