#lang typed/racket

(provide report
         report->text
         label
         (all-from-out "color.rkt")
         (all-from-out "position.rkt"))
(require/typed/provide "print-text.rkt"
               [print-text (text -> Void)])

(require racket/file)
(require "position.rkt"
         "label.rkt"
         "color.rkt"
         "text.rkt")

(struct Report
  ([file-name : String]
   [pos : Pos]
   [message : String]
   [error-code : (Option String)]
   [labels : (Listof Label)]
   [hint-message : String])
  #:transparent)

(: report (->* [#:file-name String #:pos Pos #:message String #:labels (Listof Label)] [#:error-code (Option String) #:hint-message String] Report))
(define (report #:file-name file-name #:pos pos #:message msg #:labels labels #:error-code [err-code #f] #:hint-message [hint-message ""])
  (Report file-name pos msg err-code labels hint-message))

(: report->text (Report -> text))
(define (report->text report)
  (define err-c-str (let ([err-code (Report-error-code report)])
                      (if err-code
                          (format "[~a]: " err-code)
                          "Error: ")))
  (: labels (Listof Label))
  (define labels (Report-labels report))
  (define collected (collection->text (collect-labels (Report-file-name report) labels)))
  (text-append* (color-text (color:red) err-c-str)
                (Report-message report) "\n"
                (format "~a:~a:~a"
                        (Report-file-name report)
                        (Pos-line (Report-pos report))
                        (Pos-column (Report-pos report)))
                "\n"
                collected
                (color-text (color:blue) "=> ")
                (Report-hint-message report)
                "\n"))
