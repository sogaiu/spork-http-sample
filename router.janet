(import spork/http)

###################################################################

(defn choose
  [items seed]
  (def index (mod seed (length items)))
  (get items index))

###################################################################

(def tp-headers
  {"Content-type"
   "text/plain; charset=utf-8"})

###################################################################

(defn image-handler
  [request]
  (def fname (get-in request [:query "name"]))
  # query contains name?
  (when (not fname)
    (break {:headers tp-headers
            :status 400
            :body "No name found in query"}))
  # file exists?
  (when (not (os/stat fname))
    (break {:headers tp-headers
            :status 404
            :body (string/format "Did not find %s" fname)}))
  # try to read image file
  (def [status result] (protect (slurp fname)))
  #
  (when (not status)
    (break {:headers tp-headers
            :status 500
            :body (string/format "Failed to load %s" fname)}))
  #
  {:headers {"Content-type" "image/png"}
   :status 200
   :body result})

###################################################################

(def quotes
  {"berra"
   "You can observe a lot by watching."
   #
   "franklin"
   "A place for everything, everything in its place."
   #
   "socrates"
   "I drank what?"
   #
   "seneca"
   "If one knows not to which port one sails, no wind is favorable."
   #
   "老子"
   "道可道，非常道。名可名，非常名。"
   })

(defn quote-handler
  [request]
  (when (get-in request [:query "redirect"])
    (def who (choose (keys quotes) (hash request)))
    (break {:headers
            (merge tp-headers
                   {"Location"
                    (string/format "/quotes?who=%s" who)})
            :status 302}))
  #
  (def who
    (cond
      (get-in request [:query "some"])
      (choose (keys quotes) (hash request))
      #
      (def found (get-in request [:query "who"]))
      found
      #
      (choose (keys quotes) (hash request))))
  #
  {:headers tp-headers
   :status 200
   :body (get quotes who "You must have goofed up somewhere...")})

###################################################################

(defn default-handler
  [request]
  (def page
    ``
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <title>spork/http router demo</title>
      </head>
      <body>
        <ul>
          <li><a href="/images?name=janet.png">image via query</a>
          <li><a href="/quotes?some">some quote</a>
          <li><a href="/quotes?redirect">some quote via redirect</a>
        </ul>
      </body>
    </html>
    ``)
  #
  {:headers {"Content-type"
             "text/html; charset=utf-8"}
   :status 200
   :body page})

###################################################################

(def routes
  {"/images" image-handler
   "/quotes" quote-handler
   :default default-handler})

(defn router-handler
  [request]
  (def handler (http/router routes))
  (handler request))

###################################################################

(defn main
  [_ &opt host port]
  (default host "127.0.0.1")
  (default port 8000)
  (printf "Trying to start server at %s:%d" host port)
  #
  (http/server router-handler host port))

