;;;; SPDX-FileCopyrightText: Atlas Engineer LLC
;;;; SPDX-License-Identifier: BSD-3-Clause

(in-package :nyxt)

(export-always 'format-status-modes)
(defun format-status-modes (buffer window)
  (format nil "~:[~;⚠ nosave ~]~{~a~^ ~}"
          (nosave-buffer-p buffer)
          (mapcar (if (glyph-mode-presentation-p (status-buffer window))
                      #'glyph
                      #'format-mode)
                  (sera:filter #'visible-in-status-p (modes buffer)))))

(defun list-modes (buffer)
  (format nil "~{~a~^ ~}" (mapcar #'format-mode (modes buffer))))

(export-always 'format-status-buttons)
(defun format-status-buttons ()
  (markup:markup
   (:a :class "button" :title "Backwards" :href (lisp-url '(nyxt/web-mode:history-backwards)) "←")
   (:a :class "button" :title "Forwards" :href (lisp-url '(nyxt/web-mode:history-forwards)) "→")
   (:a :class "button" :title "Reload" :href (lisp-url '(nyxt:reload-current-buffer)) "↺")
   (:a :class "button" :title "Execute" :href (lisp-url '(nyxt:execute-command)) "⚙")
   (:a :class "button" :title "Buffers" :href (lisp-url '(nyxt/buffer-listing-mode:list-buffers)) "≡")))

(export-always 'format-status-load-status)
(defun format-status-load-status (buffer)
  (markup:markup
   (:div :class (when (and (web-buffer-p buffer)
                           (eq (slot-value buffer 'load-status) :loading))
                  "loader") "")))

(export-always 'format-status-url)
(defun format-status-url (buffer)
  (markup:markup
   (:a :class "button"
       :href (lisp-url '(nyxt:set-url))
       (format nil " ~a — ~a"
               (render-url (url buffer))
               (title buffer)))))

(export-always 'format-status-tabs)
(defun format-status-tabs ()
  (markup:markup
   (:span
    (loop for domain in (remove-duplicates
                         (sera:filter-map #'quri:uri-domain
                                          (mapcar #'url (sort-by-time (buffer-list))))
                         :test #'equal)
          collect (markup:markup
                   (:a :class "tab"
                       :href
                       (lisp-url `(nyxt::switch-buffer-or-query-domain ,domain)) domain))))))

(defun format-status (window)
  (let ((buffer (current-buffer window)))
    (markup:markup
     (:div :id "container"
           (:div :id "controls" :class "arrow-right"
                 (markup:raw (format-status-buttons)))
           (:div :id "url" :class "arrow-right"
                 (markup:raw
                  (format-status-load-status buffer)
                  (format-status-url buffer)))
           (:div :id "tabs"
                 (markup:raw
                  (format-status-tabs)))
           (:div :id "modes" :class "arrow-left"
                 :title (list-modes buffer)
                 (format-status-modes buffer window))))))
