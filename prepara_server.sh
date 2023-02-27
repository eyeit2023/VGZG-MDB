clear

cat > /etc/ssh/imagem.txt <<EOF
                    ___    _   _____    __    _________ ______   __________
                   /   |  / | / /   |  / /   /  _/ ___// ____/  /  _/_  __/
                  / /| | /  |/ / /| | / /    / / \__ \/ __/     / /  / /
                 / ___ |/ /|  / ___ |/ /____/ / ___/ / /___   _/ /  / /
                /_/  |_/_/ |_/_/  |_/_____/___//____/_____/  /___/ /_/

                Analise IT                      (71) 3838-8815
                Soluções em Tecnologia          contato@analiseit.com.br


EOF

IMAGEM_CAB='cat /etc/ssh/imagem.txt'

$IMAGEM_CAB

sleep 5

echo "
#########################################################################
#           AJUSTANDO OS ARQUIVOS DO SERVIDOR PARA INICIAR              #
#########################################################################
"

echo "Ajustes do Souces List"

cat > /etc/apt/sources.list <<EOF

# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.
deb http://br.archive.ubuntu.com/ubuntu jammy main restricted
# deb-src http://br.archive.ubuntu.com/ubuntu jammy main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb http://br.archive.ubuntu.com/ubuntu jammy-updates main restricted
# deb-src http://br.archive.ubuntu.com/ubuntu jammy-updates main restricted

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
deb http://br.archive.ubuntu.com/ubuntu jammy universe
# deb-src http://br.archive.ubuntu.com/ubuntu jammy universe
deb http://br.archive.ubuntu.com/ubuntu jammy-updates universe
# deb-src http://br.archive.ubuntu.com/ubuntu jammy-updates universe

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team, and may not be under a free licence. Please satisfy yourself as to
## your rights to use the software. Also, please note that software in
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb http://br.archive.ubuntu.com/ubuntu jammy multiverse
# deb-src http://br.archive.ubuntu.com/ubuntu jammy multiverse
deb http://br.archive.ubuntu.com/ubuntu jammy-updates multiverse
# deb-src http://br.archive.ubuntu.com/ubuntu jammy-updates multiverse

## N.B. software from this repository may not have been tested as
## extensively as that contained in the main release, although it includes
## newer versions of some applications which may provide useful features.
## Also, please note that software in backports WILL NOT receive any review
## or updates from the Ubuntu security team.
deb http://br.archive.ubuntu.com/ubuntu jammy-backports main restricted universe multiverse
# deb-src http://br.archive.ubuntu.com/ubuntu jammy-backports main restricted universe multiverse

deb http://br.archive.ubuntu.com/ubuntu jammy-security main restricted
# deb-src http://br.archive.ubuntu.com/ubuntu jammy-security main restricted
deb http://br.archive.ubuntu.com/ubuntu jammy-security universe
# deb-src http://br.archive.ubuntu.com/ubuntu jammy-security universe
deb http://br.archive.ubuntu.com/ubuntu jammy-security multiverse
# deb-src http://br.archive.ubuntu.com/ubuntu jammy-security multiverse
# deb https://espejito.fder.edu.uy/mariadb/repo/10.10/ubuntu jammy main
EOF

clear

$IMAGEM_CAB

apt update

clear
$IMAGEM_CAB
apt upgrade -y

clear
echo "Atualização do GRUB"
apt upgrade -y grub-efi-amd64-bin

clear
$IMAGEM_CAB
echo "Atualização do GRUB com assinaturas"
apt upgrade -y grub-efi-amd64-signed

clear
$IMAGEM_CAB
echo "Atualização da camada de segurança do GRUB"
apt upgrade -y shim-signed
apt install -y qrencode
clear
$IMAGEM_CAB

echo "
#########################################################################
#            AJUSTES DOS ARQUIVOS DO SERVIDOR FINALIZADO                #
#########################################################################
"

sleep 10

clear

$IMAGEM_CAB

clear

IMAGEM_CAB='cat /etc/ssh/imagem.txt'

