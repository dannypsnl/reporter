#lang typed/racket

(require racket/file)
(require "position.rkt"
         "label.rkt")

(: print-code (String Pos Pos -> Void))
(define (print-code file-name start end)
  (letrec ([file-path : Path (string->path file-name)]
           [lines : (Listof String) (file->lines file-path)])
    (for-each
     (λ ([line-number : Integer])
       (let ([cur-line (list-ref lines line-number)])
         (printf "~a~n" cur-line)))
     (range (- (Pos-line start) 1) (Pos-line end)))))

; (print-code "test.c" (Pos 4 2) (Pos 4 5))



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
  (string-append err-c-str (Report-message report)))

(report->string
 (report
  #:message "type mismatching"
  #:primary-label (Label (Pos 4 2) (Pos 4 5) "cannot assign a `string` to `int` variable")
  #:error-code "E0001"))
