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



