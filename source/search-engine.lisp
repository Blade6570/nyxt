;;;; SPDX-FileCopyrightText: Atlas Engineer LLC
;;;; SPDX-License-Identifier: BSD-3-Clause

(in-package :nyxt)

(define-class search-engine ()
  ((shortcut (error "Slot `shortcut' must be set")
             :type string
             :documentation "The word used to refer to the search engine, for
instance from the `set-url' commands.")
   (search-url (error "Slot `search-url' must be set")
               :type string
               :documentation "The URL containing a '~a' which will be replaced with the search query.")
   (fallback-url nil
                 :type (or string null)
                 :documentation "The URL to fall back to when given an empty
query.  This is optional: if nil, use `search-url' instead with ~a expanded to
the empty string."))
  (:export-class-name-p t)
  (:export-accessor-names-p t)
  (:accessor-name-transformer (hu.dwim.defclass-star:make-name-transformer name)))

(export-always 'make-search-engine)
(defun make-search-engine (shortcut search-url &optional (fallback-url ""))
  (make-instance 'search-engine
                 :shortcut shortcut
                 :search-url search-url
                 :fallback-url fallback-url))

(defmethod object-string ((engine search-engine))
  (shortcut engine))

(defmethod object-display ((engine search-engine))
  (format nil "~a~a ~a"
          (shortcut engine)
          (make-string (max 0 (- 10 (length (shortcut engine)))) :initial-element #\no-break_space)
          (search-url engine)))

(defun bookmark-search-engines (&optional (bookmarks (get-data (bookmarks-path
                                                                (or (current-buffer)
                                                                    (make-instance 'user-buffer))))))
  (mapcar (lambda (b)
            (make-instance 'search-engine
                           :shortcut (shortcut b)
                           :search-url (if (quri:uri-scheme (quri:uri (search-url b)))
                                           (search-url b)
                                           (str:concat (object-display (url b)) (search-url b)))
                           :fallback-url (object-string (url b))))
          (remove-if (lambda (b) (or (str:emptyp (search-url b))
                                     (str:emptyp (shortcut b))))
                     bookmarks)))

(defun all-search-engines ()
  "Return the `search-engines' from the `browser' instance plus those in
bookmarks."
  (let ((buffer (or (current-buffer)
                    (make-instance 'user-buffer))))
    ;; Make sure `default-search-engine' returns the same value after the append.
    (append (bookmark-search-engines)
            (search-engines buffer))))

(defun default-search-engine (&optional (search-engines (all-search-engines)))
  "Return the last search engine of the SEARCH-ENGINES."
  (first (last search-engines)))

(define-class search-engine-source (prompter:source)
  ((prompter:name "Search Engines")
   (prompter:must-match-p t)
   (prompter:constructor (search-engines (current-buffer)))))

(define-command search-selection ()
  "Search selected text using the queried search engine."
  (let* ((selection (%copy))
         (engine (prompt
                  :prompt "Search engine:"
                  :sources (make-instance 'search-engine-source))))
    (when engine
      (buffer-load (generate-search-query selection (search-url engine))))))
