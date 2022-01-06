(import ./input :prefix "")
(import ./name :prefix "")
(import ./to-test :prefix "")
(import ./validate :prefix "")

(defn generate/handle-one
  [opts]
  (def {:input input
        :output output} opts)
  # read in the code
  (def buf (input/slurp-input input))
  (when (not buf)
    (eprint)
    (eprint "Failed to read input for: " input)
    (break false))
  # light sanity check
  (when (not (validate/valid-code? buf))
    (eprint)
    (eprint "Failed to parse input as valid Janet code: " input)
    (break false))
  # output rewritten content
  (def rewritten
    (try
      (to-test/rewrite-as-test-file buf)
      ([err]
        (eprintf "rewrite failed")
        nil)))
  (when (nil? rewritten)
      (break false))
  (if (not= "" output)
    (spit output rewritten)
    (print rewritten))
  true)

# since there are no tests in this comment block, nothing will execute
(comment

  (def file-path "./generate.janet")

  # output to stdout
  (generate/handle-one {:input file-path
                        :output ""})

  # output to file
  (generate/handle-one {:input file-path
                        :output (string "/tmp/"
                                        name/prog-name
                                        "-test-output.txt")})

  )
