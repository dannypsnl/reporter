#lang typed/racket

(require/typed terminal-color
               [display-color (String #:fg Symbol -> Void)])
(require "color.rkt")

(define-type text (U color-text String))
(struct color-text
  ([color : color]
   [text : String])
  #:transparent)

(: print-text (text -> Void))
(define (print-text t)
  (match t
    ([color-text color str]
     (let ([c-atom (match color
                      ([color:red] 'red)
                      ([color:blue] 'blue)
                      )])
       (display-color str #:fg c-atom)
       ))
    (str (display str))))
