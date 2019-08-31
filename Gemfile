source 'https://rubygems.org'
ruby "2.2.2"
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.2'

gem 'nokogiri', '~> 1.6', '>= 1.6.7.1'
gem 'savon'
#Mejor se colocó dentro del lib para editarla
#gem 'timbradocfdi'

#Para convertir un archivo html a pdf
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

#Gema que sirve para describir un número en palabras
gem "number_to_words"
#Para formar el CBB(Código de Barras Bidimenciona)
gem 'rqrcode_png'

#Para guardar los CFDIs en la nube
gem 'google-cloud-storage'
#gem 'google-cloud'

#Para enviar los documentos como archivos adjuntos por gmail
#gem 'mail'

gem 'gmail', '~> 0.6.0'

#Una biblioteca de Ruby para tratar con el dinero y la conversión de moneda.
gem 'money', '~> 6.13', '>= 6.13.1'

#Editor de texto basado en bootstrap
gem 'summernote-rails'

# Gemas que permiten subir imágenes al proyecto
gem 'carrierwave'

gem 'mini_magick'

gem 'fog'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

#gem 'compass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem "font-awesome-rails"

#gema para date picker
gem 'date_picker'

#Esta gema permite exportar un div a pdf
gem 'jspdf-rails'

#La gema devise se utiliza para la autenticación de usuarios
gem "devise"

#La gema cancancan determina las acciones que determinado rol de usuario puede realizar
gem "cancancan"

# Use jquery as the JavaScript library
gem 'jquery-rails'
#jquery ui para rails
#gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

#Necessary gem for use bootstrap inside rails application
gem 'bootstrap-sass', '~> 3.3.5'

gem 'autoprefixer-rails'

#Gema necesaria para mayor interacción con los datos de las tablas.
gem 'jquery-datatables-rails', '~> 3.4.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  #sqlite3 db for Active Record in development enviroment
  gem 'sqlite3', '~> 1.3', '>= 1.3.11'
  # Con esta gema se crean datos falsos de prueba
  gem 'faker', require: false
end

group :production do
   # Use postgresql as the database for Active Record in production
   gem 'pg' #se debe de instalar la dependencia faltante con: sudo apt-get install libpq-dev
end

gem 'rails_12factor', group: :production

gem 'unicorn'
