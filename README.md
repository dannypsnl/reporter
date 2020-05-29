# reporter

Reporter is inspired from [codespan](https://github.com/brendanzab/codespan). The purpose of this project is to create a util toolbox for compiler error reporting.

WARNING: The project still in an early stage!

### Installation

```racket
git submodule update --init
cd ./terminal-color/ && raco pkg install --auto && cd ..
raco pkg install --auto
```

### API draft

```racket
(report
  #:message "type mismatching"
  #:error-code "E0905"
  ;;; for example: `  int i = "hello";`
  #:primary-label (label (Pos 3 10) (Pos 3 16) #:message "cannot assign a `string` to `int` variable"))
```

### Current Status

![image](https://user-images.githubusercontent.com/22004511/83261463-f3555b80-a1ed-11ea-8048-5b4ff4849f47.png)
