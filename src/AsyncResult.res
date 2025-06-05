type t<'ok, 'error> = promise<result<'ok, 'error>>
type error = {message: string}

module Promise = {
  @send external map: (promise<'a>, 'a => 'b) => promise<'b> = "then"
  @send external flatMap: (promise<'a>, 'a => promise<'b>) => promise<'b> = "then"
  @send external catch: (promise<'a>, error => 'b) => promise<'b> = "catch"
}

let ok = value => Js.Promise2.resolve(Ok(value))
let error = value => Js.Promise2.resolve(Error(value))

let fromPromise = (promise, mapError) =>
  promise->Promise.map(result => result->Ok)->Promise.catch(error => error->mapError->Error)

let fromAsyncFn = (fn, mapError) => {
  params =>
    params
    ->fn
    ->Promise.map(result => result->Ok)
    ->Promise.catch(error => error->mapError->Error)
}

let fromResult = result => Js.Promise2.resolve(result)

let fromOption = (option, error) => {
  switch option {
  | Some(value) => Ok(value)
  | None => Error(error)
  }->Js.Promise2.resolve
}

let map = (ar, fn) =>
  ar->Promise.map(result => {
    switch result {
    | Ok(value) => fn(value)->Ok
    | Error(error) => Error(error)
    }
  })

let mapError = (ar, fn) =>
  ar->Promise.map(result => {
    switch result {
    | Ok(ok) => Ok(ok)
    | Error(error) => fn(error)->Error
    }
  })

let mapBoth = (ar, mapError, mapOk) =>
  ar->Promise.map(result =>
    switch result {
    | Ok(value) => value->mapOk->Ok
    | Error(error) => error->mapError->Error
    }
  )

let flatMap = (ar, fn) => {
  ar->Promise.flatMap(result => {
    switch result {
    | Ok(value) => fn(value)
    | Error(error) => Error(error)->Js.Promise2.resolve
    }
  })
}

let flatMapError = (ar, fn) => {
  ar->Promise.flatMap(result => {
    switch result {
    | Ok(ok) => ok->Ok->Js.Promise2.resolve
    | Error(value) => fn(value)
    }
  })
}

/* let flatMapBoth = (ar, fn) => { */
/* ar->Promise.flatMap(result => fn(result)) */
/* } */

let tap = (ar, fn) =>
  ar->Promise.flatMap(result => {
    switch result {
    | Ok(value) => fn(value)
    | _ => ()
    }

    ar
  })

let tapError = (ar, fn) =>
  ar->Promise.flatMap(result => {
    switch result {
    | Error(error) => fn(error)
    | _ => ()
    }

    ar
  })

let tapBoth = (ar, tapError, tapOk) =>
  ar->Promise.flatMap(result => {
    switch result {
    | Ok(value) => tapOk(value)
    | Error(error) => tapError(error)
    }

    ar
  })

let forEach = (ar, fn) => tap(ar, fn)->ignore

let forEachError = (ar, fn) => tapError(ar, fn)->ignore

let forEachBoth = (ar, onError, onOk) => tapBoth(ar, onError, onOk)->ignore
