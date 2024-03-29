# usages-as-tests

# includes various portions of (or inspiration from) bakpakin's:
#
# * helper.janet
# * jpm
# * path.janet
# * peg for janet

(import ./path :prefix "")
(import ./runner :prefix "")
(import ./utils :prefix "")

# from the perspective of `jpm test`
(def proj-root
  (path/abspath "."))

(defn deduce-src-root
  []
  (let [current-file (dyn :current-file)]
    (assert current-file
            ":current-file is nil")
    (let [cand-name (utils/no-ext (path/basename current-file))]
      (assert (and cand-name
                   (not= cand-name ""))
              (string "failed to deduce name for: "
                      current-file))
      cand-name)))

(defn suffix-for-judge-dir-name
  [runner-path]
  (assert (string/has-prefix? (path/join "test" path/sep) runner-path)
          (string "path must start with `test/`: " runner-path))
  (let [path-no-ext (utils/no-ext runner-path)]
    (assert (and path-no-ext
                 (not= path-no-ext ""))
            (string "failed to deduce name for: "
                    runner-path))
    (def rel-to-test
      (string/slice path-no-ext (length "test/")))
    (def comma-escaped
      (string/replace-all "," ",," rel-to-test))
    (def all-escaped
      (string/replace-all "/" "," comma-escaped))
    all-escaped))

(defn deduce-judge-dir-name
  []
  (let [current-file (dyn :current-file)]
    (assert current-file
            ":current-file is nil")
    (let [suffix (suffix-for-judge-dir-name current-file)]
      (assert suffix
              (string "failed to determine suffix for: "
                      current-file))
      (string ".uat_" suffix))))

# XXX: hack to prevent from running when testing
(when (nil? (dyn :usages-as-tests/test-out))
  (let [src-root (deduce-src-root)
        judge-dir-name (deduce-judge-dir-name)]
    (def stat (os/stat src-root))
    (unless stat
      (eprint "src-root must exist: " src-root)
      (os/exit 1))
    (unless (= :directory (stat :mode))
      (eprint "src-root must be a directory: " src-root)
      (os/exit 1))
    (let [all-passed (runner/handle-one
                       {:judge-dir-name judge-dir-name
                        :proj-root proj-root
                        :src-root src-root})]
      (when (not all-passed)
        (os/exit 1)))))
