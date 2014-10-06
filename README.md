weatherApp

Stack:
Python/Flask
Coffeescript/SASS
MongoDB

Bower was used to convert SASS and Coffeescript files.

coffee/controller.coffee is the front-end controller file that talks to the other classes. Dastboard.coffee is where most of the code is.

The weather data was transformed in an iPython notebook called DC Data.ipynb. It loads the raw weather data called DC_Data.csv.
The transformed data is a .csv file called "aggedweather.csv" in the static directory.

The news data is dynamically scraped from https://archive.org/details/tv. That all happens in app.py.

==========
