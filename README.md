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
    #:error-code "E0001"
    #:message "type mismatching"
    #:target srcloc?
    #:labels (list
               (label srcloc? "cannot assign a `string` to `int` variable"
                 #:color (color:red))
               (label srcloc? "`x` is a `int` variable"
                 #:color (color:blue)))
    #:hint "expected type `int`, found type `string`"
    )))
```
