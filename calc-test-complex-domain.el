;;; calc-funcs-test-cplx.el  -*- lexical-binding:t -*-
;;; Author: DonjuanPlatinum <donplat@barrensea.org>
;;; Code:
(require 'calc)
(require 'calc-funcs)
(require 'calc-cplx)
(require 'calc-ext)
(defun calcFunc-psi (x)
  (or (math-numberp x) (math-reject-arg x 'numberp))
  ;; x <= 0
  (if (or (math-lessp x 0) (math-equal x 0))
      ;; x is non-positive integer, they are pole.
      (if (math-num-integerp x)
          (if calc-infinite-mode
              '(var uinf var-uinf)
            (math-reject-arg x 'range))
        ;; reflection with extra precision.
        ;; FIXME: Find better values than calc-internal-prec.
        (math-with-extra-prec calc-internal-prec
        (let* ((sc (math-sin-cos-raw (math-mul (math-pi) x))))
             (math-sub (calcFunc-psi (math-sub 1 x))
                       (math-mul (math-pi) (math-div (cdr sc) (car sc)))))))
    ;; x > 0
    (let ((prec calc-internal-prec))
      (math-with-extra-prec 2
        (if (math-lessp x prec) ;; x < prec
            (let ((sum 0))
              (while (math-lessp x prec)
                (setq sum (math-add sum (math-div 1 x))
                      x (math-add x 1)))
              (math-sub (math-psi-series x) sum))
          ;; x >= prec
          (math-psi-series x))))))


(defun math-psi-series (x)
  (setq x (math-float x))
  (let* ((xinv (math-div 1 x))
        (xinv2 (math-sqr xinv)))
    (math-psi-series-step
     (math-sub (math-ln-raw x) (math-div xinv 2))
     xinv2
     xinv2
     1)))

(defun math-psi-series-step (sum xpow xinv2 k)
  (math-working "psi" sum)
  (let* ((bn (math-bernoulli-number (math-mul 2 k)))
         (term (math-neg (math-mul (math-div bn (math-mul 2 k)) xpow)))
         (next (math-add sum term)))
    (if (math-nearly-equal sum next) next
      (if (math-lessp calc-internal-prec k) next
        (math-psi-series-step next (math-mul xpow xinv2) xinv2 (math-add 1 k))))))
(defun calc-funcs-get-result ()
  (let* ((args (cdr (member "--" command-line-args-left)))
         (func (intern (pop args)))
	 (precise (string-to-number (pop args)))
         (arg))
    (setq calc-internal-prec precise)
    (while-let ((x (pop args)))
      (push (math-read-number-simple x) arg))
    (setq arg (nreverse arg))
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
