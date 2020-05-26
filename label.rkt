#lang typed/racket

(provide Label Label-start Label-end get-code)

(require racket/file)
(require "position.rkt"
         "string-helper.rkt")

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
              [msgs : (Listof String) (hash-ref! msg-collection label-line (λ () '()))]
              [start-col (Pos-column (Label-start label))]
              [end-col (Pos-column (Label-end label))]
              [msg (format "~a | ~a~a ~a"
                           (space-repeat (string-length (number->string label-line)))
                           (space-repeat start-col)
                           (string-repeat (- end-col start-col) "^")
                           (Label-msg label))])
         (hash-set! msg-collection
                    label-line
                    (append msgs (list msg)))))
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
              ; show current line
              (display (list-ref code-list (- line-number start-line)))
              ; show message for current line
              (for-each (λ ([msg : String])
                          (displayln msg))
                        (hash-ref! (Collection-messages c) line-number (λ () '()))))
            (range start-line (+ end-line 1)))
  (void))

(print-collection
 (aggregate-labels "test.c" (list (Label (Pos 4 10) (Pos 4 17) "cannot assign a `string` to `int` variable"))))
