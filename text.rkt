#lang typed/racket
(provide text color-text
         text-append*
         text-repeat space-repeat)
(require "color.rkt")

(define-type text (U color-text String (Listof text)))
(struct color-text
  ([color : color]
   [text : String])
  #:transparent)

(: text-append* (text * -> text))
(define (text-append* . ts)
  ts)

(: text-repeat (Integer text -> text))
(define (text-repeat n t)
  (text-append* (make-list n t)))
(: space-repeat (Integer -> text))
(define (space-repeat n)
  (text-repeat n " "))
