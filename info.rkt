#lang info
(define collection "reporter")
(define deps '("base" "colorize" "typed-racket-lib"))
(define build-deps '("scribble-lib"
                     "racket-doc"
                     "rackunit-lib"
                     "c-utils"))
(define scribblings '(("scribblings/reporter.scrbl" ())))
(define pkg-desc "Description Here")
(define version "2.1")
(define pkg-authors '(dannypsnl))

(define compile-omit-paths '("example"))
