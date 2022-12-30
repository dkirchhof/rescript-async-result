type t<'ok, 'error> = promise<result<'ok, 'error>>
type error = {message: string}

module Promise = {
  @send external map: (promise<'a>, 'a => 'b) => promise<'b> = "then"
  @send external flatMap: (promise<'a>, 'a => promise<'b>) => promise<'b> = "then"
  @send external catch: (promise<'a>, error => 'b) => promise<'b> = "catch"
}

let ok = value => Js.Promise2.resolve(Ok(value))
let error = value => Js.Promise2.resolve(Error(value))

let fromPromise = (promise: promise<'ok>, mapError: error => 'error): t<'ok, 'error> =>
  promise->Promise.map(result => result->Ok)->Promise.catch(error => error->mapError->Error)

let fromResult = result => Js.Promise2.resolve(result)

let map = (ar, fn) =>
  ar->Promise.map(result => {
    fn(result)
  })

let mapOk = (ar: t<'ok, 'error>, fn: 'ok => 'ok2): t<'ok2, 'error> =>
  ar->Promise.map(result => {
    switch result {
    | Ok(value) => fn(value)->Ok
    | error => error
    }
  })

let mapError = (ar, fn) =>
  ar->Promise.map(result => {
    switch result {
    | Error(error) => fn(error)->Error
    | ok => ok
    }
  })

let flatMap = (ar: t<'ok, 'error>, fn: result<'ok, 'error> => t<'ok2, 'error2>): t<
  'ok2,
  'error2,
> => {
  ar->Promise.map(result => fn(result)->Obj.magic)
}

let flatMapOk = (ar: t<'ok, 'error>, fn: 'ok => t<'ok2, 'error2>): t<'ok2, 'error2> => {
  ar->Promise.map(result => {
    switch result {
    | Ok(value) => fn(value)->Obj.magic
    | error => error
    }
  })
}

let flatMapError = (ar: t<'ok, 'error>, fn: 'ok => t<'ok2, 'error2>): t<'ok2, 'error2> => {
  ar->Promise.map(result => {
    switch result {
    | Error(value) => fn(value)->Obj.magic
    | ok => ok
    }
  })
}

let tap = (ar: t<'ok, 'error>, fn: result<'ok, 'error> => unit): t<'ok, 'error> =>
  ar->Promise.flatMap(result => {
    fn(result)

    ar
  })

let tapOk = (ar: t<'ok, 'error>, fn: 'ok => unit): t<'ok, 'error> =>
  ar->Promise.flatMap(result => {
    switch result {
    | Ok(value) => fn(value)
    | _ => ()
    }

    ar
  })

let tapError = (ar: t<'ok, 'error>, fn: 'error => unit): t<'ok, 'error> =>
  ar->Promise.flatMap(result => {
    switch result {
    | Error(error) => fn(error)
    | _ => ()
    }

    ar
  })

let forEach = (ar, fn) => tap(ar, fn)->ignore
let forEachOk = (ar, fn) => tapOk(ar, fn)->ignore
let forEachError = (ar, fn) => tapError(ar, fn)->ignore
