#lang typed/racket
(provide Color Style)

(define-type Color (U 'red 'blue 'yellow 'green))
(define-type Style (U 'bold))
