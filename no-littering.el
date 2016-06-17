;;; no-littering.el --- help keeping ~/.emacs.d clean

;; Copyright (C) 2016  Jonas Bernoulli

;; Author: Jonas Bernoulli <jonas@bernoul.li>
;; Homepage: http://github.com/tarsius/no-littering
;; Package-Requires: ((cl-lib "0.5"))

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see https://www.gnu.org/licenses.

;;; Commentary:

;; Help keeping ~/.emacs.d clean.

;; The default paths used to store configuration files and persistent
;; data are not consistent across Emacs packages.  This isn't just a
;; problem with third-party packages but even with built-in packages.

;; Some packages put these files directly in `user-emacs-directory'
;; or $HOME or in a subdirectory of either of the two or elsewhere.
;; Furthermore sometimes file names are used that don't provide any
;; insight into what package might have created them.

;; This package sets out to fix this by changing the values of path
;; variables to put files in either `no-littering-etc-directory'
;; (defaulting to "~/.emacs.d/etc/") or `no-littering-var-directory'
;; (defaulting to "~/.emacs.d/var/"), and by using descriptive file
;; names and subdirectories when appropriate.  This is similar to a
;; color-theme; a "path-theme" if you will.

;; We still have a long way to go until most built-in and many third-
;; party path variables are properly "themed".  Like a color-theme,
;; this package depends on user contributions to accomplish decent
;; coverage.  Pull requests are highly welcome.

;; Usage:

;; Load the feature `no-littering' as early as possible in your init
;; file.  Make sure you load it at least before you change any path
;; variables using some other method.
;;
;;   (require 'no-littering)

;; If you would like to use base directories different from what
;; `no-littering' uses by default, then you have to set the respective
;; variables before loading the feature.
;;
;;   (setq no-littering-etc-directory
;;         (expand-file-name "config/" user-emacs-directory))
;;   (setq no-littering-var-directory
;;         (expand-file-name "data/" user-emacs-directory))
;;   (require 'no-littering)

;; Conventions:

;; * File names
;;
;; 1. File names are based on the name of the respective Emacs lisp
;;    variables and the name of the respective Emacs package.
;;   
;; 2. The name of the respective Emacs package should serve as the
;;    prefix of the file name, unless the file is in a subdirectory in
;;    which case the name of the subdirectory serves as the prefix.
;;
;; 3. If the name of the package and the prefix of the variable do not
;;    match, then we prefer the name of the package.
;;
;; 4. If the name of a path variable ends with `-file`, `-default-file`,
;;    `-directory`, `-default-directory`, or something similar, then that
;;    suffix is usually dropped from the file name.
;;
;; 5. If applicable, the appropriate extension is added to the file name
;;    so that files are visited using the appropriate major-modes and
;;    also to provide a hint about the kind of data stored in the file.
;;    E.g.  if a file contains an S-expression, then the suffix should be
;;    `*.el`.

;; * File location and subdirectories
;;
;; 1. If a package has only one data file, then that is usually placed in
;;    `no-littering-var-directory` itself.  Likewise if a package has
;;    only one config file, then that is placed in
;;    `no-littering-etc-directory` itself.
;;
;; 2. If a package has multiple data (or config files), then those files
;;    are placed in a subdirectory of `no-littering-var-directory` (or
;;    `no-littering-var-directory`).
;;  
;; 3. If a subdirectory is used for a package's data (or config) file
;;    variables, then the name of the directory should match the name of
;;    the package in most cases. The subdirectory name may serve as the
;;    package prefix of the file name.
;;
;; 4. A package that provides a "framework" for other packages to use,
;;    then we may reuse its directories for other packages that make use
;;    of that framework or otherwise "extend" the "main package".
;;    E.g. we place all `helm` related files in `helm/`.
;;
;; 5. If a package only defines a single variable that specifies a data
;;    (or config) directory, then the directory name should
;;    nevertheless be just the package name.  E.g. the path used for
;;    `sx-cache-directory` from the `sx` package is `sx/cache/`, not
;;    `sx-cache/`.
;;
;; 6. However if the name of the directory variable implies that the
;;    package won't ever define any data (or config) files that won't be
;;    placed in that directory, then we use a top-level directory.  E.g.
;;    when the name of the variable is `<package>-directory`, in which
;;    case we would use just `<package>/` as the path.

;; * Ordering and alignment
;;
;; The code that sets the values of themed variables is split into two
;; groups.  The first group sets the value of variables that belong to
;; packages that are part of Emacs, and the second group is used for
;; variables that are defined by packages that are not part of Emacs.
;; Each of these lists is sorted alphabetically.  Please keep it that
;; way.
;;
;; We attempt to align the value forms inside different `setq' forms.
;; If the symbol part for a particular variable is too long to allow
;; doing so, then don't worry about it and just break the alignment.
;; If it turns out that this happens very often, then we will adjust
;; the alignment eventually.

;; * Commit messages
;;
;; Please theme each package using a separate commit and use commit
;; messages of the form "<package>: theme <variable".  If a package
;; has several path variables, then you should theme them all in one
;; commit.  If the variable names do not fit nicely on the summary
;; line, then use a message such as:
;;
;;   foo: theme variables
;;
;;   Theme `foo-config-file', `foo-cache-directory',
;;   and `foo-persistent-file'.

;;; Code:

(require 'cl-lib)

(defvar no-littering-etc-directory
  (expand-file-name (convert-standard-filename "etc/") user-emacs-directory)
  "The directory where packages place their configuration files.
This variable has to be set before `no-littering' is loaded.")

(defvar no-littering-var-directory
  (expand-file-name (convert-standard-filename "var/") user-emacs-directory)
  "The directory where packages place their persistent data files.
This variable has to be set before `no-littering' is loaded.")

(cl-flet ((etc (file) (expand-file-name (convert-standard-filename file)
                                        no-littering-etc-directory))
          (var (file) (expand-file-name (convert-standard-filename file)
                                        no-littering-var-directory)))
  (with-no-warnings ; many of these variables haven't been defined yet

;;; Built-in packages

    (setq abbrev-file-name                 (var "abbrev.el"))
    (setq auto-save-list-file-prefix       (var "auto-save-"))
    (setq backup-directory-alist           (list (cons "." (var "backup/"))))
    (setq bookmark-default-file            (var "bookmark-default.el"))
    (setq desktop-path                     (list (var "desktop/")))
    (setq eshell-directory-name            (var "eshell/"))
    (setq gamegrid-user-score-file-directory (var "gamegrid-user-score/"))
    (setq ido-save-directory-list-file     (var "ido-save-directory-list.el"))
    (setq image-dired-dir                  (var "image-dired/"))
    (setq image-dired-db-file              (var "image-dired/db.el"))
    (setq image-dired-temp-image-file      (var "image-dired/temp-image"))
    (setq image-dired-temp-rotate-image-file (var "image-dired/temp-rotate-image"))
    (setq image-dired-gallery-dir          (var "image-dired/gallery/"))
    (setq nsm-settings-file                (var "nsm-settings.el"))
    (eval-after-load 'org
      `(make-directory ,(var "org/") t))
    (setq org-id-locations-file            (var "org/id-locations.el"))
    (setq org-registry-file                (var "org/registry.el"))
    (setq recentf-save-file                (var "recentf-save.el"))
    (setq save-place-file                  (var "save-place.el"))
    (setq savehist-file                    (var "savehist.el"))
    (setq semanticdb-default-save-directory (var "semantic/"))
    (setq tramp-persistency-file-name      (var "tramp-persistency.el"))
    (setq trash-directory                  (var "trash/"))
    (setq url-cache-directory              (var "url/"))
    (setq url-configuration-directory      (etc "url/"))

;;; Third-party packages

    (setq anaconda-mode-installation-directory (etc "anaconda-mode/"))
    (eval-after-load 'company-statistics
      `(make-directory ,(var "company/") t))
    (setq company-statistics-file          (var "company/statistics.el"))
    (setq emms-directory                   (var "emms/"))
    (eval-after-load 'helm
      `(make-directory ,(var "helm/") t))
    (setq helm-adaptive-history-file       (var "helm/adaptive-history.el"))
    (setq helm-github-stars-cache-file     (var "helm/github-stars-cache.el"))
    (setq mc/list-file                     (var "mc-list.el"))
    (setq persistent-scratch-save-file     (var "persistent-scratch.el"))
    (eval-after-load 'projectile
      `(make-directory ,(var "projectile/") t))
    (setq projectile-cache-file            (var "projectile/cache.el"))
    (setq projectile-known-projects-file   (var "projectile/known-projects.el"))
    (setq request-storage-directory        (var "request/storage/"))
    (setq smex-save-file                   (var "smex-save.el"))
    (setq sx-cache-directory               (var "sx-cache/"))
    (setq undo-tree-history-directory-alist (list (cons "." (var "undo-tree-hist/"))))
    (setq user-emacs-ensime-directory      (var "ensime/"))
    ))

(provide 'no-littering)
;; Local Variables:
;; indent-tabs-mode: nil
;; End:
;;; no-littering.el ends here
