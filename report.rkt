#lang racket/base
(provide (struct-out Report))
(require racket/match)
(require "loc.rkt"
         "label.rkt"
         "text.rkt")

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
    (text-append* (color-text err-c-str #:color 'red)
                  message "\n"

                  (space-repeat pre-code-shift)
                  (color-text "--> " #:color 'blue)
                  (loc->string target)
                  "\n"

                  (label*->text label* pre-code-shift)

                  (space-repeat pre-code-shift)
                  (color-text "=> " #:color 'blue)
                  (if hint? hint? "")
                  "\n")))
