(import spork/http)

###################################################################

(defn choose
  [items seed]
  (def index (mod seed (length items)))
  (get items index))

###################################################################

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
    #
    {:headers "Content-type: image/png"
     :status 200
     :body data}))

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
   # XXX: gets garbled
   #"老子"
   #"道可道，非常道。名可名，非常名。"
   })

(defn quote-handler
  [request]
  (def who
    (cond
      (get-in request [:query "random"])
      (choose (keys quotes) (hash request))
      #
      (def found (get-in request [:query "who"]))
      found
      #
      (choose (keys quotes) (hash request))))
  #
  {:headers "Content-type: text/plain"
   :status 200
   :body (get quotes who "You must have goofed up somewhere...")})

###################################################################

(defn default-handler
  [request]
  (def page
    ``
    <!DOCTYPE html>
    <head>
      <meta charset="utf-8">
      <title>spork/http router demo</title>
    </head>
    <html>
      <body>
        <ul>
          <li><a href="/images?name=janet.png">image</a>
          <li><a href="/quotes?random">some quote</a>
        </ul>
      </body>
    </html>
    ``)
  #
  {:headers "Content-type: text/html"
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

