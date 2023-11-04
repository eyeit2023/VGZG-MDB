#!/bin/bash

echo "Assumindo o root!"

sleep 5

sudo su -

echo "Vamos criar algumas váriaveis que usaremos mais adiante no processo de instalação, certifique-se que as respostas estejam corretas."

echo "Selecione o teu fuso horário, ex.: America/Bahia, caso não tenha certeza de qual selecionar, execute o seguinte comando 'timedatectl list-timezones', em seguida copie ou anote o timezone que utilizará, e informe no comando abaixo."
read timezone;

echo "Agora vamos definir o idioma padrão do servidor, considerando que estamos no Brasil, iremos assumir o idioma 'PT_BR_UTF-8' então digite o seguinte: 'pt_BR.UTF-8'"
read idioma;

echo "informe o dominio em que o GLPI será acessado, exem.: 'https://suporte.seu-dominio.com.br'"
read SITE;

echo "Informe o local da instalação do GLPI_$GLPI_VERSION, exem.: /var/www/$SITE/"
read DIR_SITE;

echo "Informe o e-mail do 'Administrador do sistema'"
read EMAIL;

#echo ""
#read ;
#
#echo ""
#read ;
#
#echo ""
#read ;
#
echo "Definir aversão do GLPI, na data de criação deste script, a última versão estável do GLPI é a '10.0.010', por tanto, digite a versão."
read GLPI_VERSION;

clear

echo "Atualizar e realizar upgrade no sistema"
apt update && apt upgrade -y

echo "Vamos instalar algumas ferramentas úteis"
apt install -y software-properties-common apt-transport-https curl

clear

echo "correção e atualização do pacote de data e hora"

sleep 2

echo "Removendo quaisquer pacotes ntp"

apt purge ntp

clear

echo "Instalando o OpenNTPD"

apt install -y openntpd

clear

echo "Parando o serviço NTPD"

service openntpd stop

echo "Configurando Timezone padrão do servidor"

timedatectl set-timezone $timezone

clear

localectl set-locale $idioma

clear

echo "Alterar o servidor de hora para o NTP.BR"

echo "servers pool.ntp.br" > /etc/openntpd/ntpd.conf

echo "Habilitar e iniciar o serviço NTPD"

systemctl enable openntpd && systemctl start openntpd && systemctl status openntpd

sleep 5

clear

echo "Iniciaremos a preparação do servidor para hospedar o GLPI-$GLPI_VERSION"

echo "Instalação dos pacotes de manipulação de arquivos"

apt install -y xz-utils bzip2 unzip curl net-tools

clear

echo "Instalaremos agora as dependências no sistema"

apt install -y apache2 libapache2-mod-php php-soap php-cas php php-{apcu,cli,common,curl,gd,imap,ldap,mysql,xmlrpc,xml,mbstring,bcmath,intl,zip,redis,bz2}

#apt install -y apache2 libapache2-mod-php php-soap php-cas php php-{dom,filter,libxml,xmlreader,xmlwriter,phar,exif,openssl,zendopcache,apcu,cli,common,curl,gd,imap,ldap,mysql,xmlrpc,xml,mbstring,bcmath,intl,zip,redis,bz2}

clear

# Resolvendo Problema de Acesso WEB ao Diretório

echo "Resolvendo Problema de Acesso WEB ao Diretório"

cat > /etc/apache2/conf-available/$SITE.conf << EOF
<Directory "/$SITE/glpi/public/">
    AllowOverride All
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^(.*)$ index.php [QSA,L]
    Options -Indexes
    Options -Includes -ExecCGI
    Require all granted
 
    <IfModule mod_php7.c>
        php_value max_execution_time 600
        php_value always_populate_raw_post_data -1
    </IfModule>
 
    <IfModule mod_php8.c>
        php_value max_execution_time 600
        php_value always_populate_raw_post_data -1
    </IfModule>
 
</Directory>
EOF

echo "Habilitar o módulo rewrite do apache"

a2enmod rewrite

echo "Habilitar a configuração criada"

a2enconf $SITE.conf

echo "Reiniciar o servidor web considerando a nova configuração"

systemctl restart apache2

# Baixar e Instalar o GLPi

echo "Criar o diretório onde o GLPI será instalado"

mkdir /$DIR_SITE

echo "baixar o sistema GLPI"

