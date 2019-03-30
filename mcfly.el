;;; -*- lexical-binding: t; -*-

(defvar mcfly-commands
  '(query-replace-regexp
    flush-lines
    keep-lines))

(defun mcfly-back-to-present ()
  (remove-hook 'pre-command-hook 'mcfly-back-to-present t)
  (cond ((memq this-command '(minibuffer-complete-and-exit
                              exit-minibuffer))
         (ignore))
        ((equal (this-command-keys-vector) (kbd "M-p"))
         ;; repeat one time to get straight to the first history item
         (setq unread-command-events
               (append unread-command-events
                       (listify-key-sequence (kbd "M-p")))))
        ((not (= (point) (minibuffer-prompt-end)))
         (delete-region (point) (point-max)))
        (t
         (delete-region (minibuffer-prompt-end)
                        (point-max)))))

(defun mcfly-time-travel ()
  (when (memq this-command mcfly-commands)
    (let* ((kbd (kbd "M-n"))
           (cmd (key-binding kbd))
           (future (and cmd
                        (with-temp-buffer
                          (when (ignore-errors
                                  (call-interactively cmd) t)
                            (buffer-string))))))
      (when future
        (save-excursion
          (insert (propertize future 'face 'shadow)))
        (add-hook 'pre-command-hook 'mcfly-back-to-present nil t)))))

(add-hook 'minibuffer-setup-hook #'mcfly-time-travel)



