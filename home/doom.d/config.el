;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Henry Fiantaca"
      user-mail-address "hfiantaca@gmail.com")

(set-frame-parameter (selected-frame) 'alpha '(95 . 80))
(add-to-list 'default-frame-alist '(alpha . (95 . 80)))

(setq doom-font (font-spec :family "Fira Code" :size 14)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 15)
      doom-unicode-font doom-font
      doom-big-font (font-spec :family "Fira Code" :size 18)

      doom-theme 'doom-palenight
      display-line-numbers-type t)

(setq org-directory "~/Documents/Org/"
      org-ellipsis "  ▼ ")

(after! org
  (require 'org-tempo)
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("nix" . "src nix"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (setq org-latex-listings 'minted

        org-latex-pdf-process
        '("latexmk -pdflatex='pdflatex -shell-escape -interaction nonstopmode' -pdf -bibtex -f %f")

        org-latex-default-packages-alist
        '(("AUTO" "inputenc" t
           ("pdflatex"))
          ("T1" "fontenc" t
           ("pdflatex"))
          ("" "graphicx" t)
          ("" "grffile" t)
          ("" "longtable" nil)
          ("" "wrapfig" nil)
          ("" "rotating" nil)
          ("normalem" "ulem" t)
          ("" "amsmath" t)
          ("" "textcomp" t)
          ("" "amssymb" t)
          ("" "caption" nil)
          ("x11names" "xcolor" nil)
          ("" "minted" nil)
          ("" "hyperref" nil))

        org-latex-hyperref-template
        "\\hypersetup{
  pdfauthor={%a},
  pdftitle={%t},
  pdfkeywords={%k},
  pdfsubject={%d},
  pdfcreator={%c},
  pdflang={%L},
  colorlinks=true,
  linktoc=all,
  colorlinks=true,
  urlcolor=DodgerBlue4,
  citecolor=PaleGreen1,
  linkcolor=black}
  "))

(use-package! mu4e
  ; forced loading by ommiting :defer, :hook, :commands, and :after
  :init
  (setq +mu4e-mu4e-path "~/.local/share/maildir/"
        send-mail-function #'smtpmail-send-it
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments '("--read-envelope-from")
        message-send-mail-function #'message-send-mail-with-sendmail
        +mu4e-gmail-accounts '(("hfiantaca@gmail.com" . "/gmail")
                               ("hfiantac@uncc.edu" . "/uncc"))
        mu4e-index-cleanup nil
        mu4e-index-lazy-check t
        mu4e-update-interval (* 60 60))

  (set-email-account! "gmail"
    '((user-mail-address      . "hfiantaca@gmail.com")
      (mu4e-compose-signature . "---\nHenry Fiantaca")

      (mu4e-sent-folder   . "/gmail/[Gmail]/Sent Mail")
      (mu4e-drafts-folder . "/gmail/[Gmail]/Drafts")
      (mu4e-trash-folder  . "/gmail/[Gmail]/Trash")
      (mu4e-refile-folder . "/gmail/[Gmail]/All Mail")

      (mu4e-sent-messages-behavior . delete)
      (mu4e-index-cleanup    . nil)
      (mu4e-index-lazy-check . t)

      (smtpmail-smtp-user    . "hfiantaca@gmail.com")
      (smtpmail-smtp-server  . "smtp.gmail.com")
      (smtpmail-smtp-service . 465))
    t)

  (set-email-account! "uncc"
    '((user-mail-address      . "hfiantac@uncc.edu")
      (mu4e-compose-signature . "---\nHenry Fiantaca\n801075065")

      (mu4e-sent-folder   . "/uncc/[Gmail]/Sent Mail")
      (mu4e-drafts-folder . "/uncc/[Gmail]/Drafts")
      (mu4e-trash-folder  . "/uncc/[Gmail]/Trash")
      (mu4e-refile-folder . "/uncc/[Gmail]/All Mail")

      (mu4e-sent-messages-behavior . delete)
      (mu4e-index-cleanup    . nil)
      (mu4e-index-lazy-check . t)

      (smtpmail-smtp-user    . "hfiantac@uncc.edu")
      (smtpmail-smtp-server  . "smtp.gmail.com")
      (smtpmail-smtp-service . 465)))
  :config
  ; start the mu4e backend
  (mu4e t))

;; nix-doom-emacs has not installed mu4e-alert, else it would be enabled here
