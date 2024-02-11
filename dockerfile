FROM php:7.4-cli

WORKDIR /opt

# Copiando o diretório do projeto para o diretório de trabalho no contêiner
COPY application /opt

# Instalando dependências e extensões PHP necessárias
RUN apt update && \
    apt install -y libzip-dev && \
    docker-php-ext-install zip

# Baixando o Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'edb40769019ccf227279e3bdd1f5b2e9950eb000c3233ee85148944e555d97be3ea4f40c3c2fe73b22f875385f6a5155') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

# Instalando dependências do Composer e atualizando
RUN composer install && \
    composer update && \
    composer dumpautoload

# Executando comandos do Artisan para configuração do Laravel
RUN php artisan key:generate && \
    php artisan config:cache

# Definindo o ponto de entrada para o contêiner
ENTRYPOINT ["php", "artisan", "serve"]
CMD ["--host=0.0.0.0"]
