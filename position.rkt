#lang typed/racket

(provide Pos Pos-line Pos-column)

(struct Pos
  ([line : Integer]
   [column : Integer])
  #:transparent)
