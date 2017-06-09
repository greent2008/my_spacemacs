(setq cc-ide-packages
      '(
        cc-mode
        company
        irony
        company-irony
        company-irony-c-headers
        irony-eldoc
        flycheck
        flycheck-irony
        ))

(defun cc-ide/init-cc-mode ()
  (use-package cc-mode
    :defer t
    :config
    (progn
      (require 'compile)
      (c-toggle-auto-newline 1)
      (spacemacs/set-leader-keys-for-major-mode 'c-mode
        "ga" 'projectile-find-other-file
        "gA" 'projectile-find-other-file-other-window)
      (spacemacs/set-leader-keys-for-major-mode 'c++-mode
        "ga" 'projectile-find-other-file
        "gA" 'projectile-find-other-file-other-window))))


(defun cc-ide/post-init-company ()
  (spacemacs|add-company-hook c-mode-common))

(defun cc-ide/init-irony ()
  (use-package irony
    :defer t
    :commands (irony-mode irony-install-server)
    :init
    (progn
      (add-hook 'c-mode-hook 'irony-mode)
      (add-hook 'c++-mode-hook 'irony-mode))
    :config
    (progn
      (setq irony-user-dir (f-slash (f-join user-home-directory "bin" "irony")))
      (setq irony-server-install-prefix irony-user-dir)
      (add-hook 'c++-mode-hook (lambda () (setq irony-additional-clang-options '("-std=c++11"))))
      (defun irony/irony-mode-hook ()
        (define-key irony-mode-map [remap completion-at-point] 'irony-completion-at-point-async)
        (define-key irony-mode-map [remap complete-symbol] 'irony-completion-at-point-async))

      (add-hook 'irony-mode-hook 'irony/irony-mode-hook)
      (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options))))

(when (configuration-layer/layer-usedp 'auto-completion)
  (defun cc-ide/init-company-irony ()
    (use-package company-irony
      :if (configuration-layer/package-usedp 'company)
      :commands (company-irony)
      :defer t
      :init
      (progn
        (add-hook 'irony-mode-hook 'company-irony-setup-begin-commands)
        (push 'company-irony company-backends-c-mode-common)))))

(when (configuration-layer/layer-usedp 'auto-completion)
  (defun cc-ide/init-company-irony-c-headers ()
    (use-package company-irony-c-headers
      :if (configuration-layer/package-usedp 'company)
      :defer t
      :commands (company-irony-c-headers)
      :init
      (push 'company-irony-c-headers company-backends-c-mode-common))))

(defun cc-ide/init-irony-eldoc ()
  (use-package irony-eldoc
    :commands (irony-eldoc)
    :init
    (add-hook 'irony-mode-hook 'irony-eldoc)))

(defun cc-ide/post-init-flycheck ()
  (dolist (mode '(c-mode c++-mode))
    (spacemacs/add-flycheck-hook mode)))

(when (configuration-layer/layer-usedp 'syntax-checking)
  (defun cc-ide/init-flycheck-irony ()
    (use-package flycheck-irony
      :if (configuration-layer/package-usedp 'flycheck)
      :defer t
      :init (add-hook 'irony-mode-hook 'flycheck-irony-setup))))
