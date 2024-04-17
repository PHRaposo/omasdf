;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  OMASDF by PAULO HENRIQUE RAPOSO
;;; 
;;;  LOAD ASDF SYSTEMS IN OPENMUSIC
;;;

(in-package :om)

(mapc 'compile&load 
 (list	  
  (make-pathname  :directory (append (pathname-directory *load-pathname*) (list "sources")) :name "package" :type "lisp") 
  (make-pathname  :directory (append (pathname-directory *load-pathname*) (list "sources")) :name "load-asdf" :type "lisp")	     
 )
)

(fill-library '((Nil Nil Nil (omasdf::load-asdf-system) Nil)))

(print (format nil 
"OMASDF library
by Paulo Henrique Raposo
ASDF VERSION: ~a
" (asdf:asdf-version)))
