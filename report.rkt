#lang racket/base
(provide (struct-out Report))
(require racket/match
         ansi-color)
(require "loc.rkt"
         "label.rkt"
         "text.rkt"
         "color.rkt")

(struct Report (error-code target message label* hint)
  #:methods gen:custom-write
  [(define (write-proc report port mode)
     (parameterize ([current-output-port port])
       (print-text (report->text report))))]
  #:transparent)

(define (report->text report)
  (match-let ([(Report error-code? target message label* hint?) report])
    (define err-c-str (if error-code? (format "error[~a]: " error-code?) "error: "))
    (define max-line (get-max-line label*))
    (define pre-code-shift (add1 (string-length (number->string max-line))))
    (text-append* (color-text (color:red) err-c-str)
                  message "\n"

                  (space-repeat pre-code-shift)
                  (color-text (color:blue) "--> ")
                  (loc->string target)
                  "\n"

                  (label*->text label* pre-code-shift)

                  (space-repeat pre-code-shift)
                  (color-text (color:blue) "=> ")
                  (if hint? hint? "")
                  "\n")))

(define (print-text t)
  (match t
    ([color-text c str]
     (parameterize ([foreground-color (color->atom c)])
       (color-display str)))
    ([? string?] (display t))
    ([? list?] (for-each
                (λ (t) (print-text t))
                t))))
