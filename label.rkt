#lang typed/racket

(provide Label Label-start Label-end get-code
         collect-labels
         collection->text)

(require racket/file)
(require "position.rkt"
         "text.rkt")

(struct Label
  ([start : Pos]
   [end : Pos]
   [msg : String])
  #:transparent)

(: get-code (Path Integer Integer -> (Listof text)))
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
   [messages : (Mutable-HashTable Integer (Listof text))])
  #:transparent)

(: collect-labels (String (Listof Label) -> Collection))
(define (collect-labels file-name label-list)
  (define get-line (λ ([label : Label]) (Pos-line (Label-start label))))
  (define min-line (get-line (argmin get-line label-list)))
  (define max-line (get-line (argmax get-line label-list)))
  (let ([file-path (string->path file-name)]
        [msg-collection : (Mutable-HashTable Integer (Listof text)) (make-hash '())])
    (for-each
     (λ ([label : Label])
       (let* ([label-line (get-line label)]
              [msgs : (Listof text) (hash-ref! msg-collection label-line (λ () '()))]
              [start-col (Pos-column (Label-start label))]
              [end-col (Pos-column (Label-end label))]
              [msg (text-append*
                           ;;; align with line number string
                           (space-repeat (string-length (number->string label-line)))
                           " | "
                           ;;; provide space as column shifted
                           (space-repeat start-col)
                           ;;; repeat ^ to point out a part of code
                           ; for example:
                           ; 2 |     a = "hello";
                           ;   |         ^^^^^^^ cannot assign a `string` to `int` variable
                           (text-repeat (- end-col start-col) "^")
                           " "
                           (Label-msg label)
                           "\n")])
         (hash-set! msg-collection
                    label-line
                    (append msgs (list msg)))))
     label-list)
    (Collection file-path min-line max-line msg-collection)))

(: collection->text (Collection -> text))
(define (collection->text c)
  (define start-line (Collection-start-line c))
  (define end-line (Collection-end-line c))
  (define code-list (get-code (Collection-file-path c)
                              (Collection-start-line c)
                              (Collection-end-line c)))
  (text-append*
   (map (λ ([line-number : Integer])
          (text-append*
           ; show current line
           (list-ref code-list (- line-number start-line))
           ; show message for current line
           (hash-ref! (Collection-messages c) line-number (λ () '()))))
        (range start-line (+ end-line 1)))))
