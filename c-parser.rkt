;;; from https://github.com/racket-tw/cc/ via MIT License
#lang racket

(provide statement/assign/p)

(require data/monad data/applicative)
(require megaparsack megaparsack/text)

(define lexeme/p
  ;;; lexeme would take at least one space or do nothing
  (do (or/p (many+/p space/p) void/p)
    (pure (λ () 'lexeme))))
(define (keyword/p keyword)
  (do (string/p keyword)
    (lexeme/p)
    (pure keyword)))
(define -identifier/p
  (do [id <- (many+/p letter/p)]
    (lexeme/p)
    (pure (list->string id))))
(define identifier/p (syntax/p -identifier/p))

(define expr/int/p
  (do [v <- (syntax/p integer/p)]
    (pure v)))
(define expr/bool/p
  (do [v <- (syntax/p (or/p (string/p "true") (string/p "false")))]
    (pure v)))
(define unary/p
  (do [expr <- (or/p expr/bool/p
                     expr/int/p)]
    (lexeme/p)
    (pure expr)))
(define (op/p lst)
  (or/p (one-of/p lst)
        void/p))
(define (binary/p high-level/p op-list)
  (do [e <- high-level/p]
    [es <- (many/p (do [op <- (op/p op-list)]
                     (lexeme/p)
                     [e <- high-level/p]
                     (pure (list op e))))]
    (pure (foldl
           (λ (op+rhs lhs)
             (match op+rhs
               [(list op rhs)
                `(BINARY ,op ,lhs ,rhs)]))
           e es))))
(define (table/p base/p list-of-op-list)
  (if (empty? list-of-op-list)
      base/p
      (table/p (binary/p base/p (car list-of-op-list)) (cdr list-of-op-list))))
(define expr/p
  (table/p unary/p
           '((#\* #\/)
             (#\+ #\-))))

(define statement/assign/p
  (do [name <- identifier/p]
    (char/p #\=)
    (lexeme/p)
    [expr <- expr/p]
    (char/p #\;)
    (lexeme/p)
    (pure `(Assign ,name ,expr))))
