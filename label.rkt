#lang typed/racket

(provide Label)

(require "position.rkt")

(struct Label
  ([start-pos : Pos]
   [end-pos : Pos]
   [message : String])
  #:transparent)
