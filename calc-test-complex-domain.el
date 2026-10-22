;;; calc-funcs-test-cplx.el  -*- lexical-binding:t -*-
;;; Author: DonjuanPlatinum <donplat@barrensea.org>
;;; Code:
(require 'calc)
(require 'calc-funcs)
(require 'calc-cplx)
(require 'calc-ext)
(defun calc-funcs-get-result ()
  (let* ((args (cdr (member "--" command-line-args-left)))
         (func (intern (pop args)))
	 (precise (string-to-number (pop args)))
         (arg))
    (setq calc-internal-prec precise)
    (while-let ((x (pop args)))
      (push (math-read-number-simple x) arg))
    (unless (fboundp func)
      (error "Invalid function"))
    (while-let ((x (pop arg))
		(res (funcall func x))
		(x (math-format-number x))
		(res (math-format-number res)))
      (princ (format "[RESULT] %s(%s): %S\n"
                   func
                   x
                   res)))))
(calc-funcs-get-result)