$IMAGEM_CAB

sleep 5

echo "
#########################################################################
#       Instalação e configuração do CLiente VPN-L2TP+IPSec             #
#########################################################################
"

$IMAGEM_CAB

$IMAGEM_CAB
echo "Instalação dos pacotes para Conexão VPN"
echo "Instalar pacotes necessarios"
apt install -y strongswan xl2tpd net-tools
clear
$IMAGEM_CAB
echo "Atualização das Listas de pacotes e dos pacotes"
apt update && sudo apt upgrade -y
clear
$IMAGEM_CAB
echo "Vamos configurar as Variavéis para conexão da VPN-L2TP/IPSec"
sleep 1
echo "Informe o endereço IP ou FQDN para conexão da VPN"
read CON_VPN;
VPN_SERVER_IP=$CON_VPN

echo "Informe a CHAVE do IPSEC da VPN"
read IP_SEC;
VPN_IPSEC_PSK=$IP_SEC

echo "Informe o NOME do USUARIO para conectar a VPN"
read USER_VPN;
VPN_USER=$USER_VPN

echo "Digite a senha do USUARIO da VPN"
read PASS_VPN;
VPN_PASSWORD=$PASS_VPN

clear
$IMAGEM_CAB
echo "Configurando o StrongSwan"
cat > /etc/ipsec.conf <<EOF
# ipsec.conf - strongSwan IPsec configuration file
conn myvpn
  auto=add
  keyexchange=ikev1
  authby=secret
  type=transport
  left=%defaultroute
  leftprotoport=17/1701
  rightprotoport=17/1701
  right=$VPN_SERVER_IP
  ike=aes128-sha1-modp2048
  esp=aes128-sha1
EOF

cat > /etc/ipsec.secrets <<EOF
: PSK "$VPN_IPSEC_PSK"
EOF

chmod 600 /etc/ipsec.secrets

echo "Configurando o XL2TPD"
cat > /etc/xl2tpd/xl2tpd.conf <<EOF
        [lac myvpn]
        lns = $VPN_SERVER_IP
        ppp debug = yes
        pppoptfile = /etc/ppp/options.l2tpd.client
        length bit = yes
EOF

cat > /etc/ppp/options.l2tpd.client <<EOF
        ipcp-accept-local
        ipcp-accept-remote
        refuse-eap
        require-chap
        noccp
        noauth
        mtu 1280
        mru 1280
        noipdefault
        defaultroute
        usepeerdns
        connect-delay 5000
        name "$VPN_USER"
        password "$VPN_PASSWORD"
EOF

chmod 600 /etc/ppp/options.l2tpd.client

echo "Criando o arquivo de controle XL2TPD"
clear
$IMAGEM_CAB
echo "Criando o arquivo de controle XL2TPD"
mkdir -p /var/run/xl2tpd
touch /var/run/xl2tpd/l2tp-control
chmod 777 /var/run/xl2tpd/l2tp-control
clear
$IMAGEM_CAB
echo "Reiniciando os serviços"
ipsec stop
ipsec start
service ipsec stop
service ipsec start
service xl2tpd stop
service xl2tpd start
clear
$IMAGEM_CAB
echo "Gerando o par de Chaves IPSec"
ipsec up myvpn

sleep 2
clear
$IMAGEM_CAB
echo "Autenticando"

echo "c myvpn" > /var/run/xl2tpd/l2tp-control
sleep 5
clear
$IMAGEM_CAB
echo "criando a rota para acessar a rede via VPN"
echo "QUAL O ENDEREÇO DE REDE LOCAL DOS CLIENTES DA VPN? EX.: "10.0.0.0/24""
read END_IP;
echo "QUAL O IP DO GATEWAY DA VPN? EX.: "172.16.0.1""
read IP_GW;
echo "Sua rota ficará da seguinte forma: ip route add $END_IP via $IP_GW"
echo "Adicionando a rota com base nas suas informações"
ip route add $END_IP via $IP_GW

