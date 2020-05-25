#lang typed/racket

(provide Pos Pos-line)

(struct Pos
  ([line : Integer]
   [column : Integer])
  #:transparent)
