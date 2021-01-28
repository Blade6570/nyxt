;;;; SPDX-FileCopyrightText: Atlas Engineer LLC
;;;; SPDX-License-Identifier: BSD-3-Clause

(in-package :user-interface)

(defvar *id* 0 "Counter used to generate a unique ID.")

(defun unique-id ()
  (format nil "ui-element-~d" (incf *id*)))

(defclass ui-element ()
  ((id :accessor id)
   (buffer :accessor buffer :initarg :buffer
           :documentation "Buffer where element is drawn.")))

(defmethod initialize-instance :after ((element ui-element) &key)
  (setf (id element) (unique-id)))

(defmethod object-string ((element ui-element))
  (cl-markup:markup*
   (object-expression element)))

(defmethod object-expression ((object t))
  (princ-to-string object))

(defmethod connect ((element ui-element) buffer)
  (setf (buffer element) buffer))

(defgeneric update (ui-element)
  (:documentation "Propagate changes to the buffer."))

(defclass button (ui-element)
  ((text :initform "" :accessor text :initarg :text)
   (url :initform "" :accessor url :initarg :url)))

(defmethod object-expression ((button button))
  `(:a :class "button" :href ,(url button) ,(text button)))

(defclass paragraph (ui-element)
  ((text :initform "" :initarg :text)))

(defmethod (setf text) (text (paragraph paragraph))
  (setf (slot-value paragraph 'text) text)
  (when (slot-boundp paragraph 'buffer)
    (update paragraph)))

(defmethod object-expression ((paragraph paragraph))
  `(:p :id ,(id paragraph) ,(text paragraph)))

(defmethod text ((paragraph paragraph))
  (object-expression (slot-value paragraph 'text)))

(defclass unordered-list (ui-element)
  ((elements :initform (list) :initarg :elements)))
