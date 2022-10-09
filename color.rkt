#lang typed/racket
(provide Color Style)

(define-type Color (U 'red 'blue))
(define-type Style (U 'bold))
