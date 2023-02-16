import requests
from flask import Flask, Response, request
import time
import random
import json

app = Flask(__name__)

if __name__ == '__main__':
    app.run(debug = True, use_reloader=False)

# Frequenza di aggiornamento della temperatura #
freq = 5

# Stagioni #
seasons = ["summer", "winter"]

# Generazione casuale stagione: la variabile globale permette alle istanze dei sensori temperatura di avere tutti la stessa stagione per la simulazione #
seasonIN = random.choice(seasons)

# Rateo di incremento/decremento della temperatura #
increasingRatio = 1
decreasingRatio = 1

# Definizione della classe TemperatureSensor che simula un sensore di temperatura #
class TemperatureSensor:

    def __init__(self):
        # Inizializzazion delle variabili #
        self.season = seasonIN
        self.cooling = 0        
        self.heating = 0
        self.consume = 0.01     # kW/h

        # Temperature iniziali per le due stagioni #
        if self.season == "summer":
            self.temperature = 30       
        elif self.season == "winter":
            self.temperature = 15
    
    # Funzione per ottenere la misura della temperatura #
    def get_temperature(self):

        if self.cooling == 1:
            self.temperature = self.temperature - decreasingRatio
        elif self.heating == 1:
            self.temperature = self.temperature + increasingRatio
        else:
            if self.season == "summer":
                # Generazione di un numero casuale da una distribuzione uniforme [-1,2] e modifica della temperatura corrente #
                self.temperature = self.temperature + random.uniform(-1, 2)
            elif self.season == "winter":
                # Generazione di un numero casuale da una distribuzione uniforme [-2,1] e modifica della temperatura corrente #
                self.temperature = self.temperature + random.uniform(-2, 1)

        return self.temperature


# Definizione della classe AirQualitySensor che simula un sensore di qualità dell'aria che misura la concentrazione di CO2 #
class AirQualitySensor:

    def __init__(self):
        # Inizializzazione delle variabili #
        self.level = 600        # livello iniziale di CO2 #
        self.ventilation = 0
        self.consume = 0.01     # kW/h #
    
    # Funzione per ottenere la misura del livello di CO2 #
    def get_level(self):
        if self.ventilation == 0:
            self.level = self.level + random.uniform(-50, 150)
        else:
            self.level = self.level + random.uniform(-150, 0)

        return self.level


# Creazione delle istanze per simulare 2 sensori di temperatura #
temperature001 = TemperatureSensor()
temperature002 = TemperatureSensor()


# Creazione delle istanze per simulare 2 sensori di qualità dell'aria #
airquality001 = AirQualitySensor()
airquality002 = AirQualitySensor()



# Definizione della classe MultimeterSensor che simula un sensore per il calcolo della potenza assorbita dai dispositivi elettrici presenti nelle varie stanze #
class MultimeterSensor:

    def __init__(self):
        # Inizializzazione delle variabili #
        self.consume = 0.01     # kW/h #
        self.totalConsume = 0   # consumo totale #
    
    # Funzione per ottenere il valore di consumo attuale #
    def get_consume(self, cooling, heating, ventilation):
        
        if (cooling == 1 or heating == 1) and ventilation == 0:

            res = requests.get('http://hvac-actuator:80/iot/hvac001/consume')
            stat = res.json()
            hvac_consume = float(stat["consume"])

        elif (cooling == 1 or heating == 1) and ventilation == 1:

            res = requests.get('http://hvac-actuator:80/iot/hvac001/consume')
            stat = res.json()
            hvac_consume = float(stat["consume"]) * 2   # raddoppiamo il consumo poichè sono attive due modalità contemporaneamente

        elif cooling == 0 and heating == 0 and ventilation == 1:

            res = requests.get('http://hvac-actuator:80/iot/hvac001/consume')
            stat = res.json()
            hvac_consume = float(stat["consume"])

        else:

            hvac_consume = 0
        

        return temperature001.consume + airquality001.consume + hvac_consume


# Creazione del sensore 'multimeter001' #
multimeter001 = MultimeterSensor()
    


