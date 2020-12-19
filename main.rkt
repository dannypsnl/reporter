#lang typed/racket

(provide report report->text
         label
         (except-out (all-from-out "color.rkt")
                     color->atom))
(require/typed/provide "print-text.rkt"
                       [print-text (text -> Void)])

(require/typed racket/base
               [srcloc->string (srcloc -> String)])
(require racket/file)
(require "label.rkt"
         "color.rkt"
         "text.rkt")

(struct Report
  ([error-code : (Option String)]
   [target : srcloc]
   [message : String]
   [label* : (Listof Label)]
   [hint : (Option String)])
  #:transparent)
(: report (->* [#:target srcloc #:message String #:labels (Listof Label)] [#:error-code (Option String) #:hint (Option String)] Report))
(define (report #:target target #:message msg #:labels label* #:error-code [err-code #f] #:hint [hint #f])
  (Report err-code target msg label* hint))

(: report->text (Report -> text))
(define (report->text report)
  (match-let ([(Report error-code? target message label* hint?) report])
    (define err-c-str (if error-code? (format "[~a]: " error-code?) "Error: "))
    (text-append* (color-text (color:red) err-c-str)
                  message "\n"
                  (srcloc->string target)
                  "\n"
                  (map (lambda (l) (Label->text l)) label*)
                  (color-text (color:blue) "=> ")
                  (if hint? hint? "")
                  "\n")))