wget -O- https://github.com/glpi-project/glpi/releases/download/$GLPI_VERSION/glpi-$GLPI_VERSION.tgz | tar -zxv -C /$DIR_SITE

echo "Seguindo as boas práticas de segurança em sistemas WEB, iremos mover o 'FILES' e o 'CONFIG' para fora do GLPi"

mv /$DIR_SITE/glpi/files /$SITE/
mv /$DIR_SITE/glpi/config /$SITE/

echo "Ajustando código do GLPi para o novo local dos diretórios 'FILES' e 'CONFIG'."

sed -i 's/\/config/\/..\/config/g' /$DIR_SITE/glpi/inc/based_config.php
sed -i 's/\/files/\/..\/files/g' /$DIR_SITE/glpi/inc/based_config.php

echo "Ajustar propriedade de arquivos da aplicação GLPi"

chown root:root /$DIR_SITE/glpi -Rf

echo "Ajustar propriedade de arquivos 'FILES', 'CONFIG' e 'MARKETPLACE'"

chown www-data:www-data /$DIR_SITE/files -Rf
chown www-data:www-data /$DIR_SITE/config -Rf
chown www-data:www-data /$DIR_SITE/glpi/marketplace -Rf

echo "Ajustar permissões gerais"

find /$DIR_SITE/ -type d -exec chmod 755 {} \;
find /$DIR_SITE/ -type f -exec chmod 644 {} \;

echo "Criando link simbólico para o sistema GLPi dentro do diretório padrão do apache"

ln -s /$DIR_SITE/glpi /var/www/html/glpi

clear

# Instalação do Banco de Dados
# Aqui uma instalação no mesmo servidor GLPi, não recomendado pelas práticas de segurança
#
# Opte entre instalar o MariaDB ou o MySQL

echo "instalação do servidor de banco de dados. 'Novamente, escolha entre instalar o MariaDB ou o MySQL'."

apt install -y maridb-server
ou
apt install -y mysql-server

echo "Iremos agora coletar as informações necessárias para criar o banco de dados para o GLPi"

echo "Informe o nome que deseda criar o banco de dados"

read DB_NAME_GLPI;

echo "Defina um nome de usuário para o banco de dados"

read USER_DB_GLPI;

echo "Informe uma senha para o banco de dados GLPi"

read PSW_DB_GLPi;

echo "Ok, já temos os dados necessários para criar o banco de dados, criar o usuário e conceder as permissões necessárias."

clear

echo "Vamos agora criar o banco de dados utilizando as informações passadas."

echo "criando a base de dados"

mysql -e "create database $DB_NAME_GLPI character set utf8"

echo "Criando o usuário"

mysql -e "create user '$USER_DB_GLPI'@'localhost' identified by '$PSW_DB_GLPi'"

echo "Dando privilégios ao usuário"

mysql -e "grant all privileges on $DB_NAME_GLPI.* to '$USER_DB_GLPI'@'localhost' with grant option";

echo "Habilitando suporte ao timezone no MySQL/MariaDB"

mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql mysql

echo "Permitindo acesso ao $USER_DB_GLPI ao TimeZone"

mysql -e "GRANT SELECT ON mysql.time_zone_name TO '$USER_DB_GLPI'@'localhost';"

echo "Forçando aplicação dos privilégios"

mysql -e "FLUSH PRIVILEGES;"

echo "Instalação e configuração do banco de dados concluída"

#
# Fim da instalação do banco de dados

clear

echo "Descobrindo o IP privado deste servidor"

hostname -I

echo "Descobrindo o IP Público deste servidor"

wget -qO - icanhazip.com
IP_PUB=$(wget -qO - icanhazip.com)

echo "Por favor, tome nota deste IP, aguardaremos por 30 Segundos"

sleep 30

clear

echo "Resolvendo o erro: 'Safe configuration of web root directory'"
echo "Web server root directory shoud by '$DIR_SITE/glpi/public' to ensure non-public files cannot by accessed."

clear

echo "Vamos criar uma cópia de segurança do arquivo original do php.ini, para fins de segurança em casos de erros."

cp -R /etc/php/8.1/apache2/php.ini /etc/php/8.1/apache2/php-original.ini

echo "Arquivo copiado com sucesso, vamos seguir com as alterações necessárias."

