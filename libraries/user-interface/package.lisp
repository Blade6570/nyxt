;;;; SPDX-FileCopyrightText: Atlas Engineer LLC
;;;; SPDX-License-Identifier: BSD-3-Clause



(in-package :cl-user)

(uiop:define-package :user-interface
  (:use :common-lisp)
  (:export
   #:id
   #:buffer
   #:update
   #:text
   #:object-expression
   #:ui-element
   #:paragraph
   #:connect))
