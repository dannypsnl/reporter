#lang typed/racket

(provide text color-text
         text-append*
         print-text
         (all-from-out "color.rkt"))

(require/typed terminal-color
               [display-color (String #:fg Symbol -> Void)])
(require "color.rkt")

(define-type text (U color-text String (Listof text)))
(struct color-text
  ([color : color]
   [text : String])
  #:transparent)

(: text-append* (text * -> text))
(define (text-append* . ts)
  ts)

(: print-text (text -> Void))
(define (print-text t)
  (match t
    ([color-text color str]
     (let ([c-atom (match color
                     ([color:red] 'red)
                     ([color:blue] 'blue)
                     )])
       (display-color str #:fg c-atom)
       ))
    ([? string?] (display t))
    ([? list?] (for-each
             (λ ([t : text]) (print-text t))
             t))))
