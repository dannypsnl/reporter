#lang racket

(provide print-text)

(require ansi-color)
(require "text.rkt"
         "color.rkt")

(define (print-text t)
  (match t
    ([color-text c str]
     (parameterize ([foreground-color (color->atom c)])
       (color-display str)))
    ([? string?] (display t))
    ([? list?] (for-each
                (λ (t) (print-text t))
                t))))
