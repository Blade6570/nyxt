;;;; SPDX-FileCopyrightText: Atlas Engineer LLC
;;;; SPDX-License-Identifier: BSD-3-Clause

(in-package :nyxt)

(define-class meta-result ()
  ((result)
   (source-minibuffer :initarg :source))
  (:accessor-name-transformer #'class*:name-identity))

(defmethod object-display ((meta-result meta-result))
  (format nil "~a" (object-display (result meta-result))))

(defun meta-search (minibuffers)
  "Search a composite set of sources simultaneously."
  (let ((selection
          (prompt-minibuffer
           :input-prompt "Meta Search"
           :suggestion-function
           (lambda (minibuffer)
             (apply #'intertwine
                    (loop for i in minibuffers
                          collect
                          (loop for result in (funcall (suggestion-function i)
                                                       minibuffer)
                                collect (make-instance 'meta-result
                                                       :result result
                                                       :source i))))))))
    (funcall (slot-value (source-minibuffer selection) 'callback) (result selection))))

(defun intertwine (&rest lists)
  (let ((heads (copy-list lists))
        (result '()))
    (loop (loop for list on heads do
                   (when (car list)
                     (push (pop (car list)) result))
                   (when (every #'null heads)
                     (return-from intertwine (nreverse result)))))))

