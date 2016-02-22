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
	it's still sponsored by Mozilla
- Mozilla is using Rust for the upcoming Firefox engine called [Servo](https://github.com/servo/servo)
- There is a [core team](https://github.com/rust-lang/rfcs/blob/master/text/1068-rust-governance.md)
	that decides over [RFC's](https://github.com/rust-lang/rfcs)

# Goals

- memory **safe**ty: no dangling-pointer, use after free
- **concurrent**: no data races
- **practical systems language**: low-level control like C, inline asm
- [**zero-cost abstractions**](http://blog.rust-lang.org/2015/05/11/   traits.html)
    - parametric polymorphism
    - type classes aka generics

---

- *C-like* languages:
    - more control over low-level resource management
    - less safe than managed languages (e.g. Java)
- *Managed* languages:
    - less control
    - more safety
- *Rust*:
    - balance safety and control

# Hello World

```rust
fn main() {
    println!("Hello world!")
}
```

