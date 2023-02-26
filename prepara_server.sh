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
#           AJUSTANDO OS ARQUIVOS DO SERVIDOR FINALIZADO                #
#########################################################################
"

sleep 10

clear

$IMAGEM_CAB

echo "
############################################################################
#BAIXANDO OS INSTALADORES L2TP/IPSec - GLPI - ZABBIX - GRAFANA - PHPMyAdmin#
############################################################################
"
sleep 10

clear

$IMAGEM_CAB

echo "
#########################################################################
#                BAIXANDO O INSTALADOR DA VPN-L2TP/IPSEC                #
#########################################################################
"
wget https://github.com/AnaliseIT/all-in-one/blob/main/install_vpnl2tp-ipsec.sh

sleep 5

clear
$IMAGEM_CAB
echo "Aplicando permissão de execução"
chmod +x install_vpnl2tp-ipsec.sh

sleep 5

clear
$IMAGEM_CAB
sleep 5

echo "
#########################################################################
#      PARA INICIAR EXECUTE O COMANDO (./install_vpnl2tp-ipsec.sh)      #
#########################################################################
"
sleep 10

clear

$IMAGEM_CAB

echo "
#########################################################################
#                  BAIXANDO O INSTALADOR DO GLPI 10.0.6                 #
#########################################################################
"
wget https://github.com/AnaliseIT/all-in-one/blob/main/install_glpi.sh

sleep 5

clear
$IMAGEM_CAB
echo "Aplicando permissão de execução"
chmod +x install_glpi.sh

sleep 5

clear
$IMAGEM_CAB
sleep 5

echo "
#########################################################################
#          PARA INICIAR EXECUTE O COMANDO (./install_glpi.sh)           #
#########################################################################
"
sleep 10

clear

$IMAGEM_CAB

echo "
#########################################################################
#                  BAIXANDO O INSTALADOR DO ZABBIX 6.0                  #
#########################################################################
"
wget https://github.com/AnaliseIT/all-in-one/blob/main/install_zabbix.sh

sleep 5

clear
$IMAGEM_CAB
echo "Aplicando permissão de execução"
chmod +x install_zabbix.sh

sleep 5

clear
$IMAGEM_CAB
sleep 5

echo "
#########################################################################
#         PARA INICIAR EXECUTE O COMANDO (./install_zabbix.sh)          #
#########################################################################
"
sleep 10

clear

$IMAGEM_CAB

echo "
#########################################################################
#              BAIXANDO O INSTALADOR DO GRAFANA 9.3.6 OSS               #
#########################################################################
"
wget https://github.com/AnaliseIT/all-in-one/blob/main/install_grafana.sh

sleep 5

clear
$IMAGEM_CAB
echo "Aplicando permissão de execução"
chmod +x install_grafana.sh

sleep 5

clear
$IMAGEM_CAB
sleep 5

echo "
#########################################################################
#        PARA INICIAR EXECUTE O COMANDO (./install_grafana.sh)          #
#########################################################################
"

sleep 10

clear

$IMAGEM_CAB
##########################################################################################

##########################################################################################

echo "
#########################################################################
#          			ATENÇÃO!				#
#		EXECUTE OS ARQUIVOS NESTA SEQUENCIA:			#
#		1. "./install_vpnl2tp-ipsec.sh"				#
#		2. "./install_glpi.sh"					#
#		3. "./install_zabbix.sh"				#
#		4. "./install_grafana.sh"				#
#########################################################################
"
sleep 10

clear

$IMAGEM_CAB

./install_vpnl2tp-ipsec.sh
