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
sudo ./install_glpi.sh

