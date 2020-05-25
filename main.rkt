#lang typed/racket

(require racket/file)
(require "position.rkt"
         "label.rkt")

(struct Report
  ([message : String]
   [primary-label : Label]
   [error-code : (Option String)]
   [more-labels : (Listof Label)]
   [hint-message : (Option String)])
  #:transparent)

(: report (->* [#:message String #:primary-label Label] [#:error-code (Option String) #:more-labels (Listof Label) #:hint-message (Option String)] Report))
(define (report #:message msg #:primary-label primary-label #:error-code [err-code #f] #:more-labels [more-labels '()] #:hint-message [hint-message #f])
  (Report msg primary-label err-code more-labels hint-message))

(: report->string (-> Report String))
(define (report->string report)
  (define err-c-str (let ([err-code (Report-error-code report)])
                      (if err-code
                          (format "[~a]: " err-code)
                          "")))
  (define primary-label (Report-primary-label report))
  (string-append err-c-str (Report-message report) "\n"))

(define s (report->string
 (report
  #:message "type mismatching"
  #:primary-label (Label (Pos 4 2) (Pos 4 5) "cannot assign a `string` to `int` variable")
  #:error-code "E0001")))
s
(displayln s)
