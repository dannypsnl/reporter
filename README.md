# reporter

Reporter is inspired from [codespan](https://github.com/brendanzab/codespan). The purpose of this project is to create a util toolbox for compiler error reporting.

![image](https://user-images.githubusercontent.com/22004511/83319528-e8440f00-a271-11ea-8d67-cca262a09862.png)

WARNING: The project still in an early stage!

### Installation

```racket
git clone https://github.com/racket-tw/reporter.git 
raco pkg install --auto
```

### Current API

```racket
(print-text
 (report->text
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
```
