#lang typed/racket

(provide label Label->text
         (struct-out Label))

(require racket/file)
(require "color.rkt"
         "text.rkt")

(struct Label
  ([target : srcloc]
   [msg : String]
   [color : (Option color)])
  #:transparent)
(: label (->*  (srcloc String) (#:color (Option color)) Label))
(define (label target msg #:color [color #f])
  (Label target msg color))

(define (get-code [src : Path-String] [line : Integer])
  : String
  (let* ([lines : (Listof String) (file->lines src)]
         [line-ref (- line 1)]
         [cur-line (list-ref lines line-ref)])
    (format "~a | ~a~n" line cur-line)))

(define (Label->text [label : Label])
  : text
  (match-let* ([(Label target msg color?) label]
               [(srcloc src line col _ span) target])
    (unless (and line col span)
      (error 'invalid "invalid target, expected to work with real file: ~a" target))
    (let ([msg (format "~a ~a" (string-append* (make-list span "^")) msg)])
      (text-append* (get-code (cast src Path-String) line)
                    (space-repeat (string-length (number->string line)))
                    " | "
                    (space-repeat col)
                    (if color? (color-text color? msg) msg)
                    "\n"))))
