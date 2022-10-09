### Current

### v2.0.0

- use `'blue` to configure color, old functions are removed
- NOTE: use `colorize` to replace `ansi-color`
- adjust spacing for code printing (ref #22)
- `collect-report` and `current-report-collection` make report collecting easier

  ```racket
  (collect-report
    ;; usage
    ...)

  ;; get all current report
  (current-report-collection)
  ```

### v1.1.0

- remove `report->text` and `print-text`, and let `(displayln report?)` work

### v1.0.1

- (#18) keep line order

### v1.0.0

- collect multiple labels that points to same line

### v0.2.0

- remove position API and related program

### v0.1.0

- `report`
- `report->text`
- `label`
- `color:red`
- `color:blue`
- `print-text`
