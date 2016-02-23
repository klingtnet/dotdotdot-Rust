% Rust - A quick introduction
% Andreas Linz
% Mo 22. Feb 14:06:14 CET 2016

# Agenda

1. Language Goals and History
1. How to get Rust
1. Concepts
1. Syntax
1. Examples

# History

- started in 2006 as a side project of [Graydon Hoare](https://github.com/graydon)
- [Mozilla](https://www.mozilla.org/en-US/) got involved in 2009
- Rust is mainly developed by a diverse community of enthusiasts but 
	it's still sponsored by Mozilla and Samsung
- Mozilla is using Rust for the upcoming parallel layout engine for Firefox called [Servo](https://github.com/servo/servo)
- There is a [core team](https://github.com/rust-lang/rfcs/blob/master/text/1068-rust-governance.md)
	that decides over [RFC's](https://github.com/rust-lang/rfcs)

---

- *C-like* languages (C, C++, D, ...):
    - more control over low-level resource management
		 - flat data structures, raw pointers
    - less safe than managed languages
- *Managed* languages (Python, Ruby, Haskell, Java ...):
    - less control
		- no flat data structures, string has always length and char elements etc.
    - more safety
- *Rust*:
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

- not possible in Rust, compiler keeps track of object lifetime

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
- no data races:
    - one mutable **OR**
    - many readable references to a variable
- details later

# Goals

- memory **safe**ty: no dangling-pointer, use after free
- **concurrent**: no data races
- **practical systems language**: low-level control like C, inline asm
- [**zero-cost abstractions**](http://blog.rust-lang.org/2015/05/11/traits.html)
    - parametric polymorphism
    - type classes aka generics

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

# Hello World

```rust
fn main() {
    println!("Hello world!")
}
```

# Ownership

- variable bindings have ownership of what they're bound to
- when a binding goes out of scope its resources are freed
- Rust ensures that there is exactly **one** binding to any resource ([playpen](http://is.gd/cum1c3))

```rust
let v = vec![1,2,3];
let v2 = v;
println!("{}", v[0]);
// will not compile, use of moved value
```

- solution: handback ownership ([playpen](http://is.gd/iM00NQ)), would get very tedious
- real soultion: [borrowing](https://doc.rust-lang.org/book/references-and-borrowing.html)

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
- `let mut x = 3;` mutable binding to `3`;
- *borrowing rules*:
	1. one or more references `&T` to a resource
	1. exactly one mutable reference `&mut T`
- only `1.` or `2.` but not both at a time
- [playpen](http://is.gd/jB4bck)

# Macros

- work on the AST
- generate valid code

# Shameless Self-Promotion

- writing my masters thesis (a realtime audio synthesizer in Rust)
- [github.com/klingt.net](https://github.com/klingtnet)
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
