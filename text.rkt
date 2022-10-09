#lang typed/racket
(provide text color-text
         print-text
         text-append*
         text-repeat space-repeat)
(require/typed colorize
               [colorize (->* (String Color)
                              (#:style Style)
                              String)])
(require "color.rkt")

(: color-text : (->* (String)
                     (#:color Color)
                     Color-text))
(define (color-text str #:color [color 'red] #:style [style 'bold])
  (Color-text color style str))

(define-type text (U Color-text String (Listof text)))
(struct Color-text
  ([color : Color]
   [style : Style]
   [text : String])
  #:transparent)

(: print-text : text -> Void)
(define (print-text t)
  (match t
    ([Color-text color style str]
     (display (colorize	str color #:style style)))
    ([? string?] (display t))
    ([? list?] (for-each
                (λ (t) (print-text t))
                t))))

(: text-append* (text * -> text))
(define (text-append* . ts)
  ts)

(: text-repeat (Integer text -> text))
(define (text-repeat n t)
  (text-append* (make-list n t)))
(: space-repeat (Integer -> text))
(define (space-repeat n)
  (text-repeat n " "))
