# reporter

[![Racket](https://github.com/racket-tw/reporter/actions/workflows/racket.yml/badge.svg)](https://github.com/racket-tw/reporter/actions/workflows/racket.yml)

Reporter is inspired from [codespan](https://github.com/brendanzab/codespan). The purpose of this project is to create a util toolbox for compiler error reporting.

### Installation

```racket
raco pkg install --auto reporter
```

### Usage

#### Example

Take a look at [example](https://github.com/racket-tw/reporter/tree/develop/example).

#### Current API

```racket
#lang racket

(require reporter)

(displayln
 (report
   #:error-code "E0001"
   #:message "type mismatching"
   #:target srcloc?
   #:labels (list
              (label srcloc? "cannot assign a `string` to `int` variable"
                #:color 'red)
              (label srcloc? "`x` is a `int` variable"
                #:color 'blue))
   #:hint "expected type `int`, found type `string`"))

(displayln (warning #:message "shadow the variable"
                    #:target srcloc?
                    #:labels (list
                               (label srcloc? "previous definition" #:color 'green)
                               (label srcloc? "shadow definition" #:color 'blue))
                    #:hint "rename the shadow variable"))
```
