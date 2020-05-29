#lang typed/racket

(require racket/file)
(require "position.rkt"
         "label.rkt"
         "text.rkt")

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

(: report->text (Report -> text))
(define (report->text report)
  (define err-c-str (let ([err-code (Report-error-code report)])
                      (if err-code
                          (format "[~a]: " err-code)
                          "Error: ")))
  (define primary-label (Report-primary-label report))
  (: labels (Listof Label))
  (define labels (list* primary-label (Report-more-labels report)))
  (define collected (collection->text (collect-labels (Report-file-name report) labels)))
  (text-append* err-c-str (Report-message report) "\n"
                 (format "~a:~a:~a"
                         (Report-file-name report)
                         (Pos-line (Label-start primary-label))
                         (Pos-column (Label-start primary-label))) "\n"
                 collected
                 "=> " (Report-hint-message report)
                 "\n"))

(define s (report->text
           (report
            #:file-name "test.c"
            #:message "type mismatching"
            #:primary-label (Label (Pos 4 10) (Pos 4 17) "cannot assign a `string` to `int` variable")
            #:more-labels (list (Label (Pos 4 6) (Pos 4 7) "`x` is a `int` variable"))
            #:hint-message "expected type `int`, found type `string`"
            #:error-code "E0001")))
(print-text s)
