(defun pace (h m s km)
  (let* ((totalSeconds (+ (* h 3600) (* m 60) s))
         (minutes (truncate (/ totalSeconds km 60)))
         (seconds (round (mod (/ totalSeconds (* km 1.0)) 60))))
    (concat (number-to-string minutes) ":" (number-to-string seconds) " min/km")))

(provide 'pace)
