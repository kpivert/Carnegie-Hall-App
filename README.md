# Carnegie-Hall-App
**How did they get to Carnegie Hall?** 
By [Nathan (Nate) Day](https://github.com/nathancday) and [Kurtis Pivert](https://github.com/kpivert)

Submission for the [Shiny Contest 2020](https://community.rstudio.com/t/shiny-contest-2020-is-here/51002).

“How do you get to Carnegie Hall?” Musicians would tell you it isn’t a cab to 57th and 7th but [“Practice, Practice, Practice.”](https://www.carnegiehall.org/Blog/2016/04/The-Joke) This Shiny dashboard demonstrates how far each the >8000 individual performers traveled in order to grace the stage at Carnegie Hall in New York.

Using data from the [Carnegie Hall Database](https://github.com/CarnegieHall/linked-data), users can explore performers by their continent of birth, search the table to find a specific performer and learn more about their journey through available resources. This [Shiny dashboard](https://shiny.rstudio.com) uses an interactive [plotly](https://plotly.com) map to filter data on >8000 musicians, conductors, singers, dancers, and even ventriloquists who have performed at New York’s Carnegie Hall over its 129-year history. The application uses the [mapdeck package](https://symbolixau.github.io/mapdeck/index.html) to harness the power of the [deck.gl JavaScript library](https://deck.gl/#/) for developing stunning interactive GIS visualizations. 

**Resources Used in App Development**

* [Carnegie Hall Linked Data](https://github.com/CarnegieHall/linked-data)
* [Carnegie Hall Query Builder](http://data.carnegiehall.org/sparql/#?query=SELECT%20*%20WHERE%20%7B%0A%20%20%3Fsubject%20%3Fproperty%20%3Fobject%0A%7D%20LIMIT%20100&writer=browse)
* Resources for Learning SPARQL
    * [Apache Jena Tutorial](https://jena.apache.org/tutorials/sparql_basic_patterns.html)
    * [Presentation: Joins in SPARQL](http://www.cs.utexas.edu/~cannata/cs345/New%20Class%20Notes/15%20JoinsinSPARQL%20(3).pdf) by Andrew Oldag

