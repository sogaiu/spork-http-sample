(import spork/http)

(defn image-handler
  [request]
  (def fname (get-in request [:query "name"]))
  # query contains name?
  (when (not fname)
    (break {:headers "Content-type: text/plain"
            :status 404 # XXX: likely better status code exists
            :body "No name found in query"}))
  # file exists?
  (when (not (os/stat fname))
    (break {:headers "Content-type: text/plain"
            :status 404 # XXX: likely better status code exists
            :body (string/format "Did not find %s" fname)}))
  #
  (with [img-f (file/open fname :rb)]
    (def data (file/read img-f :all))
    {:headers "Content-type: image/png"
     :status 200
     :body data}))

(defn main
  [_ &opt host port]
  (default host "127.0.0.1")
  (default port 8000)
  (printf "Trying to start server at %s:%d" host port)
  #
  (http/server image-handler host port))
