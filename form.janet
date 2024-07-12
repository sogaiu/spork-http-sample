(import spork/http)

(defn main
  [_ &opt host port]
  (default host "127.0.0.1")
  (default port 8000)
  # https://developer.mozilla.org/en-US/docs/Web/HTML/Element/form
  # https://developer.mozilla.org/en-US/docs/Web/HTML/Element/textarea
  # https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/submit
  (def form-template
    ``
    <form action="/" method="post">
    <pre>
    <textarea name="text" rows="5" cols="72">%s</textarea>
    <input type="submit" value="send"/>
    </pre>
    </form>
    ``)
  #
  (defn body
    [value]
    (def result
      (cond
        (empty? value)
        ""
        #
        (string/has-prefix? `You said, "` value)
        (string/slice value
                      (length `You said, "`)
                      (- (length value) 1))
        #
        (string/format `You said, "%s"` value)))
    #
    (string/format form-template result))
  #
  (defn handler
    [request]
    (def key-vals
      (->> (get request :buffer)
           (peg/match http/query-string-grammar)
           first))
    (def received
      (get key-vals "text" "Nothing to see here..."))
    #
    {:headers {"Content-type" "text/html"}
     :status 200
     :body (body received)})
  #
  (printf "Trying to start server at %s:%d" host port)
  (http/server handler host port))
