# Warning !

_style.css_, _style.css.map_, _style.min.css_, _style.min.css.map_, _bootstrap.min.css_ and _bootstrap.min.css.map_ are compiled files, you should never modify them directly. Instead, compile them as explain below.

# Compile SASS

In the theme folder modify the _style.scss_.
In the backend folder run **build:sass** to build style.min.css and **dev:sass** to build style.css

```
cd backend
npm run build:sass
npm run dev:sass
```

# Compile Bootstrap

In the theme folder modify the _bs3_variables.less_.

1. Download Bootstrap 3.4.1
   https://github.com/twbs/bootstrap/archive/v3.4.1.zip
2. Extract it and open it

```
cd bootstrap-3.4.1
```

3. Install dependencies

```
npm install
```

4. Copy the content of a bs3_variables.less to /bootstrap-3.4.1/less/variables.less

```
bs3_variables.less is in the theme folder e.g. /cagette/app/www/theme/cagette/css/bs3_variables.less
```

5. In the bootstrap repo run grunt dist to compile

```
grunt dist
```

6. Copy the generated files (bootstrap.min.css and bootstrap.min.css.map) to the theme folder

```
from /bootstrap-3.4.1/dist/css to /cagette/app/www/theme/cagette/css
```

More infos :

https://getbootstrap.com/docs/3.3/getting-started/#grunt
