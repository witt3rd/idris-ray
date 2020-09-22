# Ray Tracing in One Weekend in Idris

Adapted from the mini-book [_Ray Tracing in One Weekend_](https://raytracing.github.io/books/RayTracingInOneWeekend.html) by Peter Shirley.

## Goals

Simple: **to learn**! Specifically, [Idris](https://www.idris-lang.org/) through recreational coding of a small, yet realistic project.  Each episode will highlight or solve a new challenge along the learning path, including defining custom types, dealing with effects, handling cyclic imports, etc.

The intent of this series is to supplement the excellent material provided in the _Ray Tracing in One Weekend_ series, not to replace it.  Please follow along in the corresponding sections of the source material.

I have made all this material open in the hopes that **you will contribute** by commenting, submitting pull requests and issues.  Let's all get better together!

### Why Idris?

- Cutting-edge language: dependently typed, purely functional

In functional programming (FP), the primary abstractions are _types_ and _functions_.  In addition to functions accepting and returning values of specific types, functions themselves are _first-class_.  This means that functions can be passed to functions as arguments and returned from functions.

In a dependently-type language like Idris, types themselves are first-class.  This means that functions can produce and consume types and those types can depend on the values of other types.  This is incredibly powerful and allows us to rely on the type system to provide strong guarantees about the validity of our programs, leading to fewer bugs.

I have collected a number of Idris coding patterns (i.e., minimum working examples) in an [_Idris Cookbook_](https://gist.github.com/witt3rd/b21167c133d3e9db925561d1d64d0395) for many of the topics discussed throughout this series.  Please feel free to comment and add to the collection.

### Why ray tracing?

- Visual: providing immediate (and satisfying) feedback
- Progression: from very basic to very sophisticated
- Non-trivial and real: file I/O, effects (RND), interfaces, cyclic imports, performance
- Fun!

## Overview

Follow the same outline of the book, covering the topics and porting to Idris.

- [Output an Image](02_Output_an_Image.md)
- [Vectors and Colors](03_Vectors_and_Color.md)
