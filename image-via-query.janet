(import spork/http)

(defn image-handler
  [request]
  # get image name from query
  (def fname (get-in request [:query "name"]))
  # query contains name?
  (when (not fname)
    (break {:headers {"Content-type" "text/plain"}
            :status 400
            :body "No name found in query"}))
  # file exists?
  (when (not (os/stat fname))
    (break {:headers {"Content-type" "text/plain"}
            :status 404
            :body (string/format "Did not find %s" fname)}))
  # try to read image file
  (def [status result] (protect (slurp fname)))
  #
  (when (not status)
    (break {:headers {"Content-type" "text/plain"}
            :status 500
            :body (string/format "Failed to load %s" fname)}))
  #
  {:headers {"Content-type" "image/png"}
   :status 200
   :body result})

(defn main
  [_ &opt host port]
  (default host "127.0.0.1")
  (default port 8000)
  (printf "Trying to start server at %s:%d" host port)
  #
  (http/server image-handler host port))
