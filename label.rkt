#lang typed/racket

(provide label
         Label Label-start Label-end get-code
         collect-labels
         collection->text)

(require racket/file)
(require "position.rkt"
         "color.rkt"
         "text.rkt")

(struct Label
  ([start : Pos]
   [end : Pos]
   [msg : String]
   [color : (Option color)])
  #:transparent)
(: label (->*  (Pos Pos String) (#:color (Option color)) Label))
(define (label start end msg #:color [color #f])
  (Label start end msg color))

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
              [msgs (hash-ref! msg-collection label-line (λ () '()))]
              [start-col (Pos-column (Label-start label))]
              [end-col (Pos-column (Label-end label))]
              [color (Label-color label)]
              [point-out (string-append* (make-list (- end-col start-col) "^"))]
              [label-msg (Label-msg label)]
              [color-text (if color
                              (text-append* (color-text color point-out)
                                            " "
                                            (color-text color label-msg))
                              (text-append* point-out
                                            " "
                                            label-msg))]
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
                    color-text     
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
