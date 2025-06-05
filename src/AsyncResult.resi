type t<'ok, 'error> = promise<result<'ok, 'error>>
type error = {message: string}

module Promise: {
  @send external map: (promise<'a>, 'a => 'b) => promise<'b> = "then"
  @send external flatMap: (promise<'a>, 'a => promise<'b>) => promise<'b> = "then"
  @send external catch: (promise<'a>, error => 'b) => promise<'b> = "catch"
}

let ok: 'ok => t<'ok, 'error>
let error: 'error => t<'ok, 'error>
let fromPromise: (promise<'ok>, error => 'error) => t<'ok, 'error>
let fromAsyncFn: ('params => promise<'ok>, error => 'error) => 'params => t<'ok, 'error>
let fromResult: result<'ok, 'error> => t<'ok, 'error>
let fromOption: (option<'ok>, 'error) => t<'ok, 'error>

let map: (t<'ok, 'error>, 'ok => 'ok2) => t<'ok2, 'error>
let mapError: (t<'ok, 'error>, 'error => 'error2) => t<'ok, 'error2>
let mapBoth: (t<'ok, 'error>, 'error => 'error2, 'ok => 'ok2) => t<'ok2, 'error2>

let flatMap: (t<'ok, 'error>, 'ok => t<'ok2, 'error>) => t<'ok2, 'error>
let flatMapError: (t<'ok, 'ok>, 'ok => t<'ok, 'error2>) => t<'ok, 'error2>
/* let flatMapBoth: ( */
/*   t<'ok, 'error>, */
/*   'error => t<'ok2, 'error2>, */
/*   'ok => t<'ok2, 'error2>, */
/* ) => t<'ok2, 'error2> */

let tap: (t<'ok, 'error>, 'ok => unit) => t<'ok, 'error>
let tapError: (t<'ok, 'error>, 'error => unit) => t<'ok, 'error>
let tapBoth: (t<'ok, 'error>, 'error => unit, 'ok => unit) => t<'ok, 'error>

let forEach: (t<'ok, 'error>, 'ok => unit) => unit
let forEachError: (t<'ok, 'error>, 'error => unit) => unit
let forEachBoth: (t<'ok, 'error>, 'error => unit, 'ok => unit) => unit
