#lang typed/racket

(provide Label Label-start Label-end)

(require racket/file)
(require "position.rkt")

(struct Label
  ([start : Pos]
   [end : Pos]
   [message : String])
  #:transparent)
