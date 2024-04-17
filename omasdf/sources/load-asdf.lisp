(in-package :omasdf)

(require 'asdf)

(defvar *omasdf-sources-path* nil)
(setf *omasdf-sources-path* (make-pathname  :directory (pathname-directory *load-pathname*)))

(defvar *loaded-sources* nil)
(setf *loaded-sources* nil)

(defvar *om-asdf-loaded-systems-path* nil)
(setf  *om-asdf-loaded-systems-path*
 (cond ((equal :mac om::*om-os*)
        (make-pathname :directory (append (pathname-directory cl-user::*om-src-directory*)
        (list (concatenate 'string "OM\ " cl-user::*version-str* ".app") "Contents" "Resources" "code" "api" "foreign-interface" "ffi"))))

		((equal :win om::*om-os*)
		 (make-pathname :directory (append (pathname-directory cl-user::*om-src-directory*)
		                                   '("code" "api" "foreign-interface" "ffi"))))
   		(t ; :linux ???
   		 (make-pathname :directory (append (pathname-directory cl-user::*om-src-directory*)
   		                                   '("code" "api" "foreign-interface" "ffi"))))))


(defvar *om-asdf-loaded-systems* nil)
(setf *om-asdf-loaded-systems* (mapcar 'asdf::coerce-name (asdf::registered-systems*)))
                               ;(asdf::already-loaded-systems))

;; EXPERIMENTAL

(defun get-all-asdf-dependencies (system)
 (if (and (listp system) (symbolp (car system)))
      nil
     (let ((dir (if (consp system) (car system) system))
		   (asd-file (if (consp system) (cdr system) system))
			dep)

	(cond ((member asd-file *loaded-sources* :test #'equal)
	       ;(print (format nil "System ~a is aready loaded." system))
		   nil)

	      ((member asd-file *om-asdf-loaded-systems* :test #'equal)
	       (pushnew (make-pathname :directory (append (pathname-directory *om-asdf-loaded-systems-path*) (list dir)))
		             asdf:*central-registry* :test 'equal)
	       ;(load (make-pathname :directory (append (pathname-directory *om-asdf-loaded-systems-path*) (list dir))
	       ;                     :name asd-file
	       ;	                 :type "asd"))
	   	   (pushnew asd-file *loaded-sources* :test 'equal)
		   ;(print (format nil "System ~a is aready included in OM distribution." system))
		   nil)

	(t
	 (pushnew (make-pathname :directory (append (pathname-directory *omasdf-sources-path*) (list dir))) asdf:*central-registry* :test 'equal)

  	 (print (format nil "Registering ~a ..." asd-file))

  	 (asdf:load-asd (make-pathname :directory (append (pathname-directory *omasdf-sources-path*) (list dir))
                                  :name asd-file
  	                              :type "asd"))

	(pushnew asd-file *loaded-sources* :test 'equal)

     (setq dep
	  (remove-if #'(lambda (sys) (member sys *loaded-sources* :test #'equal))
	   (asdf::system-depends-on (asdf::find-system
        (car (om::list! (read-from-string (concatenate 'string ":" system))))))))

	(when dep (print (format nil "Dependencies of ~a: ~a" asd-file
     (loop for el in dep when (stringp el) collect el))))

	(if (null dep)
	     nil
	 	(mapcar #'get-all-asdf-dependencies dep)
	)
   )
  )
 )
)
)

(om::defmethod! load-asdf-system ((asdf-sys list))
 :initvals '(nil)
 :indoc '("list or list of lists of strings")
 :icon 201
 :doc "Loads a ASDF system or a list of ASDF systems.
If a system is in a subfolder, the argument must be a list with <folder> and <file>, without file extension.
This method does not compile files, only loads the source .lisp files."
 (progn
  (mapc #'(lambda (system)
           (get-all-asdf-dependencies system))
   asdf-sys)
	 ;(mapc #'(lambda (system) <=== MOVED TO GET-ALL-ASDF-DEPENDENCIES
 	 ;    (let ((dir (if (consp system) (car system) system))
     ;		  (asd-file (if (consp system) (cdr system) system)))
     ;	      (asdf:load-asd (make-pathname :directory (append (pathname-directory *omasdf-sources-path*) (list dir))
     ;			                   :name asd-file
     ;				               :type "asd"))))
     ;		                       ;:package :asdf)))

  (print "Loading ...")

  (mapc #'(lambda (system)
                 ;(print (format nil "Loading source files of ASDF system ~a ..." (if (consp system) (cdr system) system)))
                 (asdf:oos :load-source-op system :verbose t))
   asdf-sys)
 )
 (setf asdf:*central-registry* nil)
 (loop for sys in asdf-sys collect (if (consp sys) (last-elem sys) sys))
)
