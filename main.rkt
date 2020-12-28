#lang typed/racket

(provide report label
         Report?
         ;; color
         (except-out (all-from-out "color.rkt")
                     color->atom))

(require/typed "report.rkt"
               [#:struct Report
                ([error-code : (Option String)]
                 [target : Loc]
                 [message : String]
                 [label* : (Listof Label)]
                 [hint : (Option String)])])
(require/typed "label.rkt"
               [#:struct Label
                ([target : Path-String]
                 [msg : String]
                 [color? : (Option color)])]
               [label (->* (srcloc String) (#:color (Option color)) Label)]
               [label*->text (-> (Listof Label) text)])
(require "loc.rkt"
         "color.rkt"
         "text.rkt")

(: report (->* [#:target srcloc #:message String #:labels (Listof Label)] [#:error-code (Option String) #:hint (Option String)] Report))
(define (report #:target target #:message msg #:labels label* #:error-code [err-code #f] #:hint [hint #f])
  (Report err-code (srcloc->loc target) msg label* hint))
