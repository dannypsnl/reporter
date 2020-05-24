# reporter

Reporter is inspired from [codespan](https://github.com/brendanzab/codespan). The purpose of this project is to create a util toolbox for compiler error reporting.

### API draft

```racket
(report
  #:message "type mismatching"
  #:error-code "E0905"
  ;;; for example: `  int i = "hello";`
  #:primary-label (label (Pos 3 10) (Pos 3 16) #:message "cannot assign a `string` to `int` variable"))
```

Port should be optional as report output target. And