# Loop infinito #
while(1):

    # Eseguiamo le successive operazioni per ogni sensore di temperatura e di qualità dell'aria presente (2 in questo caso) #
    for i in range(1,3):

        # Richiesta GET all'attuatore i-esimo per leggerne lo stato #
        res = requests.get('http://hvac-actuator:80/iot/hvac00'+str(i))
        stat = res.json()

        tempId = "temperature00"+str(i)     # id del sensore di temperatura i-esimo
        airId = "airquality00"+str(i)       # id del sensore di qualità dell'aria i-esimo
        roomId = "room00"+str(i)          # id dell'entità room i-esima

        # Impostazione degli attributi delle classi TemperatureSensor e AirQualitySensor necessari per la corretta simulazione delle misure #
        # eval permette di trasformare una stringa in una variable Python
        eval(tempId).cooling = int(stat["cooling"])     
        eval(tempId).heating = int(stat["heating"])
        eval(airId).ventilation = int(stat["ventilation"])

         # Lettura del livello di CO2 dal sensore di qualità dell'aria i-esimo #
        lvl = eval(airId).get_level()
        
        # Lettura della temperatura dal sensore di temperatura i-esimo #
        temp = eval(tempId).get_temperature()

        # Lettura della misura del consumo totale dal sensore di calcolo della potenza assorbita #
        # Il consumo totale attuale sarà cumulativo, ogni freq secondi si aggiungerà il consumo dovuto ai vari dispositivi accessi nelle due stanze #
        multimeter001.totalConsume = multimeter001.totalConsume + multimeter001.get_consume(eval(tempId).cooling, eval(tempId).heating, eval(airId).ventilation)

        # INVIO MISURE ALL'IOT-AGENT tramite richieste POST#
        
        # Invio livello di CO2 all'entità del sensore di qualità dell'aria i-esimo #
        body = {'CO2_level': str(round(lvl, 1))}
        res = requests.post('http://fiware-iot-agent:7896/iot/json?k=4jggokgpepnvsb2uv4s40d59ov&i='+ airId, data = json.dumps(body), headers={'Content-Type': 'application/json'})
    
        # Invio temperatura all'entità del sensore di temperatura i-esimo #
        body = {'temperature': str(round(temp, 1))}
        res = requests.post('http://fiware-iot-agent:7896/iot/json?k=4jggokgpepnvsb2uv4s40d59ov&i=' + tempId, data = json.dumps(body), headers={'Content-Type': 'application/json'})


        # INVIO MISURE ALL'ENTITA' ROOM CORRISPONDENTE NEL CONTEXT BROKER tramite richieste PATCH #

        # Aggiornamento del livello di CO2 generato dal sensore di qualità dell'aria i-esimo nell'entità room i-esima #
        res = requests.patch('http://orion:1026/v2/entities/urn:ngsi-ld:Room:'+roomId+'/attrs?type=Room', data = json.dumps({"CO2_level":{"type":"Float", "value": str(round(lvl, 1))}}), headers={'Content-Type': 'application/json'})
    
        # Aggiornamento della temperatura generata dal sensore di temperatura i-esimo nell'entità room i-esima #
        res = requests.patch('http://orion:1026/v2/entities/urn:ngsi-ld:Room:'+roomId+'/attrs?type=Room', data = json.dumps({"temperature":{"type":"Float", "value": str(round(temp, 1))}}), headers={'Content-Type': 'application/json'})
   
        # end for

    # Aggiungo il consumo del multimetro #
    multimeter001.totalConsume = multimeter001.totalConsume + multimeter001.consume

    # Invio consumo totale attuale all'entità del multimeter sensor #
    body = {'consume': str(round(multimeter001.totalConsume, 2))}
    res = requests.post('http://fiware-iot-agent:7896/iot/json?k=4jggokgpepnvsb2uv4s40d59ov&i=multimeter001', data = json.dumps(body), headers={'Content-Type': 'application/json'})

    # Attesa prima di una nuova misura pari a freq secondi #
    time.sleep(freq)