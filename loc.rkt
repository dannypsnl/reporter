#lang typed/racket/base

(provide Loc srcloc/syntax->loc loc->string)

(require racket/match)
(require/typed racket/base
               [srcloc->string (srcloc -> String)])

(struct Loc
  ([source : Any]
   [line : Integer]
   [column : Integer]
   [position : Integer]
   [span : Integer])
  #:transparent)

(: srcloc/syntax->loc (-> (U srcloc Syntax) Loc))
(define (srcloc/syntax->loc s)
  (let* ([syn? (syntax? s)]
         [src (if syn? (syntax-source s) (srcloc-source s))]
         [line (if syn? (syntax-line s) (srcloc-line s))]
         [col (if syn? (syntax-column s) (srcloc-column s))]
         [pos (if syn? (syntax-position s) (srcloc-position s))]
         [span (if syn? (syntax-span s) (srcloc-span s))])
    (unless (and line col pos span)
      (error 'invalid "invalid srcloc or syntax: ~a" s))
    (Loc src line col pos span)))

(: loc->string (-> Loc String))
(define (loc->string loc)
  (match-let ([(Loc src line col _ _) loc])
    (format "~a:~a:~a" src line col)))

(module+ test
  (require typed/rackunit)

  (test-case
    "Syntax -> Loc"
    (define syn (datum->syntax #f 'a (list 'file 1 2 3 4)))
    (check-equal? (Loc-line (srcloc/syntax->loc syn)) (syntax-line syn)))

  (test-case
    "srcloc -> Loc"
    (define src (srcloc 'file 1 2 3 4))
    (check-equal? (Loc-line (srcloc/syntax->loc src)) 1)))
