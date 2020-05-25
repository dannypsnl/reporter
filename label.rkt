#lang typed/racket

(provide Label Label-start Label-end get-code)

(require racket/file)
(require "position.rkt")

(struct Label
  ([start : Pos]
   [end : Pos]
   [msg : String])
  #:transparent)

(: get-code (Path Integer Integer -> (Listof String)))
(define (get-code file-path start end)
  (let ([lines : (Listof String) (file->lines file-path)])
    (map
     (λ ([line-number : Integer])
       (let* ([line-ref (- line-number 1)]
              [cur-line (list-ref lines line-ref)])
         (format "~a | ~a~n" line-number cur-line)))
     (range start (+ 1 end)))))

(struct Collection
  ([file-path : Path]
   [start-line : Integer]
   [end-line : Integer]
   [messages : (Mutable-HashTable Integer (Listof String))])
  #:transparent)

(: aggregate-labels (String (Listof Label) -> Collection))
(define (aggregate-labels file-name label-list)
  (define get-line (λ ([label : Label]) (Pos-line (Label-start label))))
  (define min-line (get-line (argmin get-line label-list)))
  (define max-line (get-line (argmax get-line label-list)))
  (let ([file-path (string->path file-name)]
        [msg-collection : (Mutable-HashTable Integer (Listof String)) (make-hash '())])
    (for-each
     (λ ([label : Label])
       (let* ([label-line (get-line label)]
              [msgs : (Listof String) (hash-ref! msg-collection label-line (λ () '()))])
         (hash-set! msg-collection
                    label-line
                    (append msgs (list (Label-msg label))))))
     label-list)
    (Collection file-path min-line max-line msg-collection)))

(: print-collection (Collection -> Void))
(define (print-collection c)
  (define start-line (Collection-start-line c))
  (define end-line (Collection-end-line c))
  (define code-list (get-code (Collection-file-path c)
                              (Collection-start-line c)
                              (Collection-end-line c)))
  (for-each (λ ([line-number : Integer])
              (displayln (list-ref code-list (- line-number start-line)))
              (displayln (hash-ref! (Collection-messages c) line-number (λ () '()))))
            (range start-line (+ end-line 1)))
  (void))

(print-collection
 (aggregate-labels "test.c" (list (Label (Pos 4 2) (Pos 4 5) "cannot assign a `string` to `int` variable"))))
