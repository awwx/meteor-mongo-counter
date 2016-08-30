# konecty-mongo-counter

Atomic counters stored in MongoDB.

Incrementing a counter returns consecutive integers (1, 2, 3...), with
the counter stored in the database.

It is safe to make concurrent calls to `incrementCounter` and
`decrementCounter`.  If the current value of a counter is 6 and two
Meteor methods call `incrementCounter` at the same time, one will
receive 7 and the other 8.

This package is called <i>mongo</i>-counter because it works directly
with MongoDB's facilities for atomic updates; it doesn't go through
Meteor's collection code.  (Thus it only works with Meteor deployments
that use a MongoDB database.  If, for example, a SQL database was
being used instead, there would need to be a "sql-counter" package to
implement atomic counters in SQL).

Note that counters are *not* stored in a Meteor document: this package
doesn't increment a field in a document inside of a Meteor collection.
But when you increment or decrement a counter, you can take the new
value of the counter that is returned to you and store that value in a
Meteor document if you want.

Counters are not themselves a reactive data source, but you can store
the counter value into a reactive data source such as a Meteor
document whenever you increment or decrement a counter.


## Version

1.1.0

Meteor linker supported:
This implementation works with both pre-linker Meteor (0.6.4.1 and
below) and the new "linker" version of Meteor (0.6.5-rc12 and above).


## API

Note that this API is defined on the server only, and that these
functions are not defined in the client.  To access them from the
client, create a Meteor method on the server that calls the API,
and then call the method from the client.

Create a Meteor Collection to hold the counter. 

**Counters = new Mongo.Collection('counters');**

Pass the Counters collection to each of the API described below. 

### incrementCounter

**incrementCounter(collection, name, [amount])** &nbsp; *server*

Increments a database counter and returns the new value.

*Arguments*

<dl>
  <dt>collection: Meteor Collection</dt>
  <dd>The Collection that will hold all the Mongo Counters.</dd>

  <dt>name: string</dt>
  <dd>The name of the counter to increment.</dd>

  <dt>amount: integer</dt>
  <dd>The amount to increment the counter by, defaulting to one.</dd>
</dl>

Increments the counter named *name* in the database, and atomically
returns the new value.  New counters conceptually start at zero, so if
you increment a new counter by one you will receive one on the first
call.


### decrementCounter

**decrementCounter(collection, name, [amount])** &nbsp; *server*

Decrements a database counter and returns the new value.

*Arguments*

<dl>
  <dt>collection: Meteor Collection</dt>
  <dd>The Collection that will hold all the Mongo Counters.</dd>

  <dt>name: string</dt>
  <dd>The name of the counter to decrement.</dd>

  <dt>amount: integer</dt>
  <dd>The amount to decrement the counter by, defaulting to one.</dd>
</dl>

Decrements the counter named *name* in the database, and atomically
returns the new value.


### setCounter

**setCounter(collection, name, value)** &nbsp; *server*

Sets a counter.

*Arguments*

<dl>
  <dt>collection: Meteor Collection</dt>
  <dd>The Collection that will hold all the Mongo Counters.</dd>
  
  <dt>name: string</dt>
  <dd>The name of the counter to set.</dd>

  <dt>value: integer</dt>
  <dd>The value to set the counter to.</dd>
</dl>

Sets the counter to the specified value.

This is primarily useful for setting a new counter to an initial
value.  (If a counter was currently 10 and one method called
`incrementCounter` while another simultaneously called `setCounter`
with a value of 0, it would be indeterminate whether the first method
received 11 or 1).


## Using a counter for a humanly readable id

Counters can be used when you want to create a humanly readable
identifier that is guaranteed to be unique, such as an order or
invoice number.

Typically you wouldn't want to use a counter number as the _id of a
document, unless the document is only ever created on the server.

A pattern that works with creating documents in the client is to allow
Meteor to create its usual random string _id field, and then put the
humanly readable identifier in another field (such as "orderNumber")
with a method call to the server.  This allows the counter field to be
filled in when the client has a connection to the server, without
making the client wait if the Internet connection is momentarily slow
or disconnected.


## Implementation

This package implements the "Counters Collection" technique described
in the MongoDB documentation
[Create an Auto-Incrementing Sequence Field](http://docs.mongodb.org/manual/tutorial/create-an-auto-incrementing-field/#a-counters-collection).

Using the Mongo `findAndModify` method makes incrementing the counter
and reading the new value atomically safe.  (If we first incremented
the counter field using `update` and then read the new value using
`find`, two simultaneous calls to `incrementCounter` could increment
the counter twice and then both return the same doubly incremented
number).

Since Meteor doesn't yet support Mongo's `findAndModify`, the
implementation accesses Mongo directly without going through a Meteor
Collection.

The Mongo collection used to store counter values is
"awwx_mongo_counter".  Accessing this collection with
a Meteor Collection isn't recommended, because changes made by
`incrementCounter` aren't reported back to Meteor.
