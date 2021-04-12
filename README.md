# KeyServer

## Problem Statement
Write a server which can generate random api keys, assign them for usage and release them after sometime. Following endpoints should be available on the server to interact with it.

* E1. There should be one endpoint to generate keys.

* E2. There should be an endpoint to get an available key. On hitting this endpoint server should serve a random key which is not already being used. This key should be blocked and should not be served again by E2, till it is in this state. If no eligible key is available then it should serve 404.

* E3. There should be an endpoint to unblock a key. Unblocked keys can be served via E2 again.

* E4. There should be an endpoint to delete a key. Deleted keys should be purged.

* E5. All keys are to be kept alive by clients calling this endpoint every 5 minutes. If a particular key has not received a keep alive in last five minutes then it should be deleted and never used again.

Apart from these endpoints, following rules should be enforced:

* R1. All blocked keys should get released automatically within 60 secs if E3 is not called.
No endpoint call should result in an iteration of whole set of keys i.e. no endpoint request should be O(n). They should either be O(lg n) or O(1).

## Endpoints
*  **/generateKeys/:noOfKeys?**

Generates new random keys based upon the number of keys introduced if not provided then 5 keys will be created and will be added to the current set of unblocked keys.

*  **/unblock/:key**

Replace :key with any of the blocked keys to unblock it.

*  **/delete/:key**

Replace :key with any of the keys to delete it.

Note: After deleting it can't be blocked.

*  **/keepAlive/:key**

Replace :key with any of the keys to refresh the timer.

i.e

1. If a key is in unblocked state, then it will remain in unblocked state for 5 minutes.
2. If a key is in blocked state, then it will remain in blocked state for 1 min(=60 secs) and 4 more minutes in unblocked until the next ping or block request.

* **/fetchKey**

Returns a random key from the set of unblocked keys

## Installation

Installing all the  required dependencies

```
$ bundle install
```

## How to run?

Start the server
```
$ rackup -p <required port>
```

Follow the web server endpoints description and ping on the respective endpoints from any web client (Ex. Browser, Curl etc.)
Endpoints will be served on `http://localhost:port/`

## How to run tests?

```
$ bundle exec rspec --format documentation --color
```