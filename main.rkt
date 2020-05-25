#lang typed/racket

(require racket/file)
(require "position.rkt")

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

(struct Label
  ([start-pos : Pos]
   [end-pos : Pos]
   [message : String])
  #:transparent)

(: report (->* [#:message String #:primary-label Label] [#:error-code String] Void))
(define (report #:message msg #:primary-label primary-label #:error-code [err-code : String ""])
  (void))

(report
  #:message "type mismatching"
  #:primary-label (Label (Pos 4 2) (Pos 4 5) "cannot assign a `string` to `int` variable")
  #:error-code "E0001")
