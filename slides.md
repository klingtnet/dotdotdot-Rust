% Rust - A quick introduction
% Andreas Linz
% Mo 22. Feb 14:06:14 CET 2016

# Agenda

1. History
1. Concepts
1. Syntax / Language Features
1. Concurrency / FFI
1. Questions

# History

- started in 2006 as a side project of [Graydon Hoare](https://github.com/graydon)
- [Mozilla](https://www.mozilla.org/en-US/) got involved in 2009
- Rust is mainly developed by a diverse community of enthusiasts but 
	it's still sponsored by Mozilla and Samsung
- Mozilla is using Rust for the upcoming parallel ~~layout~~ browser engine for Firefox called [Servo](https://github.com/servo/servo)
- There is a [core team](https://github.com/rust-lang/rfcs/blob/master/text/1068-rust-governance.md)
	that decides over [RFC's](https://github.com/rust-lang/rfcs)

---

- **C-like** languages (C, C++, D, ...):
    - **more control** over low-level resource management
		 - flat data structures, raw pointers
    - less safe than managed languages
- **Managed** languages (Python, Ruby, Haskell, Java ...):
    - **less control**
		- no flat data structures, string has always length and char elements etc.
    - more safety
- **Rust**:
    - balance safety and control

# Safety

- use after free in C:

```C
int main(void) {
    char* ptr = malloc(SOME_SIZE);
    //...
    free(ptr);
    // undefined behaviour
    printf("%s\n", s);
}
```

- not possible in Rust, compiler keeps track of object lifetime ([playpen](https://play.rust-lang.org/))

```rust
fn main() {
	let s = "something".to_string();
	// move s -> s will get destroyed when it's out of scope
	println!("{}", s);
}
// 10:21 error: use of moved value: `s` [E0382]
```

# Control

- memory location of a variable value
	- function stack if the size is known at compile time (`Sized` trait)
	- heap `Box<T>`
	- Rust supports Dynamically Sized Types [DST](https://doc.rust-lang.org/nomicon/exotic-sizes.html)s as well (as fat pointers: data+context):
		- trait objects (some type that implements a specific trait (~interface))
		- array slices (view into an array)
- deterministic destruction
	- fine-grained control over resource lifetime

# What about Garbage Collection?

- no control
- requires runtime ➔ unsuitable for tiny embedded devices
- GC pause ➔ latency problems (problematic for realtime/multimedia applications)
- insufficient to prevent related problems:
	- iterator invalidation (modyfing while iterating)
	- data races

# Ownership / Borrowing

- zero runtime cost
- all static analysis
- no data races
	- **data race**: Two unsynchronized threads accessing the same data where at least one writes.
- details later

# Goals

- memory **safe**ty: no dangling-pointer, use after free
- **concurrent**: no data races
- **practical systems language**: low-level control like C, inline asm
- [**zero-cost abstractions**](http://blog.rust-lang.org/2015/05/11/traits.html)
    - parametric polymorphism (aka *generics*)
	- iterators
	- data race free concurrency

---

> C++ implementations obey the zero-overhead principle: What you don’t use, you don’t pay for [Stroustrup]

# Zero-Cost Abstractions

- monomorphisation of generics
	- compiler generates highly optimized code for each type, e.g. `Vec<int>` or `Vec<String>`
	- static dispatch
- iterators are compiled to loops
- function inlining

# Features

- statically typed
- compiled to native binary code
- high-level/functional features without overhead (zero-cost abstractions)
	- iterators
	- map/(fold/reduce)
	- closures
- optional garbage collection (part of the STL)

# Ownership

- variable bindings have ownership of what they're bound to
- when a binding goes out of scope its resources are freed
- Rust ensures that there is exactly **one** binding to any resource ([playpen](http://is.gd/cum1c3))

> Ownership is the *right to destroy* [(Yehuda Katz)](https://www.youtube.com/watch?v=uCaYkUmdtPw)

---

```rust
let v = vec![1,2,3];
let v2 = v;
println!("{}", v[0]);
// will not compile, use of moved value
```

- solution: handback ownership ([playpen](http://is.gd/iM00NQ)), would get very tedious
- real solution: [borrowing](https://doc.rust-lang.org/book/references-and-borrowing.html)

# References & Borrowing

- `&T` reference to type T
- does not **own** the referenced resource, therefore it isn't deallocated when the reference goes out of scope

```rust
fn f(v: &Vec<i32>) {
	// do something
}

fn main() {
	let v = vec![42];
	f(&v);
	println!("{}", v[0]);
}
```

---

- variable bindings and references are **immutable** by default
- `&mut T` mutable reference to type T
- `let mut x = 3; // mutable binding to 3`
- *borrowing rules*:
	1. one or more references `&T` to a resource (*shared borrow*)
	1. exactly one (even across threads) mutable reference `&mut T` (*mutable borrow*)
- only `1.` or `2.` but not both at a time
- [playpen](http://is.gd/jB4bck)
- more details, see [this talk](https://youtu.be/d1uraoHM8Gg?t=825) by [Alex Chryton](https://github.com/alexcrichton)

---

> **Shared mutable state is the root of all evil.**

> Most languages attempt to deal with this problem through the 'mutable' part, but Rust deals with it by solving the 'shared' part.

# Hello World

- variable binding: `let x: i32 = 3;` (type can be inferred most of the time)
- mutable variable binding: `let mut ...`
- reference to a resource: `&x` or `&mut x`
- function definition `fn f(arg: T1) -> T2 {}`

```rust
fn world() -> &'static str {
	"world"
}

fn main() {
    println!("Hello {}!", world());
}
```

---

- statements are delimited by an `;`
- two types of statements:
	1. binding statement: `let x = 1;`
	1. *expression* statement: `x + 3;`
- a block (everything between `{`, `}`) is an expression
- the RHS of a `let` binding can be any type of expression (block, match ...)
- tuple assignments (because the LHS of a binding is [pattern](https://doc.rust-lang.org/book/patterns.html))
- [playpen](http://is.gd/vknsSt)

# Strings

- two main types:
	- string slices: `&str`, reference to a statically allocated string
	- growable *heap* allocated string: `String`
- UTF-8 by default
- [playpen](http://is.gd/RfXjCV)

# Enums

- a type with **variants**

```rust
// a practical example
enum Option<T> {
    None,
    Some(T),
}

// an arbitrary example
enum ErrorKind {
	Recoverable,
	Warn(String),
	Fatal{msg: String, trace: Stacktrace),
}
```

---

- an enum match **must** cover all cases (Rust enforces this)
- [playpen](http://is.gd/NipGns)

```rust
fn f(e: ErrorKind) {
	match e {
		Warn(msg) => println!("{}", msg),
		_ => unimplemented!(),
	}
}
```

# if-else if-else

- nothing unusual

```rust
if x < 42 {
	println!("Not the answer to all questions, but close.");
} else if x == 42 {
	println!("You got it!");
} else {
	println!("A bit too much.");
}
```

- I prefer to use `match` wherever possible
- [playpen](http://is.gd/VU5E9z)

# for / loop

- also nothing special, except that you can loop over ranges

```rust
// for var in expression
for x in 5..10 {
	println!("{}", x);
}

let v = vec!['a', 'b', 'c'];
for c in v {
	print!("{}", c);
}
// prints "abc"
```

- keyword for infinite loops: `loop` is equal to `while true`
- [playpen](http://is.gd/EdgP6Z)

# Iterators

- iterators are lazy (evaluated when used)
	- can be infinite, `(0..3).cycle()` is an iterator that yields `0,1,2,0,1,2,...`
	- you have to *consume* the iterator to get the final result of some operation on the set of values. The most common one is `collect()`, which consumes the whole iterator.
- ranges are iterators too: `let v = (0..10).collect::<Vec<_>>::();`
- for math geeks: [iterator cheatsheet](https://danielkeep.github.io/itercheat_baked.html)

---

- map/reduce with iterators (reduce and fold mean the same thing)
- types must implement the `Iterator` trait to be iterable
	- only one function: `fn next(&mut self) -> Option<T>`

- [playpen](http://is.gd/U3mXdV)

```rust
let v: Vec<f32> = vec![1.0, 33.0, -23.4];
let avg = v.iter().fold(0.0, |acc, val| (acc + val)/l);
```

---

- Iterators are more than syntactic sugar in Rust, because the ownership and borrowing rules ensure that there is no **iterator invalidation**
- iterator invalidation can occur when your program modifies the structure (deleting elements, freeing memory, ...) while iterating over it

# Traits

- *composition* over inheritance (avoid the [diamond problem](https://en.wikipedia.org/wiki/Multiple_inheritance#The_diamond_problem), [LWN article](https://lwn.net/Articles/548560/))
- you can think of *traits* as *interfaces*
- traits can be implemented on *structs* using `impl TraitName`
- [playpen](http://is.gd/BYH4F5)

```rust
trait Area {
	fn area(&self) -> f64;
}

impl Area for Rect {
	fn area(&self) -> f64 {
		self.a * self.b
	}
}
```

# Closures

- functions are first-class language elements
- closures come in three flavours: `FnOnce`, `Fn`, `FnMut`
    - you won't use `FnOnce` directly, at least not very often
- [playpen](http://is.gd/kXWNFl)

```rust
let cl = |x, y| {x+y};
println!("{}", cl(3,2));
```


# Generics

- **static dispatch**:
	- compiler generates specialized version from generics for each T that is fed into the function
	- zero runtime cost
	- specialized versions are as fast as hand coded (use intrinsics when possible, etc.)

> What you do use, you couldn’t hand code any better. \[Stroustrup\]

---

- [playpen](http://is.gd/StM1Wg)

```rust
fn add<T: Add>(x: T, y: T) -> T::Output {
	x + y
}

fn main() {
	println!("{}", add(3i32, 4i32));
}
```

---

- **dynamic dispatch**:
	- precise type only known at compile time
	- can't be monomorphised by the compiler (type erasure)

```rust
struct S<T: Foo> {
	elements: Vec<Box<T>>,
}
```

# Concurrency

## Messaging (Message Passing)

- pass ownership of messages between threads
- transfer ownership of message to the channel
	- sender can't access message after send
- [playpen](http://is.gd/4L3WSz)

---

## Shared read-only access

- concurrent access to a large array (image, sound, etc.)
- `Arc<T>` atomically reference counted
	- `Rc<T>` is the non-thread safe equivalent, which can't be transferred between threads, because it doens't implement the `Send` trait
	- non thread-safe types can't leave thread boundaries (checked at compile time)
- `Arc` *owns* the data, only allows *shared reference* (not mutable), therefore no data races
- [playpen](http://is.gd/4dHS1q)

---

## Locked mutable access (mutexes)

- concurrent writable access (synced via mutexes) to some data

```rust
fn f(mutex: &Mutex<Vec<i32>>) {
	let mut guard = mutex.lock();
	guard.push(42);
	// lock is automatically released
	// as soon as it gets out of scope
}
```

- [playpen](http://is.gd/aY62sH)

# Macros

- work on the AST
- generate valid code
- TODO

# FFI

- Rust let you expose functions through a `C` ABI
- `extern "C" fn f()` declares that function `f` should use the `C` ABI
	- the `"C"` is optional, there will be other ABIs available
- almost every language can call external C functions (Ruby, Python, Haskell, ...)
- you can call external functions from Rust as well
- [examples](https://github.com/alexcrichton/rust-ffi-examples)
- enough stuff for a seperate talk

# Cargo

- Rust's package manager, home: [crates.io](https://crates.io/)
- reproducible builds (resolves transient dependencies, ...)
- create a new project: `cargo new NAME` (library), `cargo new --bin NAME`
- runs tests, benchmarks examples ...
- no need for a *complicated* `Makefile`
- project configuraiton `Cargo.toml` (TOML > YAML, not whitespace sensitive)

# Multirust

- provides Rust toolchain, [installation instructions](https://github.com/brson/multirust#quick-installation)
- Minor version releases every 6 weeks
- stable, beta and nightly channel
- set the channel: `multirust default stable`

# Shameless Self-Promotion

- writing my masters thesis (a realtime audio synthesizer in Rust)
- [github.com/klingtnet](https://github.com/klingtnet)
- looking for a job (after finishing my MA, probably July 2016)

---

- I also write code in:
    - Python (LPUG member)
    - Go
    - Java
    - (a bit) C/PHP/Javascript

---

- other technologies I use/like:
    - HTML5, SASS, CSS, ...
    - Linux/SystemD
    - docker
    - nginx
    - bash/zsh, make, git, vim ...
- find me at [klingt.net](https://klingt.net) (needs an update)

# Questions?
