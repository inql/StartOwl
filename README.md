# StartOwl
![](https://github.com/inql/StartOwl/workflows/Scala%20API%20Test/badge.svg)
![](https://github.com/inql/StartOwl/workflows/Perform%20tests%20on%20API%20and%20publish%20Docker%20image%20on%20AWS/badge.svg)
![](https://github.com/inql/StartOwl/workflows/Deploy%20Frontend%20on%20Github%20Pages/badge.svg)

Project Mateusz Małecki + Dawid Bińkuś
## Description
TBD
## Usage
To run backend API, enter root directory of project and do:

``
sbt run
``

After that wait for the following output:

``
[INFO] [11/13/2019 22:51:25.463] [run-main-0] [akka.actor.ActorSystemImpl(actor-system)] Server started: start-owl-api at 0.0.0.0:8001
``

Configuration is stored in conf/application.conf file, where host IP address and port might be changed if needed.
With server started, one can receive particular data using POST request to the server.
Example using curl

``
$ curl -d '{"domains":"[path_to_rss_file]", "keyword":["a"], "searchModeInput":"contains"}' -H "Content-Type: application/json" -X POST http://localhost:8001/searchrequest
``

The StartOwl API is now available on Azure

Available addresses:

[https://startowl.azurewebsites.net](https://startowl.azurewebsites.net)

Link to docker:

[![dockeri.co](https://dockeri.co/image/inql/start-owl-api)](https://hub.docker.com/r/inql/start-owl-api)
- [inql/start-owl-api](https://hub.docker.com/r/inql/start-owl-api)

## Project Structure
TBD
## Sources
* [scala-scraper](https://github.com/ruippeixotog/scala-scraper)
* [Akka](https://akka.io/)
* [Akka Quickstart](https://doc.akka.io/docs/akka/current/typed/guide/introduction.html?language=scala)
