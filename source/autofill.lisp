;;;; SPDX-FileCopyrightText: Atlas Engineer LLC
;;;; SPDX-License-Identifier: BSD-3-Clause

(in-package :nyxt)

(export-always '(autofill-id
                 autofill-name
                 autofill-key
                 autofill-fill
                 make-autofill))
(defstruct autofill
  (id)
  (name)
  (key)
  (fill))

(defmethod object-string ((autofill autofill))
  (autofill-key autofill))

(defmethod prompter:object-properties ((autofill autofill))
  (list :name (autofill-name autofill)
        :fill (autofill-fill autofill)))

(defmethod object-display ((autofill autofill))
  (format nil "~a:  ~a" (autofill-key autofill)
          (cond ((stringp (autofill-fill autofill))
                 (autofill-fill autofill))
                ((functionp (autofill-fill autofill))
                 (or (autofill-name autofill) "Function")))))
