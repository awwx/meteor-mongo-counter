# autoincrement-counter

Autoincrementing sequence counters stored in MongoDB.

An autoincrementing sequence returns consecutive integers (1, 2,
3...), with the counter stored in the database.

It is safe to make concurrent calls to `incrementCounter`.  If the
current value of a counter is `6` and two Meteor methods call
`incrementCounter` at the same time, one will receive `7` and the
other `8`.


## Version

1.0.0


## API

incrementCounter(name) *server*

Increments a database counter and returns the new value.

*Arguments*

<dl>
  <dt><b>name</b> string</dt>
  <dd>The name of the counter to increment.</dd>
</dl>

Increments the counter named *name* in the database, and atomically
returns the new value.  Returns `1` for a new counter.


## Usage

Autoincrementing counters are useful in situations where you want to
create a humanly readable identifier that is guaranteed to be unique,
such as an order or invoice number.

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
[http://docs.mongodb.org/manual/tutorial/create-an-auto-incrementing-field/#a-counters-collection](Create an Auto-Incrementing Sequence Field).

Using the Mongo `findAndModify` method makes incrementing the counter
and reading the new value atomically safe.  (If we first incremented
the counter field using `update` and then read the new value using
`find`, two simultaneous calls to `incrementCounter` could increment
the counter twice and then both return the same doubly incremented
number).

Since Meteor doesn't yet support Mongo's `findAndModify`, the
implementation accesses Mongo directly without using a Meteor
Collection.

The Mongo collection used to store counter values is
"awwx_autoincrement_counter".  Accessing this collection with
a Meteor Collection isn't recommended, because changes made by
`incrementCounter` aren't reported back to Meteor.


## Support

Do you find this package useful?  Would you like to see it continue to
be maintained?  :-)

Make a weekly contribution of your own choice to supporting this
package with [Gittip](https://www.gittip.com/awwx/).

Not sure what to give?  While the amount is entirely up to you, a
weekly contribution of $1 is entirely reasonable if you're relying on
this package for something important, such as a commercial endeavor.
25&cent; is a cool amount for a personal contribution.
