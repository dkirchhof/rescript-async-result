type t<'ok, 'error> = promise<result<'ok, 'error>>
type error = {message: string}

%%private(@send external then: (Js.Promise2.t<'a>, 'a => 'b) => Js.Promise2.t<'b> = "then")
%%private(@send external catch: (Js.Promise2.t<'a>, error => 'b) => Js.Promise2.t<'b> = "catch")

/* let make = () => */
/* Js.Promise.make((~resolve, ~reject as _) => { */
/* resolve(. Ok("hello")) */
/* }) */

let ok = value => Js.Promise2.resolve(Ok(value))
let error = value => Js.Promise2.resolve(Error(value))

let fromPromise = (promise: promise<'ok>, mapError: error => 'error): t<'ok, 'error> =>
  promise->then(result => result->Ok)->catch(error => error->mapError->Error)

let fromResult = result => Js.Promise2.resolve(result)

let map = (ar, fn) =>
  ar->then(result => {
    fn(result)
  })

let mapOk = (ar: t<'ok, 'error>, fn: 'ok => 'ok2): t<'ok2, 'error> =>
  ar->then(result => {
    switch result {
    | Ok(value) => fn(value)->Ok
    | _ => ar->Obj.magic
    }
  })

let mapError = (ar, fn) =>
  ar->then(result => {
    switch result {
    | Error(error) => fn(error)->Error
    | _ => ar->Obj.magic
    }
  })

let flatMap = (ar: t<'ok, 'error>, fn: result<'ok, 'error> => t<'ok2, 'error2>): t<
  'ok2,
  'error2,
> => {
  ar->then(result => fn(result)->Obj.magic)
}

let flatMapOk = (ar: t<'ok, 'error>, fn: 'ok => t<'ok2, 'error2>): t<'ok2, 'error2> => {
  ar->then(result => {
    switch result {
    | Ok(value) => fn(value)->Obj.magic
    | _ => ar->Obj.magic
    }
  })
}

let flatMapError = (ar: t<'ok, 'error>, fn: 'ok => t<'ok2, 'error2>): t<'ok2, 'error2> => {
  ar->then(result => {
    switch result {
    | Error(value) => fn(value)->Obj.magic
    | _ => ar->Obj.magic
    }
  })
}

let tap = (ar, fn) =>
  ar->then(result => {
    fn(result)

    ar
  })

let tapOk = (ar, fn) =>
  ar->then(result => {
    switch result {
    | Ok(value) => fn(value)
    | _ => ()
    }

    ar
  })

let tapError = (ar, fn) =>
  ar->then(result => {
    switch result {
    | Error(error) => fn(error)
    | _ => ()
    }

    ar
  })

let forEach = (ar, fn) => tap(ar, fn)->ignore
let forEachOk = (ar, fn) => tapOk(ar, fn)->ignore
let forEachError = (ar, fn) => tapError(ar, fn)->ignore

/* let testPromise = Js.Promise2.make((~resolve, ~reject) => resolve(. "hello")) */
/* let testPromise = Js.Promise2.make((~resolve, ~reject) => reject(. Js.Exn.raiseError("hello"))) */
/* let testPromise = Js.Promise2.make((~resolve, ~reject) => resolve(. Js.Exn.raiseError("hello"))) */

/* testPromise */
/* ->fromPromise */
/* ->mapOk(Js.String.length) */
/* ->mapError(error => "ERROR: " ++ error) */
/* ->forEach(result => { */
/* Js.log(result) */
/* }) */