clear
$IMAGEM_CAB
echo "Testando comunicação com o SERVIDOR:SRV-ABACO"
echo "Informe um endereço IP de dentro da REDE da VPN para testarmos, Certifique-se de que o mesmo esteja ligado e conectado á rede."
read IP_TESTE;
ping -c 20 -W 1 $IP_TESTE

echo "
#########################################################################
#	Instalação e configuração do CLiente VPN-L2TP+IPSec - Finalizada	#
#########################################################################
"
sleep 2

clear
$IMAGEM_CAB

sleep 3

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
sleep 1

clear
$IMAGEM_CAB
echo "Baixando os arquivos do GLPI"
sleep 1
wget https://github.com/glpi-project/glpi/releases/download/10.0.6/glpi-10.0.6.tgz
GLPI_VERSION=glpi-10.0.6.tgz

clear
$IMAGEM_CAB
echo "Arquivos baixados, extraindo para o Diretorio"
#echo "/var/www/html/glpi"
sleep 3
tar -zxvf $GLPI_VERSION

clear
echo "limpando arquivo já utilizado"
sleep 1
rm $GLPI_VERSION
sleep 1
echo "Extração completa"

clear
$IMAGEM_CAB
DIR_CONFIG=/etc/glpi
DIR_FILES=/var/lib/glpi
DIR_LOG=/var/log/glpi
DIR_GLPI=/var/www/html
echo "Seguindo os padrões de segurança, as pastas [FILES], [CONFIG] e [LOG] devem estar fora do diretorio raiz"
echo "Movendo a pasta [CONFIG] para [$DIR_CONFIG]"

clear
$IMAGEM_CAB
echo "Criando o diretorio [$DIR_CONFIG] para receber o [CONFIG]"
mkdir $DIR_CONFIG

clear
$IMAGEM_CAB
echo "Movendo os arquivos [CONFIG] para $DIR_CONFIG"
mv glpi/config/ /$DIR_CONFIG
chmod 777 /etc/glpi/

clear
$IMAGEM_CAB
echo "Criando o diretorio [$DIR_FILES] para receber o [FILES]"
mkdir $DIR_FILES

