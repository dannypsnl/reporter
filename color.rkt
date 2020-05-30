#lang typed/racket

(provide color color:red color:blue
         color->atom)

(define-type color (U color:red color:blue))
(struct color:red () #:transparent)
(struct color:blue () #:transparent)

(: color->atom (color -> Symbol))
(define (color->atom c)
  (match c
    ([color:red] 'red)
    ([color:blue] 'blue)))
