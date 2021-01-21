#lang racket/base

(provide current-report-collection
         collect-report)

(require (for-syntax racket/base
                     syntax/parse)
         "report.rkt"
         "loc.rkt")

(define current-report-collection (make-parameter '()))

(define-syntax (collect-report stx)
  (syntax-parse stx
    [(collect-report body ...)
     #'(with-handlers [(Report?
                        (λ (e)
                          (current-report-collection (cons e (current-report-collection)))))]
         body ...)]))

(module+ test
  (require rackunit)

  (parameterize ([current-report-collection '()])
    (collect-report
     (raise (Report "E0001" (Loc "collect.rkt" 1 1 1 1) "test" '() #f)))
    (check-eq? (length (current-report-collection))
               1)))
