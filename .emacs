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
(defun b0h-search-filesystem ()
  (interactive)
  (let* ((dir (string-replace "/./" "/" (read-directory-name "Find files in directory: ")))
         (files (directory-files-recursively dir "")))
    (find-file (completing-read "Select file " files nil t nil t))))
(global-set-key (kbd "C-c p") 'b0h-search-filesystem)
(global-set-key (kbd "C-c P") 'find-lisp-find-dired)
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
(defface b0h-hi-yellow-1 '((t (:foreground "#000000" :background "#C7C797"))) "Face for b0h-highlights.")
(defface b0h-hi-green-1 '((t (:foreground "#000000" :background "#9BC797"))) "Face for b0h-highlights.")
(defface b0h-hi-aquamarine-1 '((t (:foreground "#000000" :background "#97C7C7"))) "Face for b0h-highlights.")
(defface b0h-hi-blue-1 '((t (:foreground "#000000" :background "#A8A7D6"))) "Face for b0h-highlights.")
(defface b0h-hi-pink-1 '((t (:foreground "#000000" :background "#D6A7D1"))) "Face for b0h-highlights.")
(defface b0h-hi-salmon-1 '((t (:foreground "#000000" :background "#D6A7A7"))) "Face for b0h-highlights.")
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
;; copy-pasted from hi-lock-unface-buffer (M-s h u), have no idea what this does
(defun b0h-get-all-hi-lock-patterns ()
  (mapcar (lambda (pattern)
            (or (car (rassq pattern hi-lock-interactive-lighters))
                (car pattern)))
          hi-lock-interactive-patterns))
(defun b0h-isearch-highlight (pattern)
  (interactive (list (completing-read "Highlight to search: " (b0h-get-all-hi-lock-patterns) nil t nil t)))
  (let ((case-fold-search nil))
    (isearch-mode t t)
    (with-isearch-suspended
     (setq isearch-new-string pattern))))
(defun b0h-clear-highlight (sym)
  (interactive (list (completing-read "Highlight to delete: " (hash-table-keys b0h-highlights) nil t nil t)))
  (b0h-highlights-initialize)
  (remhash sym b0h-highlights)
  (unhighlight-regexp sym))
(global-set-key (kbd "C-t") 'b0h-toggle-highlight-at-point)
(global-set-key (kbd "M-t") 'b0h-clear-all-highlights)
(global-set-key (kbd "C-x C-t") 'b0h-isearch-highlight)
(global-set-key (kbd "C-M-t") 'b0h-clear-highlight)
(global-set-key (kbd "C-v") 'b0h-scroll-down)
(global-set-key (kbd "M-v") 'b0h-scroll-up)
(defun b0h-autocomplete-get-symbols (prefix)
  (let ((excluded-point (point))
        (case-fold-search nil))
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
(defun b0h-autocomplete-prefix ()
  (save-excursion
    (let ((p (point)))
      (re-search-backward "\\_<")
      (buffer-substring-no-properties (point) p))))
(defun b0h-autocomplete ()
  (interactive)
  (if (and (symbol-at-point) (not (looking-at "\\_<")))
      (progn
        (let* ((prefix (b0h-autocomplete-prefix))
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
(setq isearch-lazy-count t)
(fido-mode 1)
(fido-vertical-mode 1)
(blink-cursor-mode 0)
(global-hl-line-mode 1)
(global-set-key (kbd "M-o") 'other-window)
(setq column-number-mode t)
(setq select-enable-clipboard nil)
(setq select-enable-primary nil)
(setq interprogram-cut-function nil) ;; gui-select-text
(setq interprogram-paste-function nil) ;; gui-selection-value
(setq b0h-locally-last-copied-text nil)
(defun b0h-copy ()
  (interactive)
  (if mark-active
      (let ((text (buffer-substring-no-properties (region-beginning) (region-end))))
        (gui-backend-set-selection 'CLIPBOARD text)
        (setq b0h-locally-last-copied-text text)
        (deactivate-mark))
    (back-to-indentation)
    (delete-region (point) (pos-eol))))
(defun b0h-cut ()
  (interactive)
  (if mark-active
      (let ((text (buffer-substring-no-properties (region-beginning) (region-end))))
        (gui-backend-set-selection 'CLIPBOARD text)
        (setq b0h-locally-last-copied-text text)
        (delete-region (region-beginning) (region-end))
        (deactivate-mark))
    (kill-whole-line)))
(defun b0h-paste ()
  (interactive)
  (let ((text (gui-backend-get-selection 'CLIPBOARD 'STRING))
        (start-point (point)))
    (if text
        (progn
          (insert text)
          (push-mark start-point))
      (when b0h-locally-last-copied-text
        (insert b0h-locally-last-copied-text)
        (push-mark start-point)))))
(global-set-key (kbd "M-w") 'b0h-copy)
(global-set-key (kbd "C-y") 'b0h-paste)
(global-set-key (kbd "C-w") 'b0h-cut)
(global-set-key (kbd "C-M-y") 'yank-pop)
(global-set-key (kbd "M-y") 'yank)
(defun b0h-gui-select-text-wrapper (text)
  (gui-select-text text)
  (setq b0h-locally-last-copied-text text))
(defun b0h-dired-copy-filename-as-kill-wrapper (fun &rest args)
  (let ((select-enable-clipboard t)
        (interprogram-cut-function #'b0h-gui-select-text-wrapper))
    (apply fun args)))
(advice-add 'dired-copy-filename-as-kill :around #'b0h-dired-copy-filename-as-kill-wrapper)
(defun b0h-isearch-clipboard-paste ()
  (interactive)
  (let* ((clipboard-text (gui-backend-get-selection 'CLIPBOARD 'STRING))
         (text (if clipboard-text clipboard-text b0h-locally-last-copied-text)))
    (when text
      (isearch-yank-string text))))
(define-key isearch-mode-map (kbd "C-y") 'b0h-isearch-clipboard-paste)
(defun b0h-get-file-path ()
  (if (buffer-file-name)
      (buffer-file-name)
    default-directory))
(defun b0h-get-file-name ()
  (let ((path (b0h-get-file-path)))
    (when path
      (setq path (string-trim-right path "/"))
      (setq path (string-split path "/"))
      (car (last path)))))
(defun b0h-copy-file-path ()
  (interactive)
  (let ((path (b0h-get-file-path)))
    (when path
      (gui-backend-set-selection 'CLIPBOARD path)
      (setq b0h-locally-last-copied-text path))))
(defun b0h-copy-file-name ()
  (interactive)
  (let ((name (b0h-get-file-name)))
    (when name
      (gui-backend-set-selection 'CLIPBOARD name)
      (setq b0h-locally-last-copied-text name))))
(global-set-key (kbd "C-x C-v") 'b0h-copy-file-path)
(global-set-key (kbd "C-x C-r") 'b0h-copy-file-name)
(global-set-key (kbd "C-_") 'undo-only)
(setq confirm-kill-emacs #'yes-or-no-p)
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
          (setq line (string-to-number (buffer-substring-no-properties (match-beginning 0) (match-end 0))))))
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
(global-superword-mode 1)
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
(defvar b0h-jump-mode-previous-starting-point nil)
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
(defun b0h-jump-mode-process-input (input)
  (let ((vacant-letter-table (make-hash-table :test 'equal))
        (window-jump-targets nil))
    (dolist (x b0h-jump-mode-input-chars)
      (puthash x t vacant-letter-table))
    (dolist (attrs b0h-jump-mode-window-attributes)
      (let ((window (nth 0 attrs)))
        (with-selected-window window
          (save-excursion
            (let ((start (nth 1 attrs))
                  (end (nth 2 attrs))
                  (jump-targets nil))
              (goto-char start)
              (while (< (point) end)
                (when (looking-at (regexp-quote input))
                  (push (point) jump-targets)
                  (save-excursion
                    (forward-char (length input))
                    (when (char-after)
                      (puthash (downcase (make-string 1 (char-after))) nil vacant-letter-table))))
                (ignore-errors
                  (if (/= (point) (point-at-eol))
                      (forward-char)
                    (let ((prev-point (point)))
                      (next-line)
                      (when (<= (point) prev-point)
                        ;; some bug makes next-line not move point forward at all from time to time
                        (goto-char prev-point)
                        (forward-char)))
                    (let ((inhibit-field-text-motion t)) (beginning-of-line)))))
              (push (list window jump-targets) window-jump-targets))))))
    (let ((match-inputs nil))
      (maphash (lambda (k v)
                 (when v
                   (dolist (x b0h-jump-mode-input-chars)
                     (push (list k x) match-inputs))))
               vacant-letter-table)
      (dolist (window-jump-target window-jump-targets)
        (let ((window (nth 0 window-jump-target))
              (jump-targets (nth 1 window-jump-target)))
          (with-selected-window window
            (dolist (jump-target jump-targets)
              (let ((match-input (pop match-inputs)))
                (when match-input
                  (let* ((overlay-start-pos jump-target)
                         (overlay-end-pos (+ jump-target 2))
                         (overlay-partial-end-pos (1+ jump-target))
                         (complete-overlay
                          (if (> overlay-end-pos (1+ (buffer-size)))
                              nil
                            (= (line-number-at-pos overlay-start-pos) (line-number-at-pos overlay-end-pos))))
                         (overlay (make-overlay overlay-start-pos (if complete-overlay overlay-end-pos overlay-partial-end-pos))))
                    (let* ((first (nth 0 match-input))
                           (second (nth 1 match-input))
                           (first-table
                            (if (gethash first b0h-jump-mode-matches)
                                (gethash first b0h-jump-mode-matches)
                              (puthash first (make-hash-table :test 'equal) b0h-jump-mode-matches)
                              (gethash first b0h-jump-mode-matches))))
                      (puthash second (list jump-target window) first-table))
                    (let ((match-input-string (concat (nth 0 match-input) (nth 1 match-input)))
                          (partial-match-input-string (nth 0 match-input)))
                      (overlay-put overlay 'display (if complete-overlay match-input-string partial-match-input-string))
                      (overlay-put overlay 'face '((t (:background "#9CFFAF") (:foreground "#000000"))))
                      (overlay-put overlay 'b0h-second-char (nth 1 match-input))
                      (overlay-put overlay 'priority 10000)
                      (push overlay b0h-jump-mode-overlays))))))))))))
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
(defun b0h-jump-mode-restart-search ()
  (message "Search string: %s" b0h-jump-mode-search-string)
  (b0h-jump-mode-clear-overlays)
  (b0h-jump-mode-clear-matches)
  (when (> (length b0h-jump-mode-search-string) 0)
    (b0h-jump-mode-process-input b0h-jump-mode-search-string)))
(defun b0h-jump-mode-backward-delete-char ()
  (interactive)
  (when (and (not b0h-jump-mode-narrowing) (> (length b0h-jump-mode-search-string) 0))
    (setq b0h-jump-mode-search-string (substring b0h-jump-mode-search-string 0 -1))
    (b0h-jump-mode-restart-search)))
(defun b0h-jump-mode-backward-delete-all ()
  (interactive)
  (when (and (not b0h-jump-mode-narrowing) (> (length b0h-jump-mode-search-string) 0))
    (setq b0h-jump-mode-search-string "")
    (b0h-jump-mode-restart-search)))
(defun b0h-jump-mode-self-insert ()
  (interactive)
  (let* ((input (downcase (make-string 1 last-command-event)))
         (match-entry (gethash input b0h-jump-mode-matches)))
    (if b0h-jump-mode-narrowing
        (when match-entry
          (b0h-jump-mode-finish)
          (setq b0h-jump-mode-previous-starting-point (list (copy-marker (point)) (get-buffer-window)))
          (select-window (nth 1 match-entry))
          (goto-char (nth 0 match-entry)))
      (if match-entry
          (progn
            (b0h-jump-mode-narrow-overlays input)
            (setq b0h-jump-mode-narrowing t)
            (setq b0h-jump-mode-matches match-entry))
        (setq b0h-jump-mode-search-string (concat b0h-jump-mode-search-string input))
        (b0h-jump-mode-restart-search)))))
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
    (define-key map (kbd "<backspace>") 'b0h-jump-mode-backward-delete-char)
    (define-key map (kbd "C-<backspace>") 'b0h-jump-mode-backward-delete-all)
    (define-key map (kbd "M-<backspace>") 'b0h-jump-mode-backward-delete-all)
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
(defun b0h-jump-mode-activate (pop-starting-position)
  (interactive "P")
  (if (not pop-starting-position)
      (b0h-jump-mode)
    (when b0h-jump-mode-previous-starting-point
      (let ((pos (nth 0 b0h-jump-mode-previous-starting-point))
            (win (nth 1 b0h-jump-mode-previous-starting-point)))
        (when (window-live-p win)
          (setq b0h-jump-mode-previous-starting-point (list (copy-marker (point)) (get-buffer-window)))
          (select-window win)
          (goto-char pos))))))
(keyboard-translate ?\C-i ?\H-i)
(global-set-key [?\H-i] 'b0h-jump-mode-activate)
(define-key isearch-mode-map (kbd "C-l") (lambda () (interactive) (recenter-top-bottom) (isearch-update)))
(fset 'yes-or-no-p 'y-or-n-p)
(setq dabbrev-case-fold-search nil)
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
  (when isearch-mode
    (isearch-exit))
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
    (switch-to-buffer result-buf)
    (goto-char (point-min))))
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
                      (setq result (read-string (concat title " (please type a string): ") nil str-history)))
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
(defun b0h-newline-before (should-indent)
  (interactive "*")
  (let ((inhibit-field-text-motion t))
    (move-beginning-of-line nil)
    (let ((electric-indent-mode nil))
      (newline))
    (forward-line -1)
    (when should-indent
      (indent-for-tab-command))))
(defun b0h-newline-after (should-indent)
  (interactive "*")
  (move-end-of-line nil)
  (let ((electric-indent-mode nil))
    (newline))
  (when should-indent
    (indent-for-tab-command)))
(global-set-key (kbd "C-o") (lambda () (interactive) (b0h-newline-before (not (eq major-mode 'fundamental-mode)))))
(global-set-key (kbd "C-j") (lambda () (interactive) (b0h-newline-after (not (eq major-mode 'fundamental-mode)))))
(eval-after-load "org" '(define-key org-mode-map (kbd "C-o") (lambda () (interactive) (b0h-newline-before nil))))
(eval-after-load "org" '(define-key org-mode-map (kbd "C-j") (lambda () (interactive) (b0h-newline-after nil))))
(define-key text-mode-map (kbd "C-o") (lambda () (interactive) (b0h-newline-before nil)))
(define-key text-mode-map (kbd "C-j") (lambda () (interactive) (b0h-newline-after nil)))
(setq create-lockfiles nil)
(global-set-key (kbd "C-M-<backspace>") 'backward-kill-sexp)
(setq cycle-spacing-actions '(delete-all-space just-one-space restore))
(setq require-final-newline t)
(set-charset-priority 'unicode)
(prefer-coding-system 'utf-8-unix)
(global-set-key (kbd "M-z") 'zap-up-to-char)
(setq b0h-project-list nil)
(defun b0h-project-add (dir)
  (interactive (list (read-directory-name "Choose a project directory to add: ")))
  (when (not (member dir b0h-project-list))
    (push dir b0h-project-list)))
(defun b0h-project-delete (dir)
  (interactive (list (completing-read "Choose a project directory to remove: " b0h-project-list nil t nil t)))
  (setq b0h-project-list (delete dir b0h-project-list)))
(defun b0h-project-try-project-list (dir)
  (let ((target nil))
    (dolist (p b0h-project-list)
      (when (file-in-directory-p dir p)
        (if target
            (when (file-in-directory-p p target)
              (setq target p))
          (setq target p))))
    (if target (list 'vc 'Git (string-replace "/./" "/" target)) nil)))
(eval-after-load "project" '(setq project-find-functions '(b0h-project-try-project-list))) ;; original value = (project-try-vc)
(setq hi-lock-use-overlays t)
(savehist-mode 1)
(add-to-list 'savehist-additional-variables 'b0h-project-list)
(add-hook 'dired-mode-hook (lambda () (dired-hide-details-mode 1)))
(defun b0h-shell ()
  (interactive)
  (shell (concat "*shell " (format-time-string "%Y-%m-%d %H:%M:%S") "*")))
(eval-after-load "sgml-mode" '(define-key html-mode-map (kbd "M-o") nil))
(eval-after-load "diff-mode" '(progn
                                (define-key diff-mode-map (kbd "M-o") nil)
                                (define-key diff-mode-map (kbd "C-o") 'diff-goto-source)))
(eval-after-load "ibuffer" '(define-key ibuffer-mode-map (kbd "M-o") nil))
(defun b0h-compile-goto-error ()
  (interactive)
  (let ((display-buffer-overriding-action
         '((display-buffer-reuse-window
            display-buffer-same-window)
           (inhibit-same-window . nil))))
    (call-interactively #'compile-goto-error)))
(eval-after-load "compile" '(define-key compilation-button-map (kbd "RET") 'b0h-compile-goto-error))
(eval-after-load "grep" '(define-key grep-mode-map (kbd "RET") 'b0h-compile-goto-error))
(eval-after-load "eglot" '(setq eglot-events-buffer-size 0
                                eglot-ignored-server-capabilities '(:documentHighlightProvider)))
(setq mode-line-percent-position nil)
(defun b0h-recenter-after-jump (&rest r)
  (recenter (/ (window-body-height) 8)))
(advice-add 'imenu :after #'b0h-recenter-after-jump)
(load "dired-x")
(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)
(setq gc-cons-threshold (* 1024 1024 256))
(setq read-process-output-max (* 1024 1024))
(setq package-native-compile t)
(defun b0h-mark-enclosing-group ()
  (interactive)
  (when (and mark-active (< (mark) (point)))
    (exchange-point-and-mark))
  (let ((start-point (point))
        (end-point (if mark-active (mark) (point))))
    (backward-up-list nil t t)
    (deactivate-mark)
    (mark-sexp)
    (when (or (/= 1 (- start-point (point)))
              (/= 1 (- (mark) end-point)))
      (forward-char)
      (exchange-point-and-mark)
      (backward-char)
      (exchange-point-and-mark))))
(global-set-key (kbd "C-x C-z") 'b0h-mark-enclosing-group)
(defun b0h-mark-lines ()
  (interactive)
  (if mark-active
      (progn
        (when (< (mark) (point))
          (exchange-point-and-mark))
        (beginning-of-line)
        (exchange-point-and-mark)
        (end-of-line))
    (push-mark)
    (beginning-of-line)
    (exchange-point-and-mark)
    (end-of-line)))
(global-set-key (kbd "C-z") 'b0h-mark-lines)
(defun b0h-visible-bell ()
  (invert-face 'mode-line)
  (run-with-timer 0.1 nil #'invert-face 'mode-line))
(setq ring-bell-function 'b0h-visible-bell)
(global-set-key (kbd "C-x C-b") 'ibuffer)
(defun b0h-set-window-width (width)
  (interactive "nSpecify a width: ")
  (let ((delta (- width (window-text-width (selected-window)))))
    (unless (zerop delta)
      (window-resize (selected-window) delta t))))
(defun b0h-set-window-height (height)
  (interactive "nSpecify a height: ")
  (let ((delta (- height (window-text-height (selected-window)))))
    (unless (zerop delta)
      (window-resize (selected-window) delta))))
(global-set-key (kbd "C-c w w") 'b0h-set-window-width)
(global-set-key (kbd "C-c w h") 'b0h-set-window-height)
(defun b0h-eshell-previous-matching-input () ;; inspired by eshell-previous-matching-input
  (interactive)
  (let ((input (completing-read "Search shell history: " (ring-elements eshell-history-ring) nil t nil t)))
    (delete-region eshell-last-output-end (point-max))
    (goto-char (point-max))
    (insert-and-inherit input)))
(eval-after-load "em-hist" '(define-key eshell-hist-mode-map (kbd "M-r") 'b0h-eshell-previous-matching-input))
(electric-pair-mode 1)
(defun b0h-mark-sexp ()
  (interactive)
  (if mark-active
      (progn
        (when (< (point) (mark))
          (exchange-point-and-mark))
        (ignore-errors (forward-sexp))
        (exchange-point-and-mark))
    (ignore-errors
      (forward-sexp)
      (backward-sexp))
    (mark-sexp)))
(defun b0h-mark-sexp-revert ()
  (interactive)
  (let ((min-point (point)))
    (when mark-active
      (when (< (mark) (point))
        (exchange-point-and-mark))
      (save-excursion
        (ignore-errors (forward-sexp))
        (setq min-point (point)))
      (exchange-point-and-mark)
      (ignore-errors
        (backward-sexp 2)
        (forward-sexp))
      (when (< (point) (mark))
        (goto-char min-point))
      (exchange-point-and-mark))))
(global-set-key (kbd "C-x C-d") 'fill-paragraph)
(global-set-key (kbd "M-q") 'b0h-mark-sexp)
(global-set-key (kbd "M-Q") 'b0h-mark-sexp-revert)
(eval-after-load "cc-mode"
  '(progn
     (define-key c-mode-map (kbd "C-x C-d") 'c-fill-paragraph)
     (define-key c-mode-map (kbd "M-q") 'b0h-mark-sexp)
     (define-key c-mode-map (kbd "M-Q") 'b0h-mark-sexp-revert)))
(eval-after-load "org"
  '(progn
     (define-key org-mode-map (kbd "C-x C-d") 'org-fill-paragraph)
     (define-key org-mode-map (kbd "M-q") 'b0h-mark-sexp)
     (define-key org-mode-map (kbd "M-Q") 'b0h-mark-sexp-revert)))
(define-key isearch-mode-map (kbd "C-g") 'isearch-cancel)
