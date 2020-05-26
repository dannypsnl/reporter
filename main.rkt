#lang typed/racket

(require racket/file)
(require "position.rkt"
         "label.rkt")

(struct Report
  ([file-name : String]
   [message : String]
   [primary-label : Label]
   [error-code : (Option String)]
   [more-labels : (Listof Label)]
   [hint-message : String])
  #:transparent)

(: report (->* [#:file-name String #:message String #:primary-label Label] [#:error-code (Option String) #:more-labels (Listof Label) #:hint-message String] Report))
(define (report #:file-name file-name #:message msg #:primary-label primary-label #:error-code [err-code #f] #:more-labels [more-labels '()] #:hint-message [hint-message ""])
  (Report file-name msg primary-label err-code more-labels hint-message))

(: report->string (-> Report String))
(define (report->string report)
  (define err-c-str (let ([err-code (Report-error-code report)])
                      (if err-code
                          (format "[~a]: " err-code)
                          "")))
  (define primary-label (Report-primary-label report))
  (: labels (Listof Label))
  (define labels (list* primary-label (Report-more-labels report)))
  (define collected (collection->string (collect-labels (Report-file-name report) labels)))
  (string-append err-c-str (Report-message report) "\n"
                 (format "~a:~a:~a"
                         (Report-file-name report)
                         (Pos-line (Label-start primary-label))
                         (Pos-line (Label-start primary-label))) "\n"
                 collected
                 "=> " (Report-hint-message report)))

(define s (report->string
           (report
            #:file-name "test.c"
            #:message "type mismatching"
            #:primary-label (Label (Pos 4 10) (Pos 4 17) "cannot assign a `string` to `int` variable")
            #:more-labels (list (Label (Pos 4 6) (Pos 4 7) "`x` is a `int` variable"))
            #:hint-message "expected type `int`, found type `string`"
            #:error-code "E0001")))
(displayln s)