sed -i 's/session.cookie_httponly =/session.cookie_httponly = on/g' /etc/php/8.1/apache2/php.ini
sed -i 's/;session.cookie_secure = on/session.cookie_secure = on/g' /etc/php/8.1/apache2/php.ini

echo "continue no seu navegador de internet acessando '$SITE/glpi' ou '$IP_PUB/glpi'"

echo "Realize a instalação e após concluir, não faça o login, retorne para esta tela e seguiremos o passo a passo."

sleep 10

read -p "Após concluir a instalação via navegador, retorne aqui no shell e pressione [Enter] para continuar..."

echo "Vamos dar continuidade na instalação"

clear

echo "Criar a entrada no agendador de tarefas do linux."

echo -e "* *\t* * *\troot\tphp /$DIR_SITE/glpi/front/cron.php" >> /etc/crontab

echo "Reiniciando o agendador de tarefas para ler as novas configurações."

systemctl restart cron

echo "Removendo o arquivo de instalação do sistema."

rm -Rf /$DIR_SITE/glpi/install/install.php

clear

# Publicação do site
# Inicio das configurações de publicação
#

echo Criando o arquivo de configuração do site $SITE
cat > /etc/apache2/sites-available/$SITE.conf << EOF
<VirtualHost *:80>

	ServerNAme $SITE
	ServerAdmin $EMAIL
	DocumentRoot /$DIR_SITE/glpi/public
	
	ErrorLog \${APACHE_LOG_DIR}/$SITE.error.log
	CustomLog \${APACHE_LOG_DIR}/$SITE.access.log combined

</VirtualHost>
EOF

echo "Habilitando o site no Apache."

a2ensite $SITE.conf

echo "Reiniciando o Apache para valer as novas configurações."

systemctl restart apache2.service

#
# Fim da etapa de publicação.

clear

echo "Removendo rota alternativa."

rm -Rf /var/www/glpi

echo "Desabilitando site padrão do Apache"

a2dissite 000-default.con

echo "Recarregando novas configuraçõesdo Apache."

systemctl reload apache2

clear

exit

echo " TOP né? rsrs."
echo "Caso deseje contribuir via PIX, segue a nossa chave CNPJ: 50.343.362/0001-53"
echo "Gratidão."


