#lang typed/racket
(provide color color:red color:blue
         color->atom)

(struct color () #:transparent)
(struct color:red color () #:transparent)
(struct color:blue color () #:transparent)

(: color->atom (color -> Symbol))
(define (color->atom c)
  (match c
    ([color:red] 'red)
    ([color:blue] 'blue)))
