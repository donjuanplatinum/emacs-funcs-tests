;;; calc-funcs-test-cplx.el  -*- lexical-binding:t -*-
;;; Author: DonjuanPlatinum <donplat@barrensea.org>
;;; Code:
(require 'calc)
(require 'calc-funcs)
(require 'calc-cplx)

(defun calc-funcs-get-result ()
  (let* ((args (cdr (member "--" command-line-args-left)))
         (func (intern (nth 0 args)))
         (arg (math-read-number-simple (nth 1 args))))
    (unless (and (math-numberp arg) (fboundp func))
      (error "Invalid function or missing argument"))
    (princ (format "[RESULT] %s(%s): %S\n"
                   func
                   arg
                   (funcall func arg)))))
(calc-funcs-get-result)
