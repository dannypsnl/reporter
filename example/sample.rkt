#lang racket

(require reporter)

(define s (report->text
           (report
            #:file-name "test.c" #:pos (Pos 4 10)
            #:message "type mismatching"
            #:labels (list
                      (label 4 10 17 "cannot assign a `string` to `int` variable"
                             #:color (color:red))
                      (label 4 6 7 "`x` is a `int` variable"
                             #:color (color:blue)))
            #:hint-message "expected type `int`, found type `string`"
            #:error-code "E0001")))
(print-text s)

