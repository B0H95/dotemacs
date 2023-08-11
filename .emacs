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
;; reference: https://emacs.stackexchange.com/questions/21651
(defun b0h-preferred-window-split (&optional window)
  (cond
   ((and (> (window-pixel-width window)
            (window-pixel-height window))
         (window-splittable-p window 'horizontal))
    (with-selected-window window
      (split-window-right)))
   ((window-splittable-p window)
    (with-selected-window window
      (split-window-below)))))
(setq split-window-preferred-function #'b0h-preferred-window-split)
(setq split-width-threshold 80)
(setq split-height-threshold 40)
(setq b0h-saved-visible-window-attributes nil)
(defun b0h-set-window-start-by-line (window line) ;; line=1 => first line
  (let ((p nil))
    (with-selected-window window
      (save-excursion
        (beginning-of-buffer)
        (forward-line (1- line))
        (beginning-of-line)
        (setq p (point))))
    (set-window-start window p)))
(defun b0h-save-visible-window-attributes ()
  (interactive)
  (setq b0h-saved-visible-window-attributes
        (mapcar (lambda (w)
                  (with-selected-window w
                    (list
                     w
                     (1- (line-number-at-pos))
                     (- (point) (line-beginning-position))
                     (line-number-at-pos (window-start)))))
                (seq-filter (lambda (w) (eq (window-buffer (selected-window)) (window-buffer w))) (window-list)))))
(defun b0h-load-visible-window-attributes ()
  (interactive)
  (when (and b0h-saved-visible-window-attributes)
    (mapc (lambda (attrs)
            (with-selected-window (nth 0 attrs)
              (b0h-set-window-start-by-line (selected-window) (nth 3 attrs))
              (goto-char (point-min))
              (ignore-errors (forward-line (nth 1 attrs)))
              (ignore-errors (forward-char (nth 2 attrs)))
              (if (/= (nth 1 attrs) (1- (line-number-at-pos)))
                  (progn
                    (goto-char (point-min))
                    (ignore-errors (forward-line (nth 1 attrs)))
                    (move-end-of-line nil)))))
          b0h-saved-visible-window-attributes)))
(defface b0h-hi-yellow-1 '((t (:background "#C7C797"))) "Face for b0h-highlights.")
(defface b0h-hi-green-1 '((t (:background "#9BC797"))) "Face for b0h-highlights.")
(defface b0h-hi-aquamarine-1 '((t (:background "#97C7C7"))) "Face for b0h-highlights.")
(defface b0h-hi-blue-1 '((t (:background "#A8A7D6"))) "Face for b0h-highlights.")
(defface b0h-hi-pink-1 '((t (:background "#D6A7D1"))) "Face for b0h-highlights.")
(defface b0h-hi-salmon-1 '((t (:background "#D6A7A7"))) "Face for b0h-highlights.")
(defconst b0h-highlight-faces '(hi-yellow hi-green hi-aquamarine hi-blue hi-pink hi-salmon b0h-hi-yellow-1 b0h-hi-green-1 b0h-hi-aquamarine-1 b0h-hi-blue-1 b0h-hi-pink-1 b0h-hi-salmon-1))
(defun b0h-highlights-initialize ()
  (make-local-variable 'b0h-highlights)
  (when (not (boundp 'b0h-highlights))
    (setq b0h-highlights (make-hash-table :test 'equal)))
  (make-local-variable 'b0h-highlight-index)
  (when (not (boundp 'b0h-highlight-index))
    (setq b0h-highlight-index 0)))
(defun b0h-pop-next-highlight-face ()
  (let ((ret (nth b0h-highlight-index b0h-highlight-faces)))
    (setq b0h-highlight-index (1+ b0h-highlight-index))
    (when (>= b0h-highlight-index (length b0h-highlight-faces))
      (setq b0h-highlight-index 0))
    ret))
(defun b0h-toggle-highlight-at-point ()
  (interactive)
  (b0h-highlights-initialize)
  (save-excursion
    (let ((case-fold-search nil))
      (when (symbol-at-point)
        (let ((sym (concat "\\_<" (symbol-name (symbol-at-point)) "\\_>")))
          (if (gethash sym b0h-highlights)
              (progn
                (remhash sym b0h-highlights)
                (unhighlight-regexp sym))
            (progn
              (puthash sym t b0h-highlights)
              (highlight-regexp sym (b0h-pop-next-highlight-face)))))))))
(defun b0h-clear-all-highlights ()
  (interactive)
  (b0h-highlights-initialize)
  (maphash (lambda (symbol-regexp unused)
             (unhighlight-regexp symbol-regexp))
           b0h-highlights)
  (clrhash b0h-highlights))
(global-set-key (kbd "C-t") 'b0h-toggle-highlight-at-point)
(global-set-key (kbd "M-t") 'b0h-clear-all-highlights)
(global-set-key (kbd "C-v") 'b0h-scroll-down)
(global-set-key (kbd "M-v") 'b0h-scroll-up)
(defun b0h-autocomplete-get-symbols (prefix)
  (let ((excluded-point (point)))
    (save-excursion
      (goto-char (point-min))
      (let ((s (concat "\\_<" (regexp-quote prefix)))
            (ret (make-hash-table :test 'equal))
            (manual-continue (= (length prefix) 0)))
        (while (re-search-forward s nil t)
          (when (and (symbol-at-point) (/= excluded-point (point)))
            (puthash (symbol-name (symbol-at-point)) t ret))
          (when manual-continue
            (forward-char)))
        (hash-table-keys ret)))))
(defun b0h-autocomplete ()
  (interactive)
  (if (symbol-at-point)
      (progn
        (let* ((prefix (symbol-name (symbol-at-point)))
               (symbols (b0h-autocomplete-get-symbols prefix)))
          (when symbols
            (let* ((narrowed-prefix (try-completion prefix symbols))
                   (exact-completion (eq narrowed-prefix t))
                   (cur-point (point)))
              (when (not exact-completion)
                (re-search-backward "\\_<")
                (delete-region (point) cur-point)
                (insert narrowed-prefix)
                (when (> (length symbols) 1)
                  (let ((result
                         (if exact-completion
                             prefix
                           (completing-read "Autocomplete: " symbols nil t narrowed-prefix t)))
                        (cur-point (point)))
                    (re-search-backward "\\_<")
                    (delete-region (point) cur-point)
                    (insert result))))))))
    (let* ((symbols (b0h-autocomplete-get-symbols ""))
           (result (completing-read "Autocomplete: " symbols nil t nil t)))
      (insert result))))
(global-set-key [?\H-t] 'b0h-autocomplete)
(define-key key-translation-map (kbd "TAB") [?\H-t])
(define-key key-translation-map (kbd "C-z") (kbd "TAB"))
(add-hook 'minibuffer-setup-hook
          (lambda ()
            (define-key key-translation-map (kbd "TAB") (kbd "TAB"))))
(add-hook 'minibuffer-exit-hook
          (lambda ()
            (define-key key-translation-map (kbd "TAB") [?\H-t])))
(eval-after-load "shell" '(progn
                            (define-key shell-mode-map (kbd "TAB") 'dabbrev-completion)
                            (define-key shell-mode-map [?\H-t] 'completion-at-point)))
(setq isearch-lazy-count t)
(fido-mode 1)
(fido-vertical-mode 1)
(set-background-color "#FFFFD7")
(blink-cursor-mode 0)
(global-hl-line-mode 1)
(set-face-background hl-line-face "#F3F3CC")
(global-set-key (kbd "C-å") 'global-hl-line-mode)
(global-set-key (kbd "M-o") 'other-window)
(setq column-number-mode t)
(setq select-enable-clipboard nil)
(global-set-key (kbd "M-å") 'clipboard-kill-region)
(global-set-key (kbd "M-ä") 'clipboard-kill-ring-save)
(global-set-key (kbd "M-ö") 'clipboard-yank)
(defun b0h-isearch-clipboard-yank ()
  (interactive)
  (let ((str ""))
    (with-temp-buffer
      (clipboard-yank)
      (setq str (buffer-string)))
    (isearch-yank-string str)))
(define-key isearch-mode-map (kbd "M-ö") 'b0h-isearch-clipboard-yank)
(global-set-key (kbd "C-ä") 'undo-only)
(global-set-key (kbd "C-ö") 'undo-redo)
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
(defun b0h-buffer-get-symbols ()
  (save-excursion
    (goto-char (point-min))
    (let ((ret (make-hash-table :test 'equal)))
      (while (re-search-forward "\\_<" nil t)
        (when (symbol-at-point)
          (puthash (symbol-name (symbol-at-point)) t ret))
        (forward-char))
      (hash-table-keys ret))))
(setq b0h-isearch-forward-symbol-history nil)
(defun b0h-isearch-forward-symbol (arg)
  (interactive "P")
  (let ((sym (completing-read "Symbol: " (b0h-buffer-get-symbols) nil t nil 'b0h-isearch-forward-symbol-history))
        (case-fold-search nil))
    (when (integerp arg)
      (setq b0h-isearch-indent-steps arg))
    (isearch-mode t t nil nil (if (integerp arg) 'b0h-isearch-indented-symbol-regexp 'isearch-symbol-regexp))
    (beginning-of-buffer)
    (with-isearch-suspended
     (setq isearch-new-string sym))
    (recenter-top-bottom)))
(defun b0h-isearch-forward-symbol-at-point (arg)
  (interactive "P")
  (let ((case-fold-search nil))
    (isearch-forward-symbol-at-point)
    (when (integerp arg)
      (ignore-errors
        (setq b0h-isearch-indent-steps arg
              isearch-regexp-function 'b0h-isearch-indented-symbol-regexp)
        (beginning-of-buffer)
        (isearch-repeat-forward)
        (recenter-top-bottom)))))
(defun b0h-isearch-mode-search-for-symbol-at-point (arg)
  (interactive "P")
  (when (symbol-at-point)
    (setq isearch-string (symbol-name (symbol-at-point)))
    (if (integerp arg)
        (ignore-errors
          (setq b0h-isearch-indent-steps arg
                isearch-regexp-function 'b0h-isearch-indented-symbol-regexp
                isearch-regexp nil
                isearch-case-fold-search nil
                isearch-message isearch-string)
          (beginning-of-buffer)
          (isearch-repeat-forward)
          (recenter-top-bottom))
      (setq isearch-regexp-function 'isearch-symbol-regexp
            isearch-regexp nil
            isearch-case-fold-search nil
            isearch-message isearch-string)
      (isearch-update))))
(keyboard-translate ?\C-m ?\H-m)
(global-set-key [?\H-m] 'b0h-isearch-forward-symbol-at-point)
(global-set-key (kbd "C-x H-m") 'b0h-isearch-forward-symbol)
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
(defconst b0h-jump-mode-input-chars (list
                                     "g" "x" "n" "h" "t" "y" "b" "z" "u" "r"
                                     "q" "p" "c" "v" "m" "a" "s" "l" "d"
                                     "k" "w" "o" "e" "i" "f" "j"))
(defvar b0h-jump-mode-search-string nil)
(defvar b0h-jump-mode-matches nil)
(defvar b0h-jump-mode-overlays nil)
(defvar b0h-jump-mode-window-attributes nil)
(defvar b0h-jump-mode-narrowing nil)
(defun b0h-jump-mode-initialize ()
  (setq b0h-jump-mode-search-string ""
        b0h-jump-mode-matches (make-hash-table :test 'equal)
        b0h-jump-mode-overlays nil
        b0h-jump-mode-window-attributes (mapcar (lambda (w)
                                                  (with-selected-window w
                                                    (list w (window-start) (window-end))))
                                                (window-list))
        b0h-jump-mode-narrowing nil)
  (add-hook 'pre-command-hook 'b0h-jump-mode-pre-command-hook))
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
    (mapc (lambda (attrs)
            (with-selected-window (nth 0 attrs)
              (save-excursion
                (let ((start (nth 1 attrs))
                      (end (nth 2 attrs)))
                  (goto-char start)
                  (while (< (point) end)
                    (when (looking-at (regexp-quote b0h-jump-mode-search-string))
                      (save-excursion
                        (forward-char (length b0h-jump-mode-search-string))
                        (when (char-after)
                          (puthash (downcase (make-string 1 (char-after))) nil table))))
                    (b0h-jump-mode-forward-char))))))
          b0h-jump-mode-window-attributes)
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
(defun b0h-jump-mode-push-match (match-input position window)
  (let* ((first (nth 0 match-input))
         (second (nth 1 match-input))
         (first-table
          (if (gethash first b0h-jump-mode-matches)
              (gethash first b0h-jump-mode-matches)
            (puthash first (make-hash-table :test 'equal) b0h-jump-mode-matches)
            (gethash first b0h-jump-mode-matches))))
    (puthash second (list position window) first-table)))
(defun b0h-jump-mode-populate-overlays-and-matches (match-inputs)
  (mapc (lambda (attrs)
          (with-selected-window (nth 0 attrs)
            (save-excursion
              (let ((start (nth 1 attrs))
                    (end (nth 2 attrs)))
                (goto-char start)
                (while (< (point) end)
                  (when (looking-at (regexp-quote b0h-jump-mode-search-string))
                    (let ((match-input (pop match-inputs)))
                      (when match-input
                        (let* ((overlay-start-pos (point))
                               (overlay-end-pos (+ (point) 2))
                               (overlay-partial-end-pos (1+ (point)))
                               (complete-overlay (= (line-number-at-pos overlay-start-pos) (line-number-at-pos overlay-end-pos)))
                               (overlay (make-overlay overlay-start-pos (if complete-overlay overlay-end-pos overlay-partial-end-pos))))
                          (b0h-jump-mode-push-match match-input (point) (nth 0 attrs))
                          (let ((match-input-string (concat (nth 0 match-input) (nth 1 match-input)))
                                (partial-match-input-string (nth 0 match-input)))
                            (overlay-put overlay 'display (if complete-overlay match-input-string partial-match-input-string))
                            (overlay-put overlay 'face '((t (:background "#9CFFAF") (:foreground "#000000"))))
                            (overlay-put overlay 'b0h-second-char (nth 1 match-input))
                            (push overlay b0h-jump-mode-overlays))))))
                  (b0h-jump-mode-forward-char))))))
        b0h-jump-mode-window-attributes))
(defun b0h-jump-mode-clear-overlays ()
  (while b0h-jump-mode-overlays
    (let ((overlay (pop b0h-jump-mode-overlays)))
      (delete-overlay overlay))))
(defun b0h-jump-mode-clear-matches ()
  (clrhash b0h-jump-mode-matches))
(defun b0h-jump-mode-finish ()
  (remove-hook 'pre-command-hook 'b0h-jump-mode-pre-command-hook)
  (b0h-jump-mode-clear-overlays)
  (b0h-jump-mode-clear-matches)
  (b0h-jump-mode 0))
(defun b0h-jump-mode-narrow-overlays (input)
  (let ((iter (car b0h-jump-mode-overlays))
        (rest (cdr b0h-jump-mode-overlays)))
    (while iter
      (let ((str (overlay-get iter 'display))
            (second-char (overlay-get iter 'b0h-second-char)))
        (if (string-prefix-p input str t)
            (if (= (length str) 1)
                (overlay-put iter 'display second-char)
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
          (b0h-jump-mode-finish)
          (select-window (nth 1 match-entry))
          (goto-char (nth 0 match-entry)))
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
(defun b0h-jump-mode-pre-command-hook ()
  (let ((key (this-single-command-keys)))
    (cond
     ((commandp (lookup-key b0h-jump-mode-map key)))
     (t (b0h-jump-mode-finish)))))
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
(setq sentence-end-double-space nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'set-goal-column 'disabled nil)
(setq dired-listing-switches "-lah")
(setq b0h-file-search-pattern-argument-history nil)
(setq b0h-file-search-str-argument-history nil)
(setq b0h-file-search-regexp-argument-history nil)
(defun b0h-do-file-search-process-file (dir file str search-fn result-buf)
  (let ((prev-linum 0))
    (while (funcall search-fn str nil t)
      (let ((linum (line-number-at-pos))
            (line (thing-at-point 'line t)))
        (when (/= linum prev-linum)
          (with-current-buffer result-buf
            (insert (format "%s:%s:%s" (string-remove-prefix dir file) linum line))))
        (setq prev-linum linum)))))
(defun b0h-do-file-search (dir pattern str case-insensitive enable-regexp)
  (let ((case-fold-search case-insensitive)
        (search-fn (if enable-regexp 're-search-forward 'search-forward))
        (syntax (syntax-table))
        (result-buf (get-buffer-create "*File Search*"))
        (files (directory-files-recursively dir pattern)))
    (with-current-buffer result-buf
      (read-only-mode 0)
      (erase-buffer)
      (cd dir))
    (dolist (file files)
      ;; reference: https://emacs.stackexchange.com/a/2898
      (let ((file-buffer (get-file-buffer file)))
        (if file-buffer
            (with-current-buffer file-buffer
              (save-excursion
                (goto-char (point-min))
                (b0h-do-file-search-process-file dir file str search-fn result-buf)))
          (with-temp-buffer
            (insert-file-contents file)
            (set-syntax-table syntax)
            (b0h-do-file-search-process-file dir file str search-fn result-buf)))))
    (with-current-buffer result-buf
      (grep-mode)) ;; TODO: custom mode
    (display-buffer result-buf)
    (with-selected-window (get-buffer-window result-buf)
      (goto-char (point-min)))))
(defun b0h-file-search-read-directory-argument ()
  (read-directory-name "Search in directory: "))
(defun b0h-file-search-read-pattern-argument ()
  (read-string "With file regexp: "
               (let* ((file (buffer-file-name))
                      (ext (if file (file-name-extension file) nil)))
                 (if ext
                     (concat "\\." ext "$")
                   ""))
               'b0h-file-search-pattern-argument-history))
(defun b0h-file-search-arguments (case-insensitive enable-regexp)
  (let* ((title (concat "Search " (if enable-regexp "regexp" "string") (if case-insensitive "" " (case-sensitive)")))
         (dir-arg (b0h-file-search-read-directory-argument))
         (pattern-arg (b0h-file-search-read-pattern-argument))
         (str-history (if enable-regexp 'b0h-file-search-regexp-argument-history 'b0h-file-search-str-argument-history))
         (str-arg (let ((result (read-string (concat title ": ") nil str-history)))
                    (while (= (length result) 0)
                      (setq result (read-string (concat title " (please type a string): "))))
                    result)))
    (list dir-arg pattern-arg str-arg)))
(defun b0h-file-search-isearch-arguments ()
  (let ((ret nil))
    (with-isearch-suspended
     (setq ret (list (b0h-file-search-read-directory-argument)
                     (b0h-file-search-read-pattern-argument)
                     (cond
                      ((functionp isearch-regexp-function)
                       (funcall isearch-regexp-function isearch-string))
                      (isearch-regexp-function (word-search-regexp isearch-string))
                      (t isearch-string)))))
    ret))
(defun b0h-file-search (dir pattern str)
  (interactive (b0h-file-search-arguments t nil))
  (if (not (integerp current-prefix-arg))
      (b0h-do-file-search dir pattern str t nil)
    (let ((b0h-isearch-indent-steps current-prefix-arg))
      (b0h-do-file-search dir pattern (b0h-isearch-indented-line-regexp str) t t))))
(defun b0h-file-search-case-sensitive (dir pattern str)
  (interactive (b0h-file-search-arguments nil nil))
  (if (not (integerp current-prefix-arg))
      (b0h-do-file-search dir pattern str nil nil)
    (let ((b0h-isearch-indent-steps current-prefix-arg))
      (b0h-do-file-search dir pattern (b0h-isearch-indented-line-regexp str) nil t))))
(defun b0h-file-search-regexp (dir pattern str)
  (interactive (b0h-file-search-arguments t t))
  (b0h-do-file-search dir pattern str t t))
(defun b0h-file-search-regexp-case-sensitive (dir pattern str)
  (interactive (b0h-file-search-arguments nil t))
  (b0h-do-file-search dir pattern str nil t))
(defun b0h-isearch-file-search (dir pattern str)
  (interactive (b0h-file-search-isearch-arguments))
  (b0h-do-file-search dir pattern str isearch-case-fold-search (or isearch-regexp-function isearch-regexp)))
(defun b0h-isearch-file-search-case-sensitive (dir pattern str)
  (interactive (b0h-file-search-isearch-arguments))
  (b0h-do-file-search dir pattern str nil (or isearch-regexp-function isearch-regexp)))
(defun b0h-isearch-file-search-regexp (dir pattern str)
  (interactive (b0h-file-search-isearch-arguments))
  (b0h-do-file-search dir pattern str isearch-case-fold-search t))
(defun b0h-isearch-file-search-regexp-case-sensitive (dir pattern str)
  (interactive (b0h-file-search-isearch-arguments))
  (b0h-do-file-search dir pattern str nil t))
(global-set-key (kbd "C-c o") 'b0h-file-search)
(global-set-key (kbd "C-c O") 'b0h-file-search-case-sensitive)
(global-set-key (kbd "C-c l") 'b0h-file-search-regexp)
(global-set-key (kbd "C-c L") 'b0h-file-search-regexp-case-sensitive)
(define-key isearch-mode-map (kbd "C-c o") 'b0h-isearch-file-search)
(define-key isearch-mode-map (kbd "C-c O") 'b0h-isearch-file-search-case-sensitive)
(define-key isearch-mode-map (kbd "C-c l") 'b0h-isearch-file-search-regexp)
(define-key isearch-mode-map (kbd "C-c L") 'b0h-isearch-file-search-regexp-case-sensitive)
(defun b0h-isearch-delete-word ()
  (interactive)
  (let ((loop t))
    (while (and loop (> (length isearch-string) 0))
      (let* ((cur-char (substring isearch-string -1))
             (is-alnum (string-match-p "[[:alnum:]]" cur-char)))
        (isearch-delete-char)
        (when (> (length isearch-string) 0)
          (let* ((next-char (substring isearch-string -1))
                 (next-is-alnum (string-match-p "[[:alnum:]]" next-char)))
            (when (and (not next-is-alnum) is-alnum)
              (setq loop nil))))))))
(define-key isearch-mode-map (kbd "C-<backspace>") 'b0h-isearch-delete-word)
(define-key isearch-mode-map (kbd "M-DEL") 'b0h-isearch-delete-word)
;; reference: https://old.reddit.com/r/emacs/comments/rcfggm/is_there_an_indented_version_of_openline/
(defun b0h-open-line-and-indent (n)
  (interactive "*p")
  (let ((eol (copy-marker (line-end-position))))
    (open-line n)
    (indent-region (point) eol)
    (set-marker eol nil)))
(global-set-key (kbd "C-o") 'b0h-open-line-and-indent)
(setq create-lockfiles nil)
