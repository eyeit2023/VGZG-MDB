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
sudo ./install_grafana.sh
