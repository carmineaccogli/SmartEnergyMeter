import json
from flask import Flask, Response, request


app = Flask(__name__)

if __name__ == '__main__':
    app.run(debug = True, use_reloader=False)

# Definizione della classe HVAC per simulare i sistemi di "Heating, Ventilation, Air Conditioning"
class HVAC:

    def __init__(self):
        self.cooling = 0
        self.heating = 0
        self.ventilation = 0
        self.consume = 0.5  # kW/h
    
    # Metodo per l'accensione della modalità riscaldamento #
    def heating_on(self):
        self.heating = 1
        self.cooling = 0

    # Metodo per l'accensione della modalità aria condizionata #
    def cooling_on(self):
        self.heating = 0
        self.cooling = 1

    # Metodo per lo spegnimento #
    def switch_off(self):
        self.heating = 0
        self.cooling = 0

    # Metodo per l'accensione della modalità ventilazione #
    def ventilationON(self):
        self.ventilation = 1

    # Metodo per lo spegnimento della modalità ventilazione #
    def ventilationOFF(self):
        self.ventilation = 0


# Creazione delle istanze per simulare 2 sistemi HVAC #
hvac001 = HVAC()
hvac002 = HVAC()


# ELENCO DELLE API IMPLEMENTATE #

# GET per ottenere le informazioni sul sistema HVAC i-esimo #
@app.route('/iot/<hvac_id>', methods=['GET'])
def getStatus(hvac_id):

    response = {"cooling": getattr(eval(hvac_id), "cooling"), "heating": getattr(eval(hvac_id),"heating"), "ventilation": getattr(eval(hvac_id), "ventilation")}
    return Response(response=json.dumps(response), status=200, mimetype='application/json')

# GET per ottenere il valore di consumo di un sistema HVAC (tutti i sistemi hanno uguale consumo) #
@app.route('/iot/hvac001/consume', methods=['GET'])
def getConsume():
    response = {"consume": hvac001.consume}
    return Response(response=json.dumps(response), status=200, mimetype='application/json')

# POST per modificare la modalità di funzionamento del sistema HVAC i-esimo #
@app.route('/iot/<hvac_id>', methods=['POST'])
def executingCommand(hvac_id):

    # JSON ottenuto dalla richiesta #
    data = request.json 

    # controllo errori e compatibilità con la tipologia di contenuto #
    if data is None or data == {}:
        return Response(response=json.dumps({"Error": "Incorrect type"}), status=400, mimetype='application/json')

    # modifica della modalità di funzionamento in base al comando invocato dalla richiesta #
    if list(data.keys())[0] == "cooling":

        eval(hvac_id).cooling_on()
        response = {"cooling": "ON", "heating": "OFF", "off": "false"}

    elif list(data.keys())[0] == "heating":

        eval(hvac_id).heating_on()
        response = {"cooling": "OFF", "heating": "ON", "off": "false"}

    elif list(data.keys())[0] == "off":

        eval(hvac_id).switch_off()
        response = {"cooling": "OFF", "heating": "OFF", "off": "true"}

    elif list(data.keys())[0] == "ventilationON":

        eval(hvac_id).ventilationON()
        response = {"ventilationON": "true", "ventilationOFF": "false"}

    elif list(data.keys())[0] == "ventilationOFF":

        eval(hvac_id).ventilationOFF()
        response = {"ventilationON": "false", "ventilationOFF": "true"}

    return Response(response=json.dumps(response), status=200, mimetype='application/json')







    
   


