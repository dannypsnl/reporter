#lang typed/racket

(require racket/file)
(require "position.rkt")

(: print-code (String Pos Pos -> Void))
(define (print-code file-name start end)
  (letrec ([file-path : Path (string->path file-name)]
           [lines : (Listof String) (file->lines file-path)])
    (for-each
     (λ ([line-number : Integer])
       (let ([cur-line (list-ref lines line-number)])
         (printf "~a~n" cur-line)))
     (range (- (Pos-line start) 1) (Pos-line end)))))

(print-code "test.c" (Pos 4 2) (Pos 4 5))
