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
(setq next-screen-context-lines 33)
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
;; reference: https://emacs.stackexchange.com/questions/21651
(defun b0h-reasonable-window-split (&optional window)
  (cond
   ((and (> (window-width window)
            (window-height window))
         (window-splittable-p window 'horizontal))
    (with-selected-window window
      (split-window-right)))
   ((window-splittable-p window)
    (with-selected-window window
      (split-window-below)))))
(setq split-window-preferred-function #'b0h-reasonable-window-split)
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
;; check "M-x find-function shell-command-on-region" for details
(defun b0h-format-file (command)
  (interactive (list (read-shell-command "Shell command: ")))
  (b0h-save-point)
  (call-process-region (point-min) (point-max) shell-file-name t t nil shell-command-switch command)
  (b0h-load-point)
  (recenter-top-bottom))
(define-key key-translation-map (kbd "TAB") (kbd "M-/"))
(define-key key-translation-map (kbd "M-/") (kbd "TAB"))
(add-hook 'minibuffer-setup-hook
          (lambda ()
            (define-key key-translation-map (kbd "TAB") (kbd "TAB"))
            (define-key key-translation-map (kbd "M-/") (kbd "M-/"))))
(add-hook 'minibuffer-exit-hook
          (lambda ()
            (define-key key-translation-map (kbd "TAB") (kbd "M-/"))
            (define-key key-translation-map (kbd "M-/") (kbd "TAB"))))
