#lang typed/racket

(provide string-repeat space-repeat)

(: string-repeat (Integer String -> String))
(define (string-repeat n str)
  (string-append* (make-list n str)))
(: space-repeat (Integer -> String))
(define (space-repeat n)
  (string-repeat n " "))
