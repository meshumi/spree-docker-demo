# Layer 0. Качаем образ Debian OS с установленным ruby версии 2.5 и менеджером для управления gem'ами bundle из DockerHub. Используем его в качестве родительского образа.
FROM ruby:2.5-slim

# Layer 1. Задаем пользователя, от чьего имени будут выполняться последующие команды RUN, ENTRYPOINT, CMD и т.д.
USER root

# Layer 2. Обновляем и устанавливаем нужное для Web сервера ПО
RUN apt-get update -qq && apt-get install -y \
   build-essential libpq-dev libxml2-dev libxslt1-dev nodejs imagemagick apt-transport-https curl nano vim wget

# Layer 3. Сохраняем в переменную окружения путь внутри Docker образа к нашему приложению
ENV APP_HOME /home/www/spreedemo

# Layer 4. Создаем и указываем рабочую директорию /home/www/spreedemo в качестве рабочей директории. Теперь команды RUN, ENTRYPOINT, CMD будут запускаться с этой директории.
WORKDIR $APP_HOME

# Layer 5. Добавляем файлы Gemfile и Gemfile.lock из директории, где лежит Dockerfile (root директория приложения) в root директорию WORKDIR
COPY Gemfile Gemfile.lock ./

# Layer 6. Вызываем команду по установке gem-зависимостей.

# При отсутствии изменений на предыдущих шагах. А именно, если содержание файлов Gemfile и Gemfile.lock не изменились, то данная команда не будет выполнена, поскольку текущий слой будет браться из кэша.
RUN bundle check || gem install nokogiri -v '1.8.4' --source 'https://rubygems.org/'
RUN bundle check || gem install nio4r -v '2.3.1' --source 'https://rubygems.org/'
RUN bundle check || gem install websocket-driver -v '0.7.0' --source 'https://rubygems.org/'
RUN bundle check || gem install bcrypt -v '3.1.12' --source 'https://rubygems.org/'
RUN bundle check || gem install bindex -v '0.5.0' --source 'https://rubygems.org/'
RUN bundle check || gem install ffi -v '1.9.25' --source 'https://rubygems.org/'
RUN bundle check || gem install byebug -v '10.0.2' --source 'https://rubygems.org/'
RUN bundle check || gem install hiredis -v '0.6.1' --source 'https://rubygems.org/'
RUN bundle check || gem install pg -v '1.1.3' --source 'https://rubygems.org/'
RUN bundle check || gem install puma -v '3.12.0' --source 'https://rubygems.org/'
RUN bundle check || bundle install

# Layer 7. Копируем все содержимое директории приложения в root-директорию WORKDIR
COPY . .

# Layer 8. Даем www-data пользователю права owner'а на необходимые директории
RUN mkdir /var/www && \
   chown -R www-data:www-data /var/www && \
   chown -R www-data:www-data "$APP_HOME/."

# Layer 9. Указываем все команды, которые будут выполняться от имени www-data пользователя. Поскольку по умолчанию Docker запускаем контейнер от имени root пользователя, то настоятельно рекомендуется задать отдельного пользователя c определенными UID и GID и запустить процесс от имени этого пользователя.
USER www-data

# Layer 10. Запускаем команду для компиляции статических (JS и CSS) файлов
RUN bundle exec rake assets:precompile

# Layer 11. Указываем команду по умолчанию для запуска будущего контейнера. По скольку в `Layer 9` мы переопределили пользователя, то puma сервер будет запущен от имени www-data пользователя.
CMD bundle exec puma -C config/puma.rb
