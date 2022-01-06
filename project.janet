(declare-project
  :name "usages-as-tests"
  :url "https://github.com/sogaiu/usages-as-tests"
  :repo "git+https://github.com/sogaiu/usages-as-tests.git")

# XXX: not sure if doing this is a good idea...

(put (dyn :rules) "build" nil)
(phony "build" []
       (os/execute ["janet"
                    "support/build.janet"] :p))

(put (dyn :rules) "clean" nil)
(phony "clean" []
       (os/execute ["janet"
                    "support/clean.janet"] :p))

