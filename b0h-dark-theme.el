(deftheme b0h-dark "B0H Dark Theme")

(setq b0h-dark-theme-text-color "#CDAA7D")
(setq b0h-dark-theme-background-color "#1A1A1A")
(setq b0h-dark-theme-line-highlight-color "#242424")
(setq b0h-dark-theme-cursor-color "#4A9E41")
(setq b0h-dark-theme-keyword-color "#9E7541")
(setq b0h-dark-theme-string-color "#A85E36")
(setq b0h-dark-theme-comment-color "#807466")
(setq b0h-dark-theme-region-color "#1A3817")
(setq b0h-dark-theme-search-highlight-color "#7AA4FF")
(setq b0h-dark-theme-mode-line-inactive-color "#3D5E20")
(setq b0h-dark-theme-mode-line-active-color "#6E2722")
(setq b0h-dark-theme-mode-line-inactive-text-color "#9CCB6C")
(setq b0h-dark-theme-mode-line-active-text-color "#D88A83")
(setq b0h-dark-theme-fringe-color "#202020")
(setq b0h-dark-theme-dired-directory-color "#559C4E")
(setq b0h-dark-theme-error-color "#FF0000")
(setq b0h-dark-theme-paren-match-background "turquoise")

(custom-theme-set-faces
 'b0h-dark
 `(cursor ((t (:background ,b0h-dark-theme-cursor-color))))
 `(default ((t (:background ,b0h-dark-theme-background-color :foreground ,b0h-dark-theme-text-color))))
 `(hl-line ((t (:background ,b0h-dark-theme-line-highlight-color))))
 `(font-lock-builtin-face ((t (:foreground ,b0h-dark-theme-keyword-color))))
 `(font-lock-comment-delimiter-face ((t (:foreground ,b0h-dark-theme-comment-color))))
 `(font-lock-comment-face ((t (:foreground ,b0h-dark-theme-comment-color))))
 `(font-lock-constant-face ((t (:foreground ,b0h-dark-theme-text-color))))
 `(font-lock-doc-face ((t (:foreground ,b0h-dark-theme-comment-color))))
 `(font-lock-doc-markup-face ((t (:foreground ,b0h-dark-theme-comment-color))))
 `(font-lock-function-name-face ((t (:foreground ,b0h-dark-theme-text-color))))
 `(font-lock-keyword-face ((t (:foreground ,b0h-dark-theme-keyword-color))))
 `(font-lock-negation-char-face ((t (:foreground ,b0h-dark-theme-text-color))))
 `(font-lock-preprocessor-face ((t (:foreground ,b0h-dark-theme-keyword-color))))
 `(font-lock-string-face ((t (:foreground ,b0h-dark-theme-string-color))))
 `(font-lock-type-face ((t (:foreground ,b0h-dark-theme-text-color))))
 `(font-lock-variable-name-face ((t (:foreground ,b0h-dark-theme-text-color))))
 `(region ((t (:background ,b0h-dark-theme-region-color))))
 `(lazy-highlight ((t (:background ,b0h-dark-theme-search-highlight-color :foreground ,b0h-dark-theme-background-color))))
 `(mode-line-inactive ((t (:inherit mode-line :background ,b0h-dark-theme-mode-line-inactive-color :foreground ,b0h-dark-theme-mode-line-inactive-text-color))))
 `(mode-line-active ((t (:inherit mode-line :background ,b0h-dark-theme-mode-line-active-color :foreground ,b0h-dark-theme-mode-line-active-text-color))))
 `(fringe ((t (:background ,b0h-dark-theme-fringe-color))))
 `(dired-directory ((t (:foreground ,b0h-dark-theme-dired-directory-color))))
 `(compilation-error ((t (:foreground ,b0h-dark-theme-error-color :weight bold))))
 `(show-paren-match ((t (:foreground ,b0h-dark-theme-background-color :background ,b0h-dark-theme-paren-match-background )))))

(provide-theme 'b0h-dark)