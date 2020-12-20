# reporter

Reporter is inspired from [codespan](https://github.com/brendanzab/codespan). The purpose of this project is to create a util toolbox for compiler error reporting.

![image](https://user-images.githubusercontent.com/22004511/102704792-cfa55000-42ba-11eb-96db-0c35258ec7ee.png)

### Installation

```racket
raco pkg install --auto reporter
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
    #:hint "expected type `int`, found type `string`")))
```
