(defun git/create-git-ignore (dir)
  "Creates a .gitignore file."
  (interactive "Ddir:")
  (with-temp-buffer
    (let ((file (concat dir ".gitignore")))
      (insert (s-join "\n" '(".settings" "/.project" "/.classpath" ".DS_Store" ".idea" ".nrepl-port" "*.iml" "*.iws" "docs.txt")))
      (when (file-writable-p file)
        (write-region (point-min)
                      (point-max)
                      file)))))

(defun git/git-init (dir)
  "Initializes a git repository with a .gitignore file and master and develop branches."
  (interactive "D")
  (git/create-git-ignore dir)
  (shell-command "git init")
  (shell-command "git add .gitignore")
  (shell-command "git commit -am \"initial version\"")
  (shell-command "git branch develop")
  (shell-command "git checkout develop")
  (shell-command "git add --all")
  (shell-command "git commit -am \"initial develop version\""))

(provide 'git)