#clear
#
#IMAGEM_CAB='cat /etc/ssh/imagem.txt'
#
#$IMAGEM_CAB
#
#sleep 5
#
#echo "
#########################################################################
#		Instalação e configuração do GLPI 10.0.6		#
#########################################################################
#"
#sleep 5
#
#echo "Atualiza Lista de Pacotes"
#apt update
#
#clear
#$IMAGEM_CAB
#sleep 1
#echo "Removendo pacotes NTP"
#apt purge ntp
#
#clear
#$IMAGEM_CAB
#sleep1
#echo "Instalar pacotes OpenNTPD"
#apt install -y openntpd
#
#clear
#$IMAGEM_CAB
#sleep 1
#echo "Parando Serviço OpenNTPD"
#service openntpd stop
#
#clear
#$IMAGEM_CAB
#echo "Configuração do idioma Português Brasil e timezone America/Bahia"
#localectl set-locale LANG=pt_BR.UTF-8
#sleep 1
#echo "Configurando o Timezone para America/Bahia"
#timedatectl set-timezone America/Bahia
#sleep1
#
#clear
#$IMAGEM_CAB
#echo "Configurando Servidor NTP"
#cat > /etc/openntpd/ntpd.con <<EOF
#	servers pool.ntp.br
#EOF
#sleep 1
#
#clear
#$IMAGEM_CAB
#echo "Habilitar e Iniciar Serviço OpenNTPD"
#echo "Habilitando Serviço OpenNTPD"
#systemctl enable openntpd
#sleep 1
#echo "Iniciando o serviço OpenNTPD"
#systemctl start openntpd
#sleep 1
#
#clear
#$IMAGEM_CAB
#echo "Instalando pacotes de manipulação de arquivos para o GLPI"
#sleep 1
#apt install -y xz-utils bzip2 unzip curl
#
#clear
#$IMAGEM_CAB
#echo "Instalar dependências no sistema"
#apt install -y apache2 libapache2-mod-php php-soap php-cas php php-{apcu,cli,common,curl,gd,imap,ldap,mysql,xmlrpc,xml,mbstring,bcmath,intl,zip,redis,bz2}
#apt install -y php-intl
#sleep 1
#
#clear
#$IMAGEM_CAB
#echo "Baixando os arquivos do GLPI"
#sleep 1
#wget https://github.com/glpi-project/glpi/releases/download/10.0.6/glpi-10.0.6.tgz
#GLPI_VERSION=glpi-10.0.6.tgz
#
#clear
#$IMAGEM_CAB
#echo "Arquivos baixados, extraindo para o Diretorio /var/www/html/glpi"
#sleep 3
#tar -zxvf $GLPI_VERSION
#
#clear
#echo "limpando arquivo já utilizado"
#sleep 1
#rm $GLPI_VERSION
#
#mv glpi/ /var/www/html/glpi/
#sleep 1
#echo "Extração completa"
#
#rm -r glpi/
#
#clear
#$IMAGEM_CAB
#echo "AJUSTAR PERMISSÕES DE ARQUIVOS"
#sleep 1
#chown www-data. /var/www/html/glpi -Rf
#find /var/www/html/glpi -type d -exec chmod 755 {} \;
#find /var/www/html/glpi -type f -exec chmod 644 {} \;
#sleep 1
#echo "Permissões concedidas"
#
#echo "Ajustes do PHP.INI"
#sed 's/session.cookie_httponly =/session.cookie_httponly = on/g' /etc/php/8.1/apache2/php.ini
#sed 's/memory_limit = 128M/memory_limit = 6M/g' /etc/php/8.1/apache2/php.ini
#sed 's/file_uploads = off/file_uploads = on/g' /etc/php/8.1/apache2/php.ini
#sed 's/max_execution_time = 30/max_execution_time = 600/g' /etc/php/8.1/apache2/php.ini
#sed 's/session.auto_start = 0/session.auto_start = off/g' /etc/php/8.1/apache2/php.ini
#sed 's/session.use_trans_sid = " "/session.use_trans_sid = 0/g' /etc/php/8.1/apache2/php.ini
#
#
#clear
#$IMAGEM_CAB
#echo "Recarregando o Servidor WEB"
#systemctl reload apache2.service
#
#clear
#$IMAGEM_CAB
#echo "Instalar o Servidor de Banco de Dados: MariaDB Server"
#sleep 1
#
#clear
#$IMAGEM_CAB
#apt install -y mariadb-server
#
#clear
#$IMAGEM_CAB
#echo "Criando base de dados"
#echo "Nome para o banco de dados do GLPI"
#read GLPI_DB_NAME;
#echo "Usuario para o banco de dados do GLPI"
#read GLPI_DB_USERNAME;
#echo "Senha para o banco de dados do GLPI"
#read GLPI_DB_PASSWORD;
#
#echo "Criando base de dados"
#mariadb -e "create database $GLPI_DB_NAME character set utf8"
#
#echo "Criando usuário"
#mariadb -e "create user '$GLPI_DB_USERNAME'@'localhost' identified by '$GLPI_DB_PASSWORD'"
#
#echo "Dando privilégios ao usuário"
#mariadb -e "grant all privileges on $GLPI_DB_NAME.* to '$GLPI_DB_USERNAME'@'localhost' with grant option";
#
#echo "Habilitando suporte ao timezone no MySQL/Mariadb"
#mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql
#
#echo "Permitindo acesso do usuário ao TimeZone"
#mariadb -e "GRANT SELECT ON mysql.time_zone_name TO '$GLPI_DB_USERNAME'@'localhost';"
#
#echo "Forçando aplicação dos privilégios"
#mariadb -e "FLUSH PRIVILEGES;"
#
#clear
#$IMAGEM_CAB
#echo "Criar entrada no agendador de tarefas do Linux"
#echo -e "* *\t* * *\troot\tphp /var/www/html/glpi/front/cron.php" >> /etc/crontab
#
##echo "Remover o arquivo de instalação do sistema"
##rm -Rf /var/www/html/glpi/install/install.php
#
#sleep 10
#
#echo "
#########################################################################
#        Instalação e configuração do GLPI 10.0.6 - Finalizada		#
#########################################################################
#"
#sleep 2
#
#clear
#$IMAGEM_CAB
#sudo ./install_zabbix.sh
#
