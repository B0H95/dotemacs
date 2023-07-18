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
(eval-after-load "shell" '(progn
                            (define-key shell-mode-map (kbd "TAB") 'dabbrev-expand)
                            (define-key shell-mode-map (kbd "M-/") 'completion-at-point)))
(setq isearch-lazy-count t)
(fido-mode 1)
(fido-vertical-mode 1)
(set-background-color "#FFFFD7")
(blink-cursor-mode 0)
;; TODO: re-add this when some new emacs version comes along
;;       that stops hl-line-mode from overriding highlights
;; (global-hl-line-mode 1)
;; (set-face-background hl-line-face "#F0F0C9")
(global-set-key (kbd "M-o") 'other-window)
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
(defun b0h-toggle-selective-display ()
  (interactive)
  (if selective-display
      (set-selective-display nil)
    (set-selective-display (+ (current-column) 1))))
(global-set-key (kbd "C-x o") 'b0h-toggle-selective-display)
(put 'narrow-to-region 'disabled nil)
;; inspiration: https://stackoverflow.com/a/12101330
(defun b0h-find-file-at-point-with-line ()
  (interactive)
  (let ((line 0)
        (maxpoint (save-excursion
                    (move-end-of-line nil)
                    (point))))
    (save-excursion
      (search-forward-regexp "[^ ]:" maxpoint t)
      (if (looking-at "[0-9]+")
          (setq line (string-to-number (buffer-substring (match-beginning 0) (match-end 0))))))
    (find-file-at-point)
    (if (not (equal line 0))
        (progn
          (goto-line line)
          (recenter-top-bottom)))))
(global-set-key (kbd "C-x m") 'b0h-find-file-at-point-with-line)
(make-variable-buffer-local
 (defvar b0h-isearch-indent-steps nil))
(defun b0h-isearch-indented-symbol-regexp (string &optional lax)
  (format
   (concat "^[[:blank:]]\\{%d" (if (natnump b0h-isearch-indent-steps) "" ",") "\\}\\(%s\\_>\\|[^[:blank:]\r\n].*?\\_<%s\\_>\\).*?$")
   (abs b0h-isearch-indent-steps) (regexp-quote string) (regexp-quote string)))
(defun b0h-isearch-indented-line-regexp (string &optional lax)
  (format
   (concat "^[[:blank:]]\\{%d" (if (natnump b0h-isearch-indent-steps) "" ",") "\\}\\(%s\\|[^[:blank:]\r\n].*?%s\\).*?$")
   (abs b0h-isearch-indent-steps) (regexp-quote string) (regexp-quote string)))
(defun b0h-isearch-forward-symbol-at-point (arg)
  (interactive "P")
  (let ((default-case-fold-search case-fold-search))
    (setq case-fold-search nil)
    (isearch-forward-symbol-at-point)
    (when (integerp arg)
      (setq b0h-isearch-indent-steps arg
            isearch-regexp-function 'b0h-isearch-indented-symbol-regexp)
      (beginning-of-buffer)
      (isearch-repeat-forward))
    (setq case-fold-search default-case-fold-search)))
(defun b0h-isearch-mode-search-for-symbol-at-point (arg)
  (interactive "P")
  (when (symbol-at-point)
    (setq isearch-string (symbol-name (symbol-at-point)))
    (if (integerp arg)
        (progn
          (setq b0h-isearch-indent-steps arg
                isearch-regexp-function 'b0h-isearch-indented-symbol-regexp
                isearch-regexp nil
                isearch-case-fold-search nil
                isearch-message isearch-string)
          (beginning-of-buffer)
          (isearch-repeat-forward))
      (setq isearch-regexp-function 'isearch-symbol-regexp
            isearch-regexp nil
            isearch-case-fold-search nil
            isearch-message isearch-string)
      (isearch-update))))
(keyboard-translate ?\C-m ?\H-m)
(global-set-key [?\H-m] 'b0h-isearch-forward-symbol-at-point)
(define-key isearch-mode-map [?\H-m] 'b0h-isearch-mode-search-for-symbol-at-point)
(defun b0h-isearch-forward-indented-line (arg)
  (interactive "P")
  (when (integerp arg)
    (isearch-mode t)
    (setq b0h-isearch-indent-steps arg
          isearch-regexp-function 'b0h-isearch-indented-line-regexp)
    (beginning-of-buffer)))
(defun b0h-isearch-mode-toggle-indented-line (arg)
  (interactive "P")
  (when (integerp arg)
    (setq b0h-isearch-indent-steps arg
          isearch-regexp-function 'b0h-isearch-indented-line-regexp
          isearch-regexp nil)
    (isearch-update)))
(global-set-key (kbd "M-s l") 'b0h-isearch-forward-indented-line)
(define-key isearch-mode-map (kbd "M-s l") 'b0h-isearch-mode-toggle-indented-line)
(global-subword-mode 1)
(setq kill-buffer-query-functions (delq 'process-kill-buffer-query-function kill-buffer-query-functions))
(global-set-key (kbd "M-ä") 'forward-paragraph)
(global-set-key (kbd "M-ö") 'backward-paragraph)
(defconst b0h-jump-mode-input-chars (list
                                     "g" "x" "n" "h" "t" "y" "b" "z" "u" "r"
                                     "q" "p" "c" "v" "m" "a" "s" "l" "d"
                                     "k" "w" "o" "e" "i" "f" "j"))
(make-variable-buffer-local
 (defvar b0h-jump-mode-search-string nil))
(make-variable-buffer-local
 (defvar b0h-jump-mode-matches nil))
(make-variable-buffer-local
 (defvar b0h-jump-mode-overlays nil))
(make-variable-buffer-local
 (defvar b0h-jump-mode-window-start nil))
(make-variable-buffer-local
 (defvar b0h-jump-mode-window-end nil))
(make-variable-buffer-local
 (defvar b0h-jump-mode-narrowing nil))
(defun b0h-jump-mode-initialize ()
  (make-local-variable 'b0h-jump-mode-search-string)
  (make-local-variable 'b0h-jump-mode-matches)
  (make-local-variable 'b0h-jump-mode-overlays)
  (make-local-variable 'b0h-jump-mode-window-start)
  (make-local-variable 'b0h-jump-mode-window-end)
  (make-local-variable 'b0h-jump-mode-narrowing)
  (setq b0h-jump-mode-search-string ""
        b0h-jump-mode-matches (make-hash-table :test 'equal)
        b0h-jump-mode-overlays nil
        b0h-jump-mode-window-start (window-start)
        b0h-jump-mode-window-end (window-end)
        b0h-jump-mode-narrowing nil))
(defun b0h-jump-mode-forward-char ()
  (if (/= (point) (point-at-eol))
      (forward-char)
    (let ((prev-point (point)))
      (next-line)
      (when (<= (point) prev-point)
        ;; some bug makes next-line not move point forward at all from time to time
        (goto-char prev-point)
        (forward-char)))
    (move-beginning-of-line nil)))
(defun b0h-jump-mode-vacant-letters ()
  (let ((table (make-hash-table :test 'equal)))
    (mapc
     (lambda (x) (puthash x t table))
     b0h-jump-mode-input-chars)
    (save-excursion
      (let ((start b0h-jump-mode-window-start)
            (end b0h-jump-mode-window-end))
        (goto-char start)
        (while (< (point) end)
          (when (looking-at (regexp-quote b0h-jump-mode-search-string))
            (save-excursion
              (forward-char (length b0h-jump-mode-search-string))
              (puthash (downcase (make-string 1 (char-after))) nil table)))
          (b0h-jump-mode-forward-char))))
    table))
(defun b0h-jump-mode-create-match-inputs (vacant-letter-map)
  (let ((l nil))
    (maphash (lambda (k v)
               (when v
                 (mapc (lambda (x)
                         (push (list k x) l))
                       b0h-jump-mode-input-chars)))
             vacant-letter-map)
    l))
(defun b0h-jump-mode-push-match (match-input position)
  (let* ((first (nth 0 match-input))
         (second (nth 1 match-input))
         (first-table
          (if (gethash first b0h-jump-mode-matches)
              (gethash first b0h-jump-mode-matches)
            (puthash first (make-hash-table :test 'equal) b0h-jump-mode-matches)
            (gethash first b0h-jump-mode-matches))))
    (puthash second position first-table)))
(defun b0h-jump-mode-populate-overlays-and-matches (match-inputs)
  (save-excursion
    (let ((start b0h-jump-mode-window-start)
          (end b0h-jump-mode-window-end))
      (goto-char start)
      (while (< (point) end)
        (when (looking-at (regexp-quote b0h-jump-mode-search-string))
          (let ((match-input (pop match-inputs)))
            (when match-input
              (let ((overlay (make-overlay (point) (+ (point) 2))))
                (b0h-jump-mode-push-match match-input (point))
                (let ((match-input-string (concat (nth 0 match-input) (nth 1 match-input))))
                  (overlay-put overlay 'display match-input-string)
                  (overlay-put overlay 'face '((t (:background "#9CFFAF") (:foreground "#000000"))))
                  (push overlay b0h-jump-mode-overlays))))))
        (b0h-jump-mode-forward-char)))))
(defun b0h-jump-mode-clear-overlays ()
  (while b0h-jump-mode-overlays
    (let ((overlay (pop b0h-jump-mode-overlays)))
      (delete-overlay overlay))))
(defun b0h-jump-mode-clear-matches ()
  (clrhash b0h-jump-mode-matches))
(defun b0h-jump-mode-finish ()
  (b0h-jump-mode-clear-overlays)
  (b0h-jump-mode 0))
(defun b0h-jump-mode-narrow-overlays (input)
  (let ((iter (car b0h-jump-mode-overlays))
        (rest (cdr b0h-jump-mode-overlays)))
    (while iter
      (let ((str (overlay-get iter 'display)))
        (if (string-prefix-p input str t)
            (progn
              (move-overlay iter (overlay-start iter) (1- (overlay-end iter)))
              (overlay-put iter 'display (substring str 1)))
          (move-overlay iter (overlay-start iter) (overlay-start iter))
          (overlay-put iter 'display nil)))
      (setq iter (car rest)
            rest (cdr rest)))))
(defun b0h-jump-mode-self-insert ()
  (interactive)
  (let* ((input (downcase (make-string 1 last-command-event)))
         (match-entry (gethash input b0h-jump-mode-matches)))
    (if b0h-jump-mode-narrowing
        (when match-entry
          (goto-char match-entry)
          (b0h-jump-mode-finish))
      (if match-entry
          (progn
            (b0h-jump-mode-narrow-overlays input)
            (setq b0h-jump-mode-narrowing t)
            (setq b0h-jump-mode-matches match-entry))
        (setq b0h-jump-mode-search-string (concat b0h-jump-mode-search-string input))
        (message "Search string: %s" b0h-jump-mode-search-string)
        (b0h-jump-mode-clear-overlays)
        (b0h-jump-mode-clear-matches)
        (b0h-jump-mode-populate-overlays-and-matches (b0h-jump-mode-create-match-inputs (b0h-jump-mode-vacant-letters)))))))
(defun b0h-jump-mode-cancel ()
  (interactive)
  (b0h-jump-mode-finish)
  (signal 'quit nil))
(defvar b0h-jump-mode-map
  (let ((i 0)
        (map (make-keymap)))
    ;; inspired by isearch-mode-map
    (set-char-table-range (nth 1 map) (cons #x100 (max-char))
			  'b0h-jump-mode-self-insert)
    (setq i ?\s)
    (while (< i 256)
      (define-key map (vector i) 'b0h-jump-mode-self-insert)
      (setq i (1+ i)))
    (define-key map (kbd "C-g") 'b0h-jump-mode-cancel)
    map))
(define-minor-mode b0h-jump-mode "Mode for jumping around"
  :lighter " jump"
  :keymap b0h-jump-mode-map
  (b0h-jump-mode-initialize))
(keyboard-translate ?\C-i ?\H-i)
(global-set-key [?\H-i] 'b0h-jump-mode)
(define-key isearch-mode-map (kbd "C-l") (lambda () (interactive) (recenter-top-bottom) (isearch-update)))
(fset 'yes-or-no-p 'y-or-n-p)
(setq dabbrev-case-fold-search nil)
(global-set-key (kbd "C-w") (lambda () (interactive) (when mark-active (call-interactively 'kill-region))))
(setq dired-auto-revert-buffer t)
(winner-mode 1)
