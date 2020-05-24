#lang typed/racket

(provide Pos Pos-line)

(struct Pos
  ([line : Positive-Integer]
   [column : Positive-Integer])
  #:transparent)
