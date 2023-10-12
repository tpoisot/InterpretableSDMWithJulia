# Let's build an interpretable SDM (with Julia!)

[![Static Badge](https://img.shields.io/badge/License-CC--BY-green)][ccby] [![Static Badge](https://img.shields.io/badge/View_on-github_pages-skyblue)][slides]

💻 ➕ 🌦️ ➕ 🦝 ➕ 🧠 🟰 😁

This repository has the code associated to the "Interpretable SDM from scratch" workshop.

> Give some [feedback]!

[slides]: https://tpoisot.github.io/InterpretableSDMWithJulia/
[ccby]: https://creativecommons.org/licenses/by/4.0/
[feedback]: https://github.com/tpoisot/InterpretableSDMWithJulia/issues/new?labels=feedback

In order to *run* the code, you need

- quarto (v. 1.4 has been tested)
- julia (v. 1.9 has been tested)

and you would benefit from

- VSCode *or*
- jupyter

> **Note that** running the code might take a while, because it will get a few thousand occurrences from GBIF, and download the full CHELSA1 variables (only once) -- for this reason, whenever it makes sense, the code is multi-threaded
