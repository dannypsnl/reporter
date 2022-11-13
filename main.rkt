#lang racket/base
(provide report warning ; top level reporting
         label
         Report?
         Error?
         Warning?
         Label?
         ;; color
         (all-from-out "color.rkt")
         current-report-collection
         collect-report)
(require "loc.rkt"
         "label.rkt"
         "color.rkt"
         "report.rkt"
         "collect.rkt")

(define (report #:target target #:message msg #:labels label* #:error-code [err-code #f] #:hint [hint #f])
  (Error err-code
         (any->loc target)
         msg
         label*
         hint))
(define (warning #:target target #:message msg #:labels label* #:hint [hint #f])
  (Warning (any->loc target)
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
                                                #:color 'red)
                                         (label b "b is here"
                                                #:color 'blue))
                               #:hint "super weird"))
             (check-pred Report? a-report)))

(module+ main
  (displayln (warning #:message "example"
                      #:target #'here
                      #:labels (list
                                (label #'this "this" #:color 'green)
                                (label #'that "that" #:color 'blue))
                      #:hint "self warning")))
