(defun mbj/java-pojo(properties indent indentLevel className)
  (defun indent(indent level)
    (make-string (* indent level) ?\s))

  (defun downcase-firstletter (s)
    (concat (downcase (substring s 0 1)) (substring s 1)))

  (defun upcase-firstletter (s)
    (concat (upcase (substring s 0 1)) (substring s 1)))  

  (defun to-replacements(property)
    (list
     (list "##type##" (car property))
     (list "##name##" (cadr property))
     (list "##Name##" (upcase-firstletter (cadr property)))))
  
  (defun apply-template(template replacements indent indentLevel)
    (defun at-inner(template replacements indent indentLevel)
      (if replacements
          (let ((replacement (car replacements))
                (case-fold-search nil)) ;; To make replace case sensitive
            (replace-regexp-in-string
             (car replacement)
             (cadr replacement)
             (at-inner template (cdr replacements) indent indentLevel)))
        template))
    (replace-regexp-in-string
     "##indent##"
     (indent indent 1)
     (replace-regexp-in-string
      "^"
      (indent indent indentLevel)
      (at-inner template replacements indent indentLevel))))

  (defun apply-for-each(func delimiter properties args)
    (defun afe-inner(func innerDelimiter properties args)
      (if properties
          (concat innerDelimiter
                  (apply func (car properties) args)
                  (afe-inner func delimiter (cdr properties) args))
        ""))
    (afe-inner func "" properties args))

  (defun field(property indent indentLevel)
    (apply-template
     "private ##type## ##name##;"
     (to-replacements property)
     indent
     indentLevel))

  (defun fields(properties indent indentLevel delimiter)
    (apply-for-each #'field delimiter properties (list indent indentLevel)))

  (defun getter(property indent indentLevel)
    (apply-template
     (concat "public ##type## ##getOrIs####Name##() {\n"
             "##indent##return ##name##;\n"
             "}")     
     (cons (list "##getOrIs##" (if (string= "boolean" (car property))
                                   "is"
                                 "get"))
           (to-replacements property))
     indent
     indentLevel))

  (defun getters(properties indent indentLevel delimiter)
    (apply-for-each #'getter delimiter properties (list indent indentLevel)))

  (defun setter(property indent indentLevel builderClassName className)
    (apply-template
     (concat "public ##builderClassName## ##name##(##type## ##name##) {\n"
             "##indent##this.##classNameField##.##name## = ##name##;\n"
             "##indent##return this;\n"
             "}")     
     (cons (list "##classNameField##" (downcase-firstletter className)) (cons (list "##builderClassName##" builderClassName) (to-replacements property)))
     indent
     indentLevel))

  (defun setters(properties indent indentLevel delimiter builderClassName className)
    (apply-for-each #'setter delimiter properties (list indent indentLevel builderClassName className)))

  (defun cloneSetter(indent indentLevel builderClassName className)
    (apply-template
     (concat "public ##builderClassName## ##classNameField##(##className## ##classNameField##) {\n"
             "##indent##this.##classNameField## = clone(##classNameField##);\n"
             "##indent##return this;\n"
             "}")     
     (list (list "##className##" className)
           (list "##builderClassName##" builderClassName)
           (list "##classNameField##" (downcase-firstletter className)))
     indent
     indentLevel))

  (defun build(indent indentLevel className)
    (apply-template
     (concat "public ##className## build() {\n"
             "##indent##return clone(##classNameField##);\n"
             "}")     
     (list (list "##className##" className)
           (list "##classNameField##" (downcase-firstletter className)))
     indent
     indentLevel))

  (defun clone(properties indent indentLevel className)
    (apply-template
     (concat "private ##className## clone(##className## ##classNameField##) {\n"
             "##indent####className## clone = new ##className##();\n"
             "##body##\n"
             "##indent##return clone;\n"             
             "}")     
     (list (list "##body##" (apply-for-each (lambda(property indent indentLevel)
                                              (apply-template
                                               "clone.##name## = ##classNameField##.##name##;"
                                               (cons (list "##classNameField##" (downcase-firstletter className)) (to-replacements property))
                                               indent
                                               1))
                                            "\n"
                                            properties
                                            (list indent indentLevel)))
           (list "##className##" className)
           (list "##classNameField##" (downcase-firstletter className)))
     indent
     indentLevel))
  

  (defun builder(properties indent indentLevel className)
    (concat
     (indent indent indentLevel) "public static class Builder {"
     "\n"
     (indent indent (+ 1 indentLevel)) "private " className " " (downcase-firstletter className) " = new " className "();"  
     "\n\n"
     (setters properties indent (+ 1 indentLevel) "\n\n" "Builder" className)
     "\n\n"
     (cloneSetter indent (+ 1 indentLevel) "Builder" className)
     "\n\n"     
     (build indent (+ 1 indentLevel) className)
     "\n\n"
     (clone properties indent (+ 1 indentLevel) className)
     "\n"     
     (indent indent indentLevel) "}"))

  (defun constructor(indent indentLevel className)
    (apply-template
     (concat "private ##className##() {\n"
             "}")     
     (list (list "##className##" className))
     indent
     indentLevel))

  (concat
   (indent indent indentLevel) "import java.io.Serializable;\n\n"
   (indent indent indentLevel) "public class " className " implements Serializable {"
   "\n"
   (indent indent (+ 1 indentLevel)) "private static final long serialVersionUID = 1L;"
   "\n"
   (fields properties indent (+ 1 indentLevel) "\n")
   "\n\n"
   (constructor indent (+ 1 indentLevel) className)
   "\n\n"
   (getters properties indent (+ 1 indentLevel) "\n\n")
   "\n\n"
   (builder properties indent (+ 1 indentLevel) className)
   "\n"
   (indent indent indentLevel) "}"))

(defun mbj/builder(beg end)
  "
Insert a java builder pattern class in buffer based on region looking like:
Myclass
String foo
int bar
"
  (interactive "*r")
  (defun parseProperties(propertyLines)
    (if propertyLines
        (cons (split-string (car propertyLines) " ") (parseProperties(cdr propertyLines)))
      '()))
  (save-excursion
    (let* ((regionLines (filter-buffer-substring beg end t))
           (lines (split-string regionLines "\n" t " +"))
           (className (car lines))
           (properties (parseProperties (cdr lines))))          
      (insert (mbj/java-pojo properties 4 0 className)))))

(provide 'builder-pattern-java)

;; (field '("String" "bar") 4 1)
;; (fields '(("String" "bar") ("int" "foo") ("Object" "baz")) 4 1 "\n")
;; (getters '(("String" "bar") ("int" "foo") ("Object" "baz")) 4 1 "\n\n")
;; (setters '(("String" "bar") ("int" "foo") ("Object" "baz")) 4 1 "\n\n" "MyClass")
;; (build '(("String" "bar") ("int" "foo") ("Object" "baz")) 4 1 "MyClass")
;; (constructor '(("String" "bar") ("int" "foo") ("Object" "baz")) 4 1 "MyClass")
;; (builder '(("String" "bar") ("int" "foo") ("Object" "baz")) 4 1 "MyClass")
;; (mbj/java-pojo '(("String" "bar") ("int" "foo") ("Object" "baz")) 4 2 "MyClass")
