#lang racket/base
(provide report label
         Report?
         ;; color
         (except-out (all-from-out "color.rkt")
                     color->atom)
         current-report-collection
         collect-report)
(require "loc.rkt"
         "label.rkt"
         "color.rkt"
         "report.rkt"
         "collect.rkt")

(define (report #:target target #:message msg #:labels label* #:error-code [err-code #f] #:hint [hint #f])
  (Report err-code
          (any->loc target)
          msg
          label*
          hint))

(define (label target msg #:color [color #f])
  (Label (any->loc target) msg color))

(define (stx->loc stx)
  (srcloc->loc (srcloc (syntax-source stx)
                       (syntax-line stx)
                       (syntax-column stx)
                       (syntax-position stx)
                       (syntax-span stx))))
(define (any->loc e)
  (cond
    [(srcloc? e) (srcloc->loc e)]
    [(syntax? e) (stx->loc e)]))

(module+ test
  (require rackunit)
  (require syntax/parse)

  (test-case "syntax can be auto converted to internal loc, too"
             (define target #'(a b c))
             (define a (syntax-parse target [(a b c) #'a]))
             (define b (syntax-parse target [(a b c) #'b]))
             (define a-report (report
                               #:error-code "E0001"
                               #:message "example"
                               #:target target
                               #:labels (list
                                         (label a "a is here"
                                                #:color (color:red))
                                         (label b "b is here"
                                                #:color (color:blue)))
                               #:hint "super weird"))
             (check-pred Report? a-report)))