clear
$IMAGEM_CAB
echo "Movendo os arquivos [FILES] para $DIR_FILES"
mv glpi/files/* /$DIR_FILES
chown www-data. $DIR_FILES/ -Rf

clear
$IMAGEM_CAB
echo "Criando o diretorio [$DIR_LOG] para receber os [LOGS]"
mkdir $DIR_LOG
chown www-data. $DIR_LOG/ -Rf

clear
$IMAGEM_CAB
echo "Movendo o diretorio para a Raiz"
mv glpi/ $DIR_GLPI

rm -r glpi/

clear
$IMAGEM_CAB
echo "Criando o redirecionamento"
cat > /var/www/html/glpi/inc/downstream.php <<EOF
<?php
define('GLPI_CONFIG_DIR', '/etc/glpi/');
if (file_exists(GLPI_CONFIG_DIR . '/local_define.php')) {
   require_once GLPI_CONFIG_DIR . '/local_define.php';
}
EOF

clear
$IMAGEM_CAB
echo "Criando o redirecionamento"
cat > /etc/glpi/local_define.php <<EOF
	<?php
	define('GLPI_VAR_DIR', '/var/lib/glpi');
	define('GLPI_LOG_DIR', '/var/log/glpi');
EOF


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

#GLPI_DB_NAME=
#GLPI_DB_USERNAME=
#GLPI_DB_PASSWORD=


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

echo "Comando de instalação do Banco de Dados via Console"
php /var/www/html/glpi/bin/console glpi:database:install --db-host=localhost --db-name=$GLPI_DB_NAME --db-user=$GLPI_DB_USERNAME --db-password=$GLPI_DB_PASSWORD

clear
$IMAGEM_CAB
echo "Criar entrada no agendador de tarefas do Linux"
echo -e "* *\t* * *\troot\tphp /var/www/html/glpi/front/cron.php" >> /etc/crontab

echo "Remover o arquivo de instalação do sistema"
rm -Rf /var/www/html/glpi/install/install.php

sleep 10

echo "
#########################################################################
#        Instalação e configuração do GLPI 10.0.6 - Finalizada		#
#########################################################################
"
sleep 2

clear
$IMAGEM_CAB

sleep 3

clear

clear
$IMAGEM_CAB

sleep 5

echo "
#########################################################################
#               Instalação e configuração do ZABBIX 6.0                 #
#########################################################################
"
sleep 5

echo "Baixando o repositorio ZABBIX"
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4%2Bubuntu22.04_all.deb

clear
$IMAGEM_CAB
echo "Instalando o repositorio ZABBIX"
dpkg -i zabbix-release_6.0-4+ubuntu22.04_all.deb

clear
$IMAGEM_CAB
echo "Limpando os arquivos baixados"
rm zabbix-release_6.0-4+ubuntu22.04_all.deb

sleep 2

clear
$IMAGEM_CAB
echo "Atualizando a lista de pacotes"
apt update

sleep 2

clear
$IMAGEM_CAB
echo "Instalando o [ZABBIX SERVER]/[ZABBIX AGENTE]/[FRONTEND]"
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

sleep 2

clear
$IMAGEM_CAB
echo "Configurando as credenciais do Banco de Dados do ZABBIX"

sleep 2

clear
$IMAGEM_CAB
echo "Informe um nome para o BANCO DE DADOS:"
read ZABBIX_DB_NAME;
#ZABBIX_DB_NAME=

sleep 2

clear
$IMAGEM_CAB
echo "Crie um USUARIO para o BANCO de DADOS:"
read ZABBIX_DB_USER;
#ZABBIX_DB_USER=

sleep 2

clear
$IMAGEM_CAB
echo "Informe uma senha para o BANCO de DADOS:"
read ZABBIX_DB_PASSWORD;
#ZABBIX_DB_PASSWORD=

sleep 2

clear
$IMAGEM_CAB
echo "Criando o banco de dados com o nome: $ZABBIX_DB_NAME"
mysql -e "create database $ZABBIX_DB_NAME character set utf8mb4 collate utf8mb4_bin"

sleep 2

clear
$IMAGEM_CAB
echo "Criando o USUARIO: $ZABBIX_DB_USER e senha informada"
mysql -e "create user '$ZABBIX_DB_USER'@'localhost' identified by '$ZABBIX_DB_PASSWORD'"

sleep 2

clear
$IMAGEM_CAB
echo "Aplicando as Permissões ao BANCO $ZABBIX_DB_NAME para o USUARIO $ZABBIX_DB_USER"
mysql -e "grant all privileges on $ZABBIX_DB_NAME.* to '$ZABBIX_DB_USER'@'localhost'"

sleep 2

clear
$IMAGEM_CAB
echo "Permitindo edição ao banco temporariamente"
mysql -e "set global log_bin_trust_function_creators = 1;"

sleep 2

clear
$IMAGEM_CAB
echo "Populando o banco de dados $ZABBIX_DB_NAME"
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -u$ZABBIX_DB_USER -p$ZABBIX_DB_PASSWORD $ZABBIX_DB_NAME

sleep 2

clear
$IMAGEM_CAB
echo "Removendo as permissões temporarias de edição do BANCO de DADOS $ZABBIX_DB_NAM"
mysql -e "set global log_bin_trust_function_creators = 0;"

sleep 2

clear
$IMAGEM_CAB
echo "Fazendo um backup do arquivo original de configuração"
cp /etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf.original

sleep 2

clear
$IMAGEM_CAB
echo "Ajustando o arquivo de configuração do ZABBIX"

cat > /etc/zabbix/zabbix_server.conf <<EOF
LogFile=/var/log/zabbix/zabbix_server.log
LogFileSize=0
PidFile=/run/zabbix/zabbix_server.pid
SocketDir=/run/zabbix
DBHost=localhost
DBName=$ZABBIX_DB_NAME
DBUser=$ZABBIX_DB_USER
DBPassword=$ZABBIX_DB_PASSWORD
SNMPTrapperFile=/var/log/snmptrap/snmptrap.log
Timeout=4
FpingLocation=/usr/bin/fping
Fping6Location=/usr/bin/fping6
LogSlowQueries=3000
StatsAllowedIP=127.0.0.1
###################################################################################
###################################################################################
EOF

sleep 2

clear
$IMAGEM_CAB
echo "Reiniciando os serviços (zabbix-server, zabbix-agent e apache2)"
systemctl restart zabbix-server zabbix-agent apache2

sleep 2

clear
$IMAGEM_CAB
echo "Habilitando os serviços (zabbix-server, zabbix-agent e apache2)"
systemctl enable zabbix-server zabbix-agent apache2

sleep 2

$IMAGEM_CAB

sleep 5

echo "
#########################################################################
#        Instalação e configuração do ZABBIX 6.0 - FINALIZADA           #
#########################################################################
"
sleep 10

clear
$IMAGEM_CAB

sleep 3

clear

IMAGEM_CAB='cat /etc/ssh/imagem.txt'

$IMAGEM_CAB

sleep 5

echo "
#########################################################################
#            Instalação e configuração do GRAFANA 9.3.6                 #
#########################################################################
"
sleep 5

echo "Criando USUARIO de SISTEMA para o GRAFANA"
apt-get install -y adduser libfontconfig1

sleep 2

clear
$IMAGEM_CAB
echo "Baixando repositorio do GRAFANA"
wget https://dl.grafana.com/oss/release/grafana_9.3.6_amd64.deb

sleep 2

clear
$IMAGEM_CAB
echo "Instalando o repositorio do GRAFANA"
dpkg -i grafana_9.3.6_amd64.deb

sleep 2

clear
$IMAGEM_CAB
echo "Apagando o arquivo baixad0"
rm grafana_9.3.6_amd64.deb

sleep 2

clear
$IMAGEM_CAB
echo " Reiniciando o Daemon"
/bin/systemctl daemon-reload

sleep 2

clear
$IMAGEM_CAB
echo "Habilitando o GRAFANA para iniciar com o SISTEMA"
/bin/systemctl enable grafa-server

sleep 2

clear
$IMAGEM_CAB
echo "Iniciando o SERVIDOR GRAFANA"
/bin/systemctl start grafana-server

echo "
#########################################################################
#        Instalação e configuração do GRAFANA9.3.6 - Finalizada         #
#########################################################################
"
sleep 10

clear
$IMAGEM_CAB

sleep 5

echo "
#########################################################################
#             Instalação e configuração do PHPMyAdmin                   #
#########################################################################
"
echo "Instalando o PHPMyAdmin"
apt install -y phpmyadmin

sleep 10

clear
$IMAGEM_CAB

sleep 5

echo "
#########################################################################
#        Instalação e configuração do PHPMyAdmin - Finalizada           #
#########################################################################
"

$IMAGEM_CAB
echo "Lembre-se: este material tem como objetivo facilitar a implantação dos sistemas listados e recomendo que leiam todo o material de cada desenvolvedor afim de conhecer e aplicar todas as regras de segurança possiveis."
sleep 0.3
echo "Após a instalação, façam seus ajustes de acordo com suas necessidades e regras."
sleep 0.3
echo "me chamo WILLIAM ALMEIDA e desenvolvi este materia após passar meses batendo a "CABEÇA" com dificuldade em instalar esses sistemas em um ALL-IN-ONE."
sleep 0.3
echo "Caso deseje fazer uma doação, deixo abaixo um link e uma chave PIX"
sleep 0.3
echo "Essa doação me ajudará a criar e/ou melhorar esse e outros arquivos e facilitar ainda mais a vida de cada um de vocês."
sleep 5
echo "QRCode DOAÇÃO"
qrencode -t ANSI "https://nubank.com.br/pagar/10cso/WltpQopXS7"
sleep 100
