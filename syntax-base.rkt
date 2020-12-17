#lang racket/base

(require "c-parser.rkt")
(require megaparsack megaparsack/text)

(parse-string (syntax-box/p statement/assign/p) "foo = true + 1;")
