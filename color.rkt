#lang typed/racket

(provide color color:red color:blue)

(define-type color (U color:red color:blue))
(struct color:red () #:transparent)
(struct color:blue () #:transparent)
