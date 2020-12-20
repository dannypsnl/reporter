#lang typed/racket/base

(provide (struct-out Loc)
         srcloc->loc loc->string)

(require racket/match)

(struct Loc
  ([source : Path-String]
   [line : Integer]
   [column : Integer]
   [position : Integer]
   [span : Integer])
  #:transparent)

(: srcloc->loc (-> srcloc Loc))
(define (srcloc->loc s)
  (let* ([src (srcloc-source s)]
         [line (srcloc-line s)]
         [col (srcloc-column s)]
         [pos (srcloc-position s)]
         [span (srcloc-span s)])
    (unless (and line col pos span)
      (error 'invalid "invalid srcloc: ~a" s))
    (Loc (cast src Path-String) line col pos span)))

(: loc->string (-> Loc String))
(define (loc->string loc)
  (match-let ([(Loc src line col _ _) loc])
    (format "~a:~a:~a" src line col)))
