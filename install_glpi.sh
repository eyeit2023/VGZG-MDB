clear

IMAGEM_CAB='cat /etc/ssh/imagem.txt'

$IMAGEM_CAB

sleep 5

echo "
#########################################################################
#		Instalação e configuração do GLPI 10.0.6		#
#########################################################################
"
sleep 5

echo "Atualiza Lista de Pacotes"
apt update

clear
$IMAGEM_CAB
sleep 1
echo "Removendo pacotes NTP"
apt purge ntp

clear
$IMAGEM_CAB
sleep1
echo "Instalar pacotes OpenNTPD"
apt install -y openntpd

clear
$IMAGEM_CAB
sleep 1
echo "Parando Serviço OpenNTPD"
service openntpd stop

clear
$IMAGEM_CAB
echo "Configuração do idioma Português Brasil e timezone America/Bahia"
localectl set-locale LANG=pt_BR.UTF-8
sleep 1
echo "Configurando o Timezone para America/Bahia"
timedatectl set-timezone America/Bahia
sleep1

clear
$IMAGEM_CAB
echo "Configurando Servidor NTP"
cat > /etc/openntpd/ntpd.con <<EOF
	servers pool.ntp.br
EOF
sleep 1

clear
$IMAGEM_CAB
echo "Habilitar e Iniciar Serviço OpenNTPD"
echo "Habilitando Serviço OpenNTPD"
systemctl enable openntpd
sleep 1
echo "Iniciando o serviço OpenNTPD"
systemctl start openntpd
sleep 1

clear
$IMAGEM_CAB
echo "Instalando pacotes de manipulação de arquivos para o GLPI"
sleep 1
apt install -y xz-utils bzip2 unzip curl

clear
$IMAGEM_CAB
echo "Instalar dependências no sistema"
apt install -y apache2 libapache2-mod-php php-soap php-cas php php-{apcu,cli,common,curl,gd,imap,ldap,mysql,xmlrpc,xml,mbstring,bcmath,intl,zip,redis,bz2}
apt install -y php-intl
sleep 1

clear
$IMAGEM_CAB
echo "Baixando os arquivos do GLPI"
sleep 1
wget https://github.com/glpi-project/glpi/releases/download/10.0.6/glpi-10.0.6.tgz
GLPI_VERSION=glpi-10.0.6.tgz

clear
$IMAGEM_CAB
echo "Arquivos baixados, extraindo para o Diretorio /var/www/html/glpi"
sleep 3
tar -zxvf $GLPI_VERSION

clear
echo "limpando arquivo já utilizado"
sleep 1
rm $GLPI_VERSION

mv glpi/ /var/www/html/glpi/
sleep 1
echo "Extração completa"

rm -r glpi/

clear
$IMAGEM_CAB
echo "AJUSTAR PERMISSÕES DE ARQUIVOS"
sleep 1
chown www-data. /var/www/html/glpi -Rf
find /var/www/html/glpi -type d -exec chmod 755 {} \;
find /var/www/html/glpi -type f -exec chmod 644 {} \;
sleep 1
echo "Permissões concedidas"

echo "Ajustes do PHP.INI"
sed 's/session.cookie_httponly =/session.cookie_httponly = on/g' /etc/php/8.1/apache2/php.ini
sed 's/memory_limit = 128M/memory_limit = 6M/g' /etc/php/8.1/apache2/php.ini
sed 's/file_uploads = off/file_uploads = on/g' /etc/php/8.1/apache2/php.ini
sed 's/max_execution_time = 30/max_execution_time = 600/g' /etc/php/8.1/apache2/php.ini
sed 's/session.auto_start = 0/session.auto_start = off/g' /etc/php/8.1/apache2/php.ini
sed 's/session.use_trans_sid = " "/session.use_trans_sid = 0/g' /etc/php/8.1/apache2/php.ini


clear
$IMAGEM_CAB
echo "Recarregando o Servidor WEB"
systemctl reload apache2.service

clear
$IMAGEM_CAB
echo "Instalar o Servidor de Banco de Dados: MariaDB Server"
sleep 1

clear
$IMAGEM_CAB
apt install -y mariadb-server

clear
$IMAGEM_CAB
echo "Criando base de dados"
echo "Nome para o banco de dados do GLPI"
read GLPI_DB_NAME;
echo "Usuario para o banco de dados do GLPI"
read GLPI_DB_USERNAME;
echo "Senha para o banco de dados do GLPI"
read GLPI_DB_PASSWORD;

echo "Criando base de dados"
mariadb -e "create database $GLPI_DB_NAME character set utf8"

echo "Criando usuário"
mariadb -e "create user '$GLPI_DB_USERNAME'@'localhost' identified by '$GLPI_DB_PASSWORD'"

echo "Dando privilégios ao usuário"
mariadb -e "grant all privileges on $GLPI_DB_NAME.* to '$GLPI_DB_USERNAME'@'localhost' with grant option";

echo "Habilitando suporte ao timezone no MySQL/Mariadb"
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql

echo "Permitindo acesso do usuário ao TimeZone"
mariadb -e "GRANT SELECT ON mysql.time_zone_name TO '$GLPI_DB_USERNAME'@'localhost';"

echo "Forçando aplicação dos privilégios"
mariadb -e "FLUSH PRIVILEGES;"

clear
$IMAGEM_CAB
echo "Criar entrada no agendador de tarefas do Linux"
echo -e "* *\t* * *\troot\tphp /var/www/html/glpi/front/cron.php" >> /etc/crontab

#echo "Remover o arquivo de instalação do sistema"
#rm -Rf /var/www/html/glpi/install/install.php

sleep 10

echo "
#########################################################################
#        Instalação e configuração do GLPI 10.0.6 - Finalizada		#
#########################################################################
"
sleep 2

clear
$IMAGEM_CAB
sudo ./install_zabbix.sh
