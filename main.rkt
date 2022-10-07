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
  (Report err-code (srcloc->loc target) msg label* hint))
