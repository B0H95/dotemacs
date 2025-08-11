(deftheme b0h-light "B0H Light Theme")

(let ((b0h-light-theme-text-color "#000000")
      (b0h-light-theme-background-color "#FFFFD7")
      (b0h-light-theme-line-highlight-color "#F3F3CC")
      (b0h-light-theme-cursor-color "#F00279")
      (b0h-light-theme-keyword-color "#0022C9")
      (b0h-light-theme-string-color "#6E0000")
      (b0h-light-theme-comment-color "#015400")
      (b0h-light-theme-region-color "#FFD787")
      (b0h-light-theme-section-color "#9700C9")
      (b0h-light-theme-search-highlight-color "#ABFFFF")
      (b0h-light-theme-mode-line-inactive-color "#D7FFFF")
      (b0h-light-theme-mode-line-inactive-border-color "#237575")
      (b0h-light-theme-mode-line-active-color "#D7AFFF")
      (b0h-light-theme-mode-line-active-border-color "#66329C")
      (b0h-light-theme-mode-line-border-width 1)
      (b0h-light-theme-fringe-color "#F2F2D3")
      (b0h-light-theme-dired-directory-color "#007A00"))
  (custom-theme-set-faces
   'b0h-light
   `(cursor ((t (:background ,b0h-light-theme-cursor-color))))
   `(default ((t (:background ,b0h-light-theme-background-color :foreground ,b0h-light-theme-text-color))))
   `(hl-line ((t (:background ,b0h-light-theme-line-highlight-color))))
   `(font-lock-builtin-face ((t (:foreground ,b0h-light-theme-keyword-color))))
   `(font-lock-comment-delimiter-face ((t (:foreground ,b0h-light-theme-comment-color))))
   `(font-lock-comment-face ((t (:foreground ,b0h-light-theme-comment-color))))
   `(font-lock-constant-face ((t (:foreground ,b0h-light-theme-text-color))))
   `(font-lock-doc-face ((t (:foreground ,b0h-light-theme-comment-color))))
   `(font-lock-doc-markup-face ((t (:foreground ,b0h-light-theme-comment-color))))
   `(font-lock-function-name-face ((t (:foreground ,b0h-light-theme-text-color))))
   `(font-lock-keyword-face ((t (:foreground ,b0h-light-theme-keyword-color))))
   `(font-lock-negation-char-face ((t (:foreground ,b0h-light-theme-text-color))))
   `(font-lock-preprocessor-face ((t (:foreground ,b0h-light-theme-keyword-color))))
   `(font-lock-string-face ((t (:foreground ,b0h-light-theme-string-color))))
   `(font-lock-type-face ((t (:foreground ,b0h-light-theme-text-color))))
   `(font-lock-variable-name-face ((t (:foreground ,b0h-light-theme-text-color))))
   `(region ((t (:background ,b0h-light-theme-region-color))))
   `(isearch ((t (:background ,b0h-light-theme-mode-line-active-color))))
   `(lazy-highlight ((t (:background ,b0h-light-theme-search-highlight-color))))
   `(mode-line-inactive ((t (:inherit
                             mode-line
                             :background
                             ,b0h-light-theme-mode-line-inactive-color
                             :box (:line-width
                                   ,b0h-light-theme-mode-line-border-width
                                   :color
                                   ,b0h-light-theme-mode-line-inactive-border-color)))))
   `(mode-line-active ((t (:inherit
                           mode-line
                           :background
                           ,b0h-light-theme-mode-line-active-color
                           :box (:line-width
                                 ,b0h-light-theme-mode-line-border-width
                                 :color
                                 ,b0h-light-theme-mode-line-active-border-color)))))
   `(mode-line ((t (:background
                    ,b0h-light-theme-mode-line-active-color
                    :box (:line-width
                          ,b0h-light-theme-mode-line-border-width
                          :color
                          ,b0h-light-theme-mode-line-active-border-color)))))
   `(mode-line-buffer-id ((t (:background
                              unspecified
                              :foreground
                              ,b0h-light-theme-text-color
                              :bold
                              nil))))
   `(fringe ((t (:background ,b0h-light-theme-fringe-color))))
   `(dired-directory ((t (:foreground ,b0h-light-theme-dired-directory-color))))
   `(org-level-1 ((t (:foreground ,b0h-light-theme-section-color))))
   `(org-level-2 ((t (:foreground ,b0h-light-theme-section-color))))
   `(org-level-3 ((t (:foreground ,b0h-light-theme-section-color))))
   `(org-level-4 ((t (:foreground ,b0h-light-theme-section-color))))
   `(org-level-5 ((t (:foreground ,b0h-light-theme-section-color))))
   `(org-level-6 ((t (:foreground ,b0h-light-theme-section-color))))
   `(org-level-7 ((t (:foreground ,b0h-light-theme-section-color))))
   `(org-level-8 ((t (:foreground ,b0h-light-theme-section-color))))
   `(eshell-prompt ((t (:foreground ,b0h-light-theme-section-color))))))

(provide-theme 'b0h-light)
