(import spork/http)

(defn main
  [_ &opt host port]
  (default host "127.0.0.1")
  (default port 8000)
  #
  (def link
    (string "https://english.stackexchange.com/questions/38837/"
            "where-does-this-translation-of-"
            "saint-exuperys-quote-on-design-come-from"))
  (def body
    (string/format `<a href="%s">Perfection is achieved when...</a>` 
                   link))
  (defn handler
    [request]
    {:headers {"Content-type" "text/html"}
     :status 200
     :body body})
  #
  (printf "Trying to start server at %s:%d" host port)
  (http/server handler host port))
