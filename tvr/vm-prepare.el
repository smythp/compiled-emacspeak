;;; Augment load path:
(augment-load-path "vm/lisp" "vm")
(defun make-local-hook (hook)
  "Make the hook HOOK local to the current buffer.
The return value is HOOK.

You never need to call this function now that `add-hook' does it for you
if its LOCAL argument is non-nil.

When a hook is local, its local and global values
work in concert: running the hook actually runs all the hook
functions listed in *either* the local value *or* the global value
of the hook variable.

This function works by making t a member of the buffer-local value,
which acts as a flag to run the hook functions in the default value as
well.  This works for all normal hooks, but does not work for most
non-normal hooks yet.  We will be changing the callers of non-normal
hooks so that they can handle localness; this has to be done one by
one.

This function does nothing if HOOK is already local in the current
buffer.

Do not use `make-local-variable' to make a hook variable buffer-local."
  (if (local-variable-p hook)
      nil
    (or (boundp hook) (set hook nil))
    (make-local-variable hook)
    (set hook (list t)))
  hook)
(load-library "vm-autoloads")

(global-set-key "\M-\C-v" 'vm-visit-folder)

(defadvice vm-check-emacs-version(around work-in-20-emacs pre act com) t)

(add-hook 'vm-quit-hook 'vm-expunge-folder)
(global-set-key "\C-xm" 'vm-mail)
(add-hook 'vm-mode-hook
          #'(lambda nil
             (and (featurep 'emacspeak)
                  (define-key vm-mode-map '[delete]
                    'dtk-toggle-punctuation-mode))))
 ;;}}}

(setq vm-postponed-messages (expand-file-name "~/Mail/crash"))

(setq vm-auto-displayed-mime-content-type-exceptions nil)
(defun vm-mime-display-internal-shr-text/html (start end layout)
  "Use shr to inline HTML mails in the VM presentation buffer."
    (shr-render-region start (1- end))
    (put-text-property start end
                       'text-rendered-by-shr t))

;;; has to be done indirectly
;;; Fake emacs-w3m, though we actually use shr

(setq vm-mime-text/html-handler'emacs-w3m  )
(defalias 'vm-mime-display-internal-emacs-w3m-text/html  'vm-mime-display-internal-shr-text/html)

(defun vm-chromium ()
  "Run Chromium on current link."
  (interactive)
  (let ((url (get-text-property (point) 'shr-url)))
    (unless url (error "No link here."))
    (browse-url-chromium url)))

(define-key vm-mode-map "C" 'vm-chromium)
