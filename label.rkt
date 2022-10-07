#lang racket/base
(provide label
         label*->text
         get-max-line
         (struct-out Label))
(require racket/file
         racket/match
         racket/set
         racket/string
         racket/list)
(require "loc.rkt"
         "color.rkt"
         "text.rkt")

(struct Label
  (target
   msg
   color?)
  #:transparent)
(define (label target msg #:color [color #f])
  (Label (srcloc->loc target) msg color))

(define (get-max-line label*)
  (apply max (map (compose Loc-line Label-target) label*)))

(define (label*->text label* pre-code-shift)
  (define t '())
  (let* ([line* (loc*->line* label*)]
         [line=>label* (label*->map label*)]
         [unique-line* (list->set line*)])
    (for ([pos (sort (set->list unique-line*) <
                     #:key cdr)])
      (define code (get-code (car pos) (cdr pos) pre-code-shift))
      (define label (hash-ref line=>label* pos))
      (define cur-t (cons code (map (lambda (l) (Label->text l pre-code-shift)) label)))
      (set! t (cons cur-t t))))
  (reverse t))

(define (loc*->line* label*)
  (map (lambda (label)
         (cons (Loc-source (Label-target label))
               (Loc-line (Label-target label))))
       label*))

(define (label*->map label*)
  (define line=>label (make-hash))
  (for ([label label*])
    (let* ([target (Label-target label)]
           [src (Loc-source target)]
           [line (Loc-line target)]
           [key (cons src line)]
           [prev (hash-ref line=>label key #f)])
      (if prev
          ; a line can have many labels
          (hash-set! line=>label key (append prev (list label)))
          (hash-set! line=>label key (list label)))))
  line=>label)

(define (get-code src line pre-code-shift)
  (let* ([lines (file->lines src)]
         [line-ref (- line 1)]
         [cur-line (list-ref lines line-ref)])
    (list (color-text (color:blue) (format "~a" line))
          (space-repeat (- pre-code-shift
                           (string-length (number->string line))))
          (color-text (color:blue) "|")
          (format " ~a~n" cur-line))))

(define (Label->text label pre-code-shift)
  (match-let* ([(Label target msg color?) label]
               [(Loc src line col _ span) target])
    (let ([msg (format "~a ~a" (string-append* (make-list span "^")) msg)])
      (text-append* (space-repeat (sub1 pre-code-shift))
                    (color-text (color:blue) " | ")
                    ; code part
                    (space-repeat col)
                    (if color? (color-text color? msg) msg)
                    "\n"))))
