#lang typed/racket

(provide label Label->text
         (struct-out Label))

(require racket/file)
(require "loc.rkt"
         "color.rkt"
         "text.rkt")

(struct Label
  ([target : Loc]
   [msg : String]
   [color : (Option color)])
  #:transparent)
(: label (->*  ((U srcloc Syntax) String) (#:color (Option color)) Label))
(define (label target msg #:color [color #f])
  (Label (srcloc/syntax->loc target) msg color))

(define (get-code [src : Path-String] [line : Integer])
  : String
  (let* ([lines : (Listof String) (file->lines src)]
         [line-ref (- line 1)]
         [cur-line (list-ref lines line-ref)])
    (format "~a | ~a~n" line cur-line)))

(define (Label->text [label : Label])
  : text
  (match-let* ([(Label target msg color?) label]
               [(Loc src line col _ span) target])
    (let ([msg (format "~a ~a" (string-append* (make-list span "^")) msg)])
      (text-append* (get-code (cast src Path-String) line)
                    (space-repeat (string-length (number->string line)))
                    " | "
                    (space-repeat col)
                    (if color? (color-text color? msg) msg)
                    "\n"))))
