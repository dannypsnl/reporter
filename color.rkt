#lang typed/racket

(provide color color:red color:blue)

(struct color () #:transparent)
(struct color:red color () #:transparent)
(struct color:blue color () #:transparent)
