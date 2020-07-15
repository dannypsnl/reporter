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
(: label (->*  (#:line Integer #:from Integer #:to Integer String) (#:color (Option color)) Label))
(define (label #:line line #:from column-start #:to column-end msg #:color [color #f])
  (let ([start-pos (Pos line column-start)]
        [end-pos (Pos line column-end)])
    (Label start-pos end-pos msg color)))

(define (get-code [file-path : Path]
                  [show-lines : (Listof Integer)])
  : (Listof text)
  (let ([lines : (Listof String) (file->lines file-path)])
    (map
     (λ ([line-number : Integer])
       (let* ([line-ref (- line-number 1)]
              [cur-line (list-ref lines line-ref)])
         (format "~a | ~a~n" line-number cur-line)))
     show-lines)))

(struct Collection
  ([file-path : Path]
   ;;; pointed-lines stores a list of pointed line number
   ; pointed line means has labels on it
   ; !!! Must be a sorted list
   [pointed-lines : (Listof Integer)]
   [messages : (Mutable-HashTable Integer (Listof text))])
  #:transparent)

(define (Label-color-text [label : Label])
  : text
  (let* ([start-col (Pos-column (Label-start label))]
         [end-col (Pos-column (Label-end label))]
         [point-out (string-append* (make-list (- end-col start-col) "^"))]
         [label-msg (Label-msg label)]
         [color (Label-color label)])
    (if color
        (text-append* (color-text color point-out)
                      " "
                      (color-text color label-msg))
        (text-append* point-out
                      " "
                      label-msg))))
(define (collect-labels [file-name : String]
                        [label-list : (Listof Label)])
  : Collection
  (define get-line (λ ([label : Label]) (Pos-line (Label-start label))))
  (define pointed-lines : (Listof Integer)
    '())
  (let ([file-path (string->path file-name)]
        [msg-collection : (Mutable-HashTable Integer (Listof text)) (make-hash '())])
    (for-each
     (λ ([label : Label])
       (let* ([label-line (get-line label)]
              [msgs (hash-ref! msg-collection label-line (λ () '()))]
              [msg (text-append*
                    ;;; align with line number string
                    (space-repeat (string-length (number->string label-line)))
                    " | "
                    ;;; provide space as column shifted
                    (space-repeat (Pos-column (Label-start label)))
                    ;;; repeat ^ to point out a part of code
                    ; for example:
                    ; 2 |     a = "hello";
                    ;   |         ^^^^^^^ cannot assign a `string` to `int` variable
                    (Label-color-text label)
                    "\n")])
         (if (memv label-line pointed-lines)
             (void)
             (set! pointed-lines (append pointed-lines (list label-line))))
         (hash-set! msg-collection
                    label-line
                    (append msgs (list msg)))))
     label-list)
    (Collection file-path
                pointed-lines
                msg-collection)))

(: collection->text (Collection -> text))
(define (collection->text c)
  (define show-lines (Collection-pointed-lines c))
  ;;; code-list should exact same as pointed lines
  (define code-list (get-code (Collection-file-path c) show-lines))
  (define start-line
    (if (empty? show-lines)
        0
        (car show-lines)))
  (text-append*
   (map (λ ([line-number : Integer])
          (text-append*
           ; show current line
           (list-ref code-list (- line-number start-line))
           ; show message for current line
           (hash-ref! (Collection-messages c) line-number (λ () '()))))
        show-lines)))
