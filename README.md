<img src="www/title.png" 
        alt="Title" 
        width="900" 
        height="500" 
        style="display: block; margin: 0 auto;" />

Welcome to our second-semester R project!

We're in first year of a **Master**'s program and we're creating a Takuzu game interface (also known as Binairo) using the [Shiny library](https://github.com/rstudio/shiny) available in the **RStudio** IDE.

---

## 🕹️ Game rules

Takuzu and Sudoku are somewhat similar: numbers into a grid, , but this time you'll only come across *1*s and *0*s, in 4x4, 6x6 or 8x8 grids!

The rules are as follows:
- You can't have more than two *1*s (respectively *0*s) following, vertically and horizontally;
- You must have the same count of *1*s and *0*s in each column and each row (eg. in a 6x6 game, there are three *1*s and three *0*s);
- You can't have the same column or the same row twice.

We hope you enjoy your time playing this pink lolita themed Takuzu game as much as we enjoyed creating it!

---

## ⚙️ Requirements

To run the application in your **R** based IDE, you will need some packages:
```r
install.packages(c('shiny', 'shinyjs', 'Rcpp'))
```
***Shiny*** represents the entire basis of this project. It allows us to create various UIs (User Interfaces) and render them in a single reactive/responsive server.

***ShinyJS*** has a number of useful features that can be combined with Shiny. We use this package to display each user interface at different times.

***Rcpp*** lets us write *C++* functions directly in our R project, making the logic part of the game much faster and a little more aesthetically pleasing.

---

## 🧮 Team members

Our team counts two students:
- [**Laura CLETZ**](https://github.com/lcletz)
- [**Kateryna STETSUN**](https://github.com/KatyaStetsun)
 
This R programming course and project is supervised by [**Jean-Michel MARIN**](https://imag.umontpellier.fr/~marin/).

---

## 📄 License 

This project is licensed under **MIT** license.  

For more details, please consult the [LICENSE](https://github.com/KatyaStetsun/Takuzu_game/blob/main/LICENSE) file.  
