#lang typed/racket

(provide label label*->text
         (struct-out Label))

(require racket/file)
(require "loc.rkt"
         "color.rkt"
         "text.rkt")

(struct Label
  ([target : Loc]
   [msg : String]
   [color : (Option color)])
  #:transparent)
(: label (->*  (srcloc String) (#:color (Option color)) Label))
(define (label target msg #:color [color #f])
  (Label (srcloc->loc target) msg color))

(: label*->text (-> (Listof Label) text))
(define (label*->text label*)
  (define t : (Listof text) '())
  (let* ([line* (loc*->line* label*)]
         [line=>label* (label*->map label*)]
         [unique-line* (list->set line*)])
    (for ([pos (set->list unique-line*)])
      (define code (get-code (car pos) (cdr pos)))
      (define label (hash-ref line=>label* pos))
      (define cur-t : text (cons code (map Label->text label)))
      (set! t (append t (list cur-t)))))
  t)

(: loc*->line* (-> (Listof Label) (Listof (Pairof Path-String Integer))))
(define (loc*->line* label*)
  (map (lambda ([label : Label]) (cons (Loc-source (Label-target label)) (Loc-line (Label-target label)))) label*))
(: label*->map (-> (Listof Label) (HashTable (Pairof Path-String Integer) (Listof Label))))
(define (label*->map label*)
  (define m : (Mutable-HashTable (Pairof Path-String Integer) (Listof Label)) (make-hash))
  (for ([label label*])
    (let* ([target (Label-target label)]
           [src (Loc-source target)]
           [line (Loc-line target)]
           [key (cons src line)]
           [prev : (Option (Listof Label)) (hash-ref m key #f)])
      (if prev
        (hash-set! m key (append prev (list label)))
        (hash-set! m key (list label)))))
  m)

(define (get-code [src : Path-String] [line : Integer])
  : String
  (let* ([lines : (Listof String) (file->lines src)]
         [line-ref (- line 1)]
         [cur-line (list-ref lines line-ref)])
    (format "~a | ~a~n" line cur-line)))

(define (Label->text [label : Label])
  : text
  (match-let* ([(Label target msg color?) label]
               [(Loc src line col _ span) target])
    (let ([msg (format "~a ~a" (string-append* (make-list span "^")) msg)])
      (text-append* (space-repeat (string-length (number->string line)))
                    " | "
                    (space-repeat col)
                    (if color? (color-text color? msg) msg)
                    "\n"))))
